import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/rule_filter.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/taxon_tree.dart';

final searchDatabaseProvider =
    AsyncNotifierProvider<SearchDatabase, List<MainTaxonomyData>>(
      () => SearchDatabase(),
    );

class SearchDatabase extends AsyncNotifier<List<MainTaxonomyData>> {
  int _latestSearch = 0;

  @override
  FutureOr<List<MainTaxonomyData>> build() async {
    ref.watch(databaseProvider);
    return [];
  }

  Future<void> search(
    String query, {
    required SearchFilter filterBy,
    RuleFilter<SearchFilter> rules = const RuleFilter(),
  }) async {
    final searchId = ++_latestSearch;
    // Keeps the previous results; the list shows them until this finishes.
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => MDDSearch(
        ref.read(databaseProvider),
      ).searchSpecies(query, filterBy: filterBy, rules: rules),
    );
    // A newer search started meanwhile; its results win.
    if (searchId == _latestSearch) state = result;
  }

  /// Empties the results and drops any search still running.
  void clear() {
    _latestSearch++;
    state = const AsyncValue.data([]);
  }
}

final totalRecordsProvider = FutureProvider<int>((ref) async {
  return await MddQuery(ref.watch(databaseProvider)).totalRecords();
});

final speciesListProvider =
    AsyncNotifierProvider<SpeciesList, List<MddGroupListResult>>(
      () => SpeciesList(),
    );

class SpeciesList extends AsyncNotifier<List<MddGroupListResult>> {
  Future<List<MddGroupListResult>> _fetchSpeciesList() async {
    return MddQuery(ref.watch(databaseProvider)).retrieveGroupList();
  }

  @override
  FutureOr<List<MddGroupListResult>> build() async {
    return await _fetchSpeciesList();
  }

  Future<void> search(
    String query, {
    required SearchFilter filterBy,
    RuleFilter<SearchFilter> rules = const RuleFilter(),
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      return await MDDSearch(
        ref.read(databaseProvider),
      ).searchTable(query, filterBy: filterBy, rules: rules);
    });
  }
}

/// The species shown by [SpeciesPage]. Each species page overrides it in a
/// nested `ProviderScope` with its own ID, so pages lower in the navigation
/// stack keep their species when another one is opened.
final currentMddIDProvider = NotifierProvider<CurrentMddID, int>(
  () => CurrentMddID(),
  dependencies: const [],
);

class CurrentMddID extends Notifier<int> {
  CurrentMddID([this._initialID = 0]);

  final int _initialID;

  @override
  int build() {
    return _initialID;
  }

  void setMddID(int mddID) {
    state = mddID;
  }
}

final taxonDataProvider = AsyncNotifierProvider<TaxonData, db.TaxonomyData>(
  () => TaxonData(),
  dependencies: [currentMddIDProvider],
);

class TaxonData extends AsyncNotifier<db.TaxonomyData> {
  Future<db.TaxonomyData> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.watch(databaseProvider)).retrieveTaxonData(mddID);
  }

  @override
  FutureOr<db.TaxonomyData> build() async {
    return await _fetch();
  }
}

final synonymDataProvider =
    AsyncNotifierProvider<SynonymData, List<db.SynonymData>>(
      () => SynonymData(),
      dependencies: [currentMddIDProvider],
    );

class SynonymData extends AsyncNotifier<List<db.SynonymData>> {
  Future<List<db.SynonymData>> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(
      ref.watch(databaseProvider),
    ).retrieveSynonymData(mddID);
  }

  @override
  FutureOr<List<db.SynonymData>> build() async {
    return await _fetch();
  }
}

final mainTaxonomyDataProvider =
    FutureProvider.family<List<MainTaxonomyData>, List<int>>((
      ref,
      mddIDList,
    ) async {
      return MddQuery(
        ref.watch(databaseProvider),
      ).retrieveSpeciesList(mddIDList);
    });

final milDataFamilyProvider = FutureProvider.family<List<db.MilDataData>, int>((
  ref,
  mddID,
) async {
  return MddQuery(ref.watch(databaseProvider)).retrieveMilData(mddID);
});

final speciesMilImagesProvider =
    FutureProvider.family<List<RandomMilImagesWithTaxonomyResult>, int>((
      ref,
      mddId,
    ) async {
      return MddQuery(
        ref.watch(databaseProvider),
      ).getMilImagesForSpecies(mddId);
    });

final milDataProvider =
    AsyncNotifierProvider<MilDataNotifier, List<db.MilDataData>>(
      () => MilDataNotifier(),
      dependencies: [currentMddIDProvider],
    );

class MilDataNotifier extends AsyncNotifier<List<db.MilDataData>> {
  Future<List<db.MilDataData>> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.watch(databaseProvider)).retrieveMilData(mddID);
  }

  @override
  FutureOr<List<db.MilDataData>> build() async {
    return await _fetch();
  }
}

final randomMilImagesProvider =
    FutureProvider<List<RandomMilImagesWithTaxonomyResult>>((ref) async {
      return MddQuery(ref.watch(databaseProvider)).getRandomMilImages();
    });

List<Map<String, dynamic>> _parseMilJson(String jsonString) {
  final List<dynamic> parsed = jsonDecode(jsonString);
  final random = Random();
  final list = parsed.cast<Map<String, dynamic>>();
  list.shuffle(random);
  return list.take(20).toList();
}

final milJsonCarouselProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final jsonString = await rootBundle.loadString('assets/data/mil.json');
  return await compute(_parseMilJson, jsonString);
});

final treeSpeciesDataProvider = FutureProvider<Map<int, TreeSpeciesData>>((
  ref,
) async {
  return MddQuery(ref.watch(databaseProvider)).retrieveTreeSpecies();
});

final taxonTreeProvider = FutureProvider<List<TaxonNode>>((ref) async {
  final speciesList = await ref.watch(speciesListProvider.future);
  final speciesData = await ref.watch(treeSpeciesDataProvider.future);
  return buildTaxonTree(speciesList, speciesData);
});

final expandedTaxaProvider = NotifierProvider<ExpandedTaxa, ExpandedTaxaState>(
  () => ExpandedTaxa(),
);

class ExpandedTaxaState {
  const ExpandedTaxaState({this.keys = const {}, this.generation = 0});

  final Set<String> keys;

  /// Bumped on expand/collapse all so list-view tiles rebuild with the new
  /// initial state.
  final int generation;
}

/// Expanded nodes, shared by the list and tree views on the Explore page.
class ExpandedTaxa extends Notifier<ExpandedTaxaState> {
  @override
  ExpandedTaxaState build() => const ExpandedTaxaState();

  void setExpanded(String key, bool isExpanded) {
    final keys = {...state.keys};
    isExpanded ? keys.add(key) : keys.remove(key);
    state = ExpandedTaxaState(keys: keys, generation: state.generation);
  }

  void toggle(String key) => setExpanded(key, !state.keys.contains(key));

  void expandAll(List<TaxonNode> tree) {
    state = ExpandedTaxaState(
      keys: collectParentKeys(tree),
      generation: state.generation + 1,
    );
  }

  void collapseAll() {
    state = ExpandedTaxaState(generation: state.generation + 1);
  }
}

/// Species, tree, and statistics for a higher taxon page.
final higherTaxonProvider = FutureProvider.family<HigherTaxonData, TaxonKey>((
  ref,
  taxon,
) async {
  final rows = await MddQuery(
    ref.watch(databaseProvider),
  ).retrieveSpeciesInTaxon(taxon.rank, taxon.name);
  return HigherTaxonData(taxon: taxon, rows: rows);
});

/// A sample of photos for a higher taxon page, at most one per species
/// until every species with a photo is shown.
final higherTaxonImagesProvider =
    FutureProvider.family<List<RandomMilImagesWithTaxonomyResult>, TaxonKey>((
      ref,
      taxon,
    ) async {
      final data = await ref.watch(higherTaxonProvider(taxon).future);
      return MddQuery(
        ref.watch(databaseProvider),
      ).getMilImagesForSpeciesIds([for (final row in data.rows) row.id]);
    });

/// Living species per country for a higher taxon, as map shapes.
final higherTaxonHeatmapProvider = FutureProvider.autoDispose
    .family<CountryHeatmap, TaxonKey>((ref, taxon) async {
      final data = await ref.watch(higherTaxonProvider(taxon).future);
      final source = await rootBundle.loadString(
        'assets/data/countries.geojson',
      );
      return CountryHeatmap(
        counts: CountrySpeciesCounts.fromRows(data.rows),
        topology: Map<String, dynamic>.from(jsonDecode(source) as Map),
      );
    });

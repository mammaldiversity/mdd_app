import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';

final searchDatabaseProvider =
    AsyncNotifierProvider<SearchDatabase, List<MainTaxonomyData>>(
        () => SearchDatabase());

class SearchDatabase extends AsyncNotifier<List<MainTaxonomyData>> {
  @override
  FutureOr<List<MainTaxonomyData>> build() async {
    return [];
  }

  Future<void> search(String query, {required SearchFilter filterBy}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      return await MDDSearch(ref.read(databaseProvider))
          .searchSpecies(query, filterBy: filterBy);
    });
  }
}

final totalRecordsProvider = FutureProvider<int>((ref) async {
  return await MddQuery(ref.read(databaseProvider)).totalRecords();
});

final speciesListProvider =
    AsyncNotifierProvider<SpeciesList, List<MddGroupListResult>>(
        () => SpeciesList());

class SpeciesList extends AsyncNotifier<List<MddGroupListResult>> {
  Future<List<MddGroupListResult>> _fetchSpeciesList() async {
    return MddQuery(ref.read(databaseProvider)).retrieveGroupList();
  }

  @override
  FutureOr<List<MddGroupListResult>> build() async {
    return await _fetchSpeciesList();
  }

  Future<void> search(String query, {required SearchFilter filterBy}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      return await MDDSearch(ref.read(databaseProvider))
          .searchTable(query, filterBy: filterBy);
    });
  }
}

final currentMddIDProvider =
    NotifierProvider<CurrentMddID, int>(() => CurrentMddID());

class CurrentMddID extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setMddID(int mddID) {
    state = mddID;
  }
}

final taxonDataProvider =
    AsyncNotifierProvider<TaxonData, db.TaxonomyData>(() => TaxonData());

class TaxonData extends AsyncNotifier<db.TaxonomyData> {
  Future<db.TaxonomyData> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.read(databaseProvider)).retrieveTaxonData(mddID);
  }

  @override
  FutureOr<db.TaxonomyData> build() async {
    return await _fetch();
  }
}

final synonymDataProvider =
    AsyncNotifierProvider<SynonymData, List<db.SynonymData>>(
        () => SynonymData());

class SynonymData extends AsyncNotifier<List<db.SynonymData>> {
  Future<List<db.SynonymData>> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.read(databaseProvider))
        .retrieveSynonymData(mddID);
  }

  @override
  FutureOr<List<db.SynonymData>> build() async {
    return await _fetch();
  }
}

final mainTaxonomyDataProvider =
    FutureProvider.family<List<MainTaxonomyData>, List<int>>(
        (ref, mddIDList) async {
  return MddQuery(ref.read(databaseProvider)).retrieveSpeciesList(mddIDList);
});

final milDataFamilyProvider =
    FutureProvider.family<List<db.MilDataData>, int>((ref, mddID) async {
  return MddQuery(ref.read(databaseProvider)).retrieveMilData(mddID);
});

final milDataProvider =
    AsyncNotifierProvider<MilDataNotifier, List<db.MilDataData>>(
        () => MilDataNotifier());

class MilDataNotifier extends AsyncNotifier<List<db.MilDataData>> {
  Future<List<db.MilDataData>> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.read(databaseProvider)).retrieveMilData(mddID);
  }

  @override
  FutureOr<List<db.MilDataData>> build() async {
    return await _fetch();
  }
}

final randomMilImagesProvider = FutureProvider<List<RandomMilImagesWithTaxonomyResult>>((ref) async {
  return MddQuery(ref.read(databaseProvider)).getRandomMilImages();
});

List<Map<String, dynamic>> _parseMilJson(String jsonString) {
  final List<dynamic> parsed = jsonDecode(jsonString);
  final random = Random();
  final list = parsed.cast<Map<String, dynamic>>();
  list.shuffle(random);
  return list.take(20).toList();
}

final milJsonCarouselProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/mil.json');
  return await compute(_parseMilJson, jsonString);
});

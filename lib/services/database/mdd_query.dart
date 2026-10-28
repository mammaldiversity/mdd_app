import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/rule_filter.dart';
import 'package:mdd/services/taxon_tree.dart';

part 'mdd_query.g.dart';

@DriftAccessor(include: {'tables.drift'})
class MddQuery extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MddQuery(super.db);

  String addVersion(String version) {
    return version;
  }

  Future<TaxonomyData> retrieveTaxonData(int mddID) async {
    return await (select(
      taxonomy,
    )..where((tbl) => tbl.id.equals(mddID))).getSingle();
  }

  Future<MddInfoData> retrieveMddInfo() async {
    return await (select(mddInfo).getSingle());
  }

  Future<List<MilDataData>> retrieveMilData(int mddID) async {
    return await (select(
      milData,
    )..where((tbl) => tbl.mddId.equals(mddID))).get();
  }

  Future<List<SynonymData>> retrieveSynonymData(int mddID) async {
    final data = await (select(
      synonym,
    )..where((tbl) => tbl.speciesId.equals(mddID))).get();
    if (kDebugMode) {
      print('Synonym data: $data');
    }
    return data;
  }

  /// Every synonym with only the columns the synonym table shows, sorted by
  /// valid species. Other fields are null; [retrieveSynonymById] has them.
  Future<List<SynonymData>> retrieveSynonymTable() {
    return customSelect(
      'SELECT synId, speciesId, species, rootName, originalCombination, '
      'author, year, validity, nomenclatureStatus, originalRank, '
      'typeCountry, taxonOrder, family, genus, specificEpithet '
      'FROM synonym ORDER BY genus, specificEpithet, year',
      readsFrom: {synonym},
    ).map((row) => synonym.map(row.data)).get();
  }

  Future<SynonymData?> retrieveSynonymById(int synId) {
    return (select(
      synonym,
    )..where((tbl) => tbl.synId.equals(synId))).getSingleOrNull();
  }

  // Count total synonyms
  Future<int> totalSynonyms() async {
    return await (select(synonym)).get().then((value) => value.length);
  }

  Future<List<TaxonomyData>> retrieveTaxonDataList(List<int> mddID) async {
    return await (select(taxonomy)..where((tbl) => tbl.id.isIn(mddID))).get();
  }

  Future<List<SynonymData>> retrieveSynonymDataList(List<int> mddIDs) async {
    return await (select(synonym)
          ..where((tbl) => tbl.speciesId.isIn(mddIDs))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.speciesId)]))
        .get();
  }

  Future<int> totalRecords() async {
    final groupList = await retrieveGroupList();
    return groupList.length;
  }

  Future<List<MainTaxonomyData>> retrieveSpeciesList(List<int> mddID) async {
    List<TaxonomyData> data = await (select(
      taxonomy,
    )..where((tbl) => tbl.id.isIn(mddID))).get();
    // Convert to MainTaxonomyData and order by specific epithet
    final taxonData = data
        .map((e) => MainTaxonomyData.fromTaxonomyData(e))
        .toList();
    return taxonData..sort((a, b) {
      int result = a.genus.compareTo(b.genus);
      if (result == 0) {
        result = a.specificEpithet.compareTo(b.specificEpithet);
      }
      return result;
    });
  }

  Future<List<MddGroupListResult>> retrieveGroupList() async {
    return mddGroupList().get();
  }

  /// Leaf data for the Explore tree view, keyed by MDD ID.
  Future<Map<int, TreeSpeciesData>> retrieveTreeSpecies() async {
    const String query = '''
      SELECT id, genus, specificEpithet, mainCommonName, extinct
      FROM taxonomy
    ''';
    final rows = await customSelect(query, readsFrom: {taxonomy}).get();
    return {
      for (final QueryRow row in rows)
        row.read<int>('id'): TreeSpeciesData(
          id: row.read<int>('id'),
          specificEpithet: row.readNullable<String>('specificEpithet') ?? '',
          mainCommonName: row.readNullable<String>('mainCommonName') ?? '',
          isExtinct: row.readNullable<int>('extinct') == 1,
        ),
    };
  }

  /// Order names in phylogenetic sequence, by each order's lowest
  /// phylosort.
  Future<List<String>> retrieveOrderSequence() {
    return customSelect(
      'SELECT taxonOrder FROM taxonomy '
      'WHERE taxonOrder IS NOT NULL '
      'GROUP BY taxonOrder ORDER BY MIN(phylosort)',
      readsFrom: {taxonomy},
    ).map((row) => row.read<String>('taxonOrder')).get();
  }

  Future<List<RandomMilImagesWithTaxonomyResult>> getRandomMilImages() async {
    return randomMilImagesWithTaxonomy().get();
  }

  Future<List<RandomMilImagesWithTaxonomyResult>> getMilImagesForSpecies(
    int mddId,
  ) async {
    const String query = '''
      SELECT milData.*, taxonomy.genus, taxonomy.specificEpithet, taxonomy.mainCommonName 
      FROM milData 
      INNER JOIN taxonomy ON milData.mddId = taxonomy.id 
      WHERE milData.mddId = ?
      ORDER BY milData.milId ASC
    ''';

    return customSelect(
      query,
      variables: [Variable.withInt(mddId)],
      readsFrom: {milData, taxonomy},
    ).map(_milImageFromRow).get();
  }

  /// Images of any of [mddIds], landscape first, then one image per species
  /// before repeats so a large taxon shows a varied sample.
  Future<List<RandomMilImagesWithTaxonomyResult>> getMilImagesForSpeciesIds(
    List<int> mddIds, {
    int limit = 24,
  }) async {
    if (mddIds.isEmpty) return [];
    final placeholders = List.filled(mddIds.length, '?').join(',');
    final String query =
        '''
      SELECT milData.*, taxonomy.genus, taxonomy.specificEpithet, taxonomy.mainCommonName,
        ROW_NUMBER() OVER (PARTITION BY milData.mddId ORDER BY milData.milId) AS speciesRank
      FROM milData
      INNER JOIN taxonomy ON milData.mddId = taxonomy.id
      WHERE milData.mddId IN ($placeholders)
      ORDER BY speciesRank ASC,
        CASE WHEN milData.orientation = 'landscape' THEN 0 ELSE 1 END ASC,
        taxonomy.phylosort ASC
      LIMIT ?
    ''';

    return customSelect(
      query,
      variables: [...mddIds.map(Variable.withInt), Variable.withInt(limit)],
      readsFrom: {milData, taxonomy},
    ).map(_milImageFromRow).get();
  }

  RandomMilImagesWithTaxonomyResult _milImageFromRow(QueryRow row) {
    return RandomMilImagesWithTaxonomyResult(
      milId: row.read<String>('milId'),
      mddId: row.read<int>('mddId'),
      description: row.readNullable<String>('description'),
      photographer: row.readNullable<String>('photographer'),
      location: row.readNullable<String>('location'),
      distribution: row.readNullable<String>('distribution'),
      dateTaken: row.readNullable<String>('dateTaken'),
      orientation: row.readNullable<String>('orientation'),
      isUncertainIdentification: row.readNullable<int>(
        'isUncertainIdentification',
      ),
      genus: row.readNullable<String>('genus'),
      specificEpithet: row.readNullable<String>('specificEpithet'),
      mainCommonName: row.readNullable<String>('mainCommonName'),
    );
  }

  /// Every species in the taxon [name] at [rank] (exact match), in
  /// phylogenetic order.
  Future<List<TaxonomyData>> retrieveSpeciesInTaxon(
    TaxonRank rank,
    String name,
  ) async {
    return (select(taxonomy)
          ..where((tbl) => _rankColumn(tbl, rank).equals(name))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.phylosort)]))
        .get();
  }

  GeneratedColumn<String> _rankColumn(Taxonomy tbl, TaxonRank rank) {
    switch (rank) {
      case TaxonRank.subclass:
        return tbl.subclass;
      case TaxonRank.infraclass:
        return tbl.infraclass;
      case TaxonRank.magnorder:
        return tbl.magnorder;
      case TaxonRank.superorder:
        return tbl.superorder;
      case TaxonRank.order:
        return tbl.taxonOrder;
      case TaxonRank.suborder:
        return tbl.suborder;
      case TaxonRank.infraorder:
        return tbl.infraorder;
      case TaxonRank.parvorder:
        return tbl.parvorder;
      case TaxonRank.superfamily:
        return tbl.superfamily;
      case TaxonRank.family:
        return tbl.family;
      case TaxonRank.subfamily:
        return tbl.subfamily;
      case TaxonRank.tribe:
        return tbl.tribe;
      case TaxonRank.genus:
        return tbl.genus;
      case TaxonRank.subgenus:
        return tbl.subgenus;
      case TaxonRank.species:
        return tbl.sciName;
    }
  }

  Future<List<RandomMilImagesWithTaxonomyResult>> getMilImagesPaginated({
    required int limit,
    required int offset,
    String? searchQuery,
  }) async {
    String query = '''
      SELECT milData.*, taxonomy.genus, taxonomy.specificEpithet, taxonomy.mainCommonName 
      FROM milData 
      INNER JOIN taxonomy ON milData.mddId = taxonomy.id 
    ''';
    List<Variable> variables = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim();
      final queryWithUnderscore = cleanQuery.replaceAll(' ', '_');
      query += '''
        WHERE taxonomy.genus LIKE ? 
           OR taxonomy.specificEpithet LIKE ? 
           OR taxonomy.sciName LIKE ? 
           OR taxonomy.mainCommonName LIKE ? 
           OR milData.photographer LIKE ? 
           OR milData.location LIKE ? 
           OR milData.description LIKE ?
      ''';
      final pattern = '%$cleanQuery%';
      final sciPattern = '%$queryWithUnderscore%';
      variables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(sciPattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }

    query +=
        ' ORDER BY taxonomy.genus ASC, taxonomy.specificEpithet ASC LIMIT ? OFFSET ?';
    variables.add(Variable.withInt(limit));
    variables.add(Variable.withInt(offset));

    return customSelect(
          query,
          variables: variables,
          readsFrom: {milData, taxonomy},
        )
        .map(
          (QueryRow row) => RandomMilImagesWithTaxonomyResult(
            milId: row.read<String>('milId'),
            mddId: row.read<int>('mddId'),
            description: row.readNullable<String>('description'),
            photographer: row.readNullable<String>('photographer'),
            location: row.readNullable<String>('location'),
            distribution: row.readNullable<String>('distribution'),
            dateTaken: row.readNullable<String>('dateTaken'),
            orientation: row.readNullable<String>('orientation'),
            isUncertainIdentification: row.readNullable<int>(
              'isUncertainIdentification',
            ),
            genus: row.readNullable<String>('genus'),
            specificEpithet: row.readNullable<String>('specificEpithet'),
            mainCommonName: row.readNullable<String>('mainCommonName'),
          ),
        )
        .get();
  }

  Future<int> getMilImagesCount({String? searchQuery}) async {
    String query = '''
      SELECT COUNT(*) AS count 
      FROM milData 
      INNER JOIN taxonomy ON milData.mddId = taxonomy.id 
    ''';
    List<Variable> variables = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim();
      final queryWithUnderscore = cleanQuery.replaceAll(' ', '_');
      query += '''
        WHERE taxonomy.genus LIKE ? 
           OR taxonomy.specificEpithet LIKE ? 
           OR taxonomy.sciName LIKE ? 
           OR taxonomy.mainCommonName LIKE ? 
           OR milData.photographer LIKE ? 
           OR milData.location LIKE ? 
           OR milData.description LIKE ?
      ''';
      final pattern = '%$cleanQuery%';
      final sciPattern = '%$queryWithUnderscore%';
      variables.addAll([
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(sciPattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable.withString(pattern),
      ]);
    }

    final result = await customSelect(
      query,
      variables: variables,
      readsFrom: {milData, taxonomy},
    ).map((row) => row.read<int>('count')).getSingle();
    return result;
  }

  Future<List<TaxonomyData>> getTaxonomyForCountryStats() async {
    return (select(taxonomy)..where(
          (tbl) =>
              tbl.countryDistribution.isNotNull() &
              tbl.countryDistribution.isNotValue(''),
        ))
        .get();
  }
}

enum SearchFilter {
  all,
  // Taxonomy
  order,
  family,
  genus,
  species,
  commonName,
  authority,
  countryDistribution,
  typeLocality,

  // Synonym
  synonymRootName,
  synonymOriginalCombination,
  synonymAuthorYear,
  synonymTypeLocality,

  // MilData
  milDataDescription,
  milDataPhotographer,
  milDataLocation,
}

enum FilterGroup { general, taxonomy, synonym, milData }

extension SearchFilterExtension on SearchFilter {
  FilterGroup get group {
    switch (this) {
      case SearchFilter.all:
        return FilterGroup.general;
      case SearchFilter.order:
      case SearchFilter.family:
      case SearchFilter.genus:
      case SearchFilter.species:
      case SearchFilter.commonName:
      case SearchFilter.authority:
      case SearchFilter.countryDistribution:
      case SearchFilter.typeLocality:
        return FilterGroup.taxonomy;
      case SearchFilter.synonymRootName:
      case SearchFilter.synonymOriginalCombination:
      case SearchFilter.synonymAuthorYear:
      case SearchFilter.synonymTypeLocality:
        return FilterGroup.synonym;
      case SearchFilter.milDataDescription:
      case SearchFilter.milDataPhotographer:
      case SearchFilter.milDataLocation:
        return FilterGroup.milData;
    }
  }

  String get displayName {
    switch (this) {
      case SearchFilter.all:
        return 'All Fields';
      case SearchFilter.order:
        return 'Order';
      case SearchFilter.family:
        return 'Family';
      case SearchFilter.genus:
        return 'Genus';
      case SearchFilter.species:
        return 'Species';
      case SearchFilter.commonName:
        return 'Common Name';
      case SearchFilter.authority:
        return 'Authority & Year';
      case SearchFilter.countryDistribution:
        return 'Country Distribution';
      case SearchFilter.typeLocality:
        return 'Type Locality';
      case SearchFilter.synonymRootName:
        return 'Root Name';
      case SearchFilter.synonymOriginalCombination:
        return 'Original Combination';
      case SearchFilter.synonymAuthorYear:
        return 'Author & Year';
      case SearchFilter.synonymTypeLocality:
        return 'Type Locality';
      case SearchFilter.milDataDescription:
        return 'Description';
      case SearchFilter.milDataPhotographer:
        return 'Photographer';
      case SearchFilter.milDataLocation:
        return 'Location';
    }
  }
}

class MDDSearch extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MDDSearch(super.db);

  /// Search and return species data
  Future<List<MainTaxonomyData>> searchSpecies(
    String rawQuery, {
    required SearchFilter filterBy,
    RuleFilter<SearchFilter> rules = const RuleFilter(),
  }) async {
    final results = await _searchWithRules(rawQuery, filterBy, rules);
    final data =
        results.map((e) => MainTaxonomyData.fromTaxonomyData(e)).toList()
          ..sort((a, b) {
            int result = a.genus.compareTo(b.genus);
            if (result == 0) {
              result = a.specificEpithet.compareTo(b.specificEpithet);
            }
            return result;
          });
    return data;
  }

  /// Search the table for a query
  /// Returns a list of IDs
  Future<List<MddGroupListResult>> searchTable(
    String rawQuery, {
    required SearchFilter filterBy,
    RuleFilter<SearchFilter> rules = const RuleFilter(),
  }) async {
    // Search all columns for the query
    final results = await _searchWithRules(rawQuery, filterBy, rules);
    final data = results
        .map(
          (e) => MddGroupListResult(
            id: e.id,
            family: e.family,
            taxonOrder: e.taxonOrder,
            genus: e.genus,
          ),
        )
        .toList();
    return data;
  }

  /// Narrows the simple search to species that pass [rules]. With an empty
  /// query, the rules alone decide the results.
  Future<List<TaxonomyData>> _searchWithRules(
    String rawQuery,
    SearchFilter filterBy,
    RuleFilter<SearchFilter> rules,
  ) async {
    if (!rules.isActive) return _search(rawQuery, filterBy);
    final ids = await _ruleMatchIds(rules);
    final results = rawQuery.isEmpty
        ? await select(taxonomy).get()
        : await _search(rawQuery, filterBy);
    return results.where((e) => ids.contains(e.id)).toList();
  }

  Future<Set<int>> _ruleMatchIds(RuleFilter<SearchFilter> rules) async {
    Set<int>? allIds;
    Set<int>? combined;
    for (final rule in rules.activeRules) {
      var value = rule.value.trim();
      if (_usesUnderscores(rule.field)) value = value.replaceAll(' ', '_');
      var ids = await _fieldMatchIds(
        rule.field,
        likePattern(rule.operator, value),
      );
      // A species fails a negated rule when any of its records match, so
      // synonyms and images count as one value per species.
      if (rule.operator.isNegated) {
        allIds ??= await _idsWhere(taxonomy, taxonomy.id, const Constant(true));
        ids = allIds.difference(ids);
      }
      combined = combined == null
          ? ids
          : rules.match == RuleMatch.all
          ? combined.intersection(ids)
          : combined.union(ids);
    }
    return combined ?? {};
  }

  /// Scientific names and original combinations store spaces as
  /// underscores.
  bool _usesUnderscores(SearchFilter field) =>
      field == SearchFilter.all ||
      field == SearchFilter.species ||
      field == SearchFilter.synonymOriginalCombination;

  /// Species IDs with any of [field]'s columns matching the LIKE [pattern].
  Future<Set<int>> _fieldMatchIds(SearchFilter field, String pattern) {
    Expression<bool> anyLike(List<GeneratedColumn<String>> columns) =>
        columns.map((c) => c.like(pattern)).reduce((a, b) => a | b);

    switch (field.group) {
      case FilterGroup.general:
      case FilterGroup.taxonomy:
        return _idsWhere(
          taxonomy,
          taxonomy.id,
          anyLike(_taxonomyRuleColumns(field)),
        );
      case FilterGroup.synonym:
        final columns = switch (field) {
          SearchFilter.synonymRootName => [synonym.rootName],
          SearchFilter.synonymOriginalCombination => [
            synonym.originalCombination,
          ],
          SearchFilter.synonymAuthorYear => [synonym.author, synonym.year],
          _ => [synonym.oldTypeLocality, synonym.originalTypeLocality],
        };
        return _idsWhere(synonym, synonym.speciesId, anyLike(columns));
      case FilterGroup.milData:
        final columns = switch (field) {
          SearchFilter.milDataDescription => [milData.description],
          SearchFilter.milDataPhotographer => [milData.photographer],
          _ => [milData.location],
        };
        return _idsWhere(milData, milData.mddId, anyLike(columns));
    }
  }

  List<GeneratedColumn<String>> _taxonomyRuleColumns(SearchFilter field) {
    switch (field) {
      case SearchFilter.order:
        return [taxonomy.taxonOrder];
      case SearchFilter.family:
        return [taxonomy.family];
      case SearchFilter.genus:
        return [taxonomy.genus];
      case SearchFilter.species:
        return [taxonomy.sciName];
      case SearchFilter.commonName:
        return [taxonomy.mainCommonName, taxonomy.otherCommonNames];
      case SearchFilter.authority:
        return [taxonomy.authoritySpeciesAuthor];
      case SearchFilter.countryDistribution:
        return [taxonomy.countryDistribution];
      case SearchFilter.typeLocality:
        return [taxonomy.typeLocality];
      default:
        // Same columns as the simple "All Fields" search.
        return [
          taxonomy.family,
          taxonomy.taxonOrder,
          taxonomy.genus,
          taxonomy.specificEpithet,
          taxonomy.sciName,
          taxonomy.originalNameCombination,
          taxonomy.mainCommonName,
          taxonomy.otherCommonNames,
          taxonomy.countryDistribution,
          taxonomy.authoritySpeciesAuthor,
          taxonomy.distributionNotes,
          taxonomy.typeLocality,
        ];
    }
  }

  Future<Set<int>> _idsWhere(
    TableInfo table,
    GeneratedColumn<int> idColumn,
    Expression<bool> where,
  ) async {
    final query = selectOnly(table)
      ..addColumns([idColumn])
      ..where(where);
    final ids = await query.map((row) => row.read(idColumn)).get();
    return ids.whereType<int>().toSet();
  }

  Future<List<TaxonomyData>> _search(
    String rawQuery,
    SearchFilter filterBy,
  ) async {
    switch (filterBy) {
      case SearchFilter.all:
        return _searchAll(rawQuery);
      case SearchFilter.order:
        return (select(
          taxonomy,
        )..where((tbl) => tbl.taxonOrder.like('%$rawQuery%'))).get();
      case SearchFilter.family:
        return _searchByFamily(rawQuery);
      case SearchFilter.genus:
        return _searchByGenus(rawQuery);
      case SearchFilter.species:
        return _searchBySpecies(rawQuery);
      case SearchFilter.commonName:
        return (select(taxonomy)..where(
              (tbl) =>
                  tbl.mainCommonName.like('%$rawQuery%') |
                  tbl.otherCommonNames.like('%$rawQuery%'),
            ))
            .get();
      case SearchFilter.authority:
        return (select(taxonomy)
              ..where((tbl) => tbl.authoritySpeciesAuthor.like('%$rawQuery%')))
            .get();
      case SearchFilter.countryDistribution:
        return _searchByCountry(rawQuery);
      case SearchFilter.typeLocality:
        return (select(
          taxonomy,
        )..where((tbl) => tbl.typeLocality.like('%$rawQuery%'))).get();

      // Synonym searches
      case SearchFilter.synonymRootName:
        return _queryTaxonomyFromSynonymIds(
          await (select(
            synonym,
          )..where((tbl) => tbl.rootName.like('%$rawQuery%'))).get(),
        );
      case SearchFilter.synonymOriginalCombination:
        final queryWithUnderscore = rawQuery.replaceAll(' ', '_');
        return _queryTaxonomyFromSynonymIds(
          await (select(synonym)..where(
                (tbl) =>
                    tbl.originalCombination.like('%$rawQuery%') |
                    tbl.originalCombination.like('%$queryWithUnderscore%'),
              ))
              .get(),
        );
      case SearchFilter.synonymAuthorYear:
        return _queryTaxonomyFromSynonymIds(
          await (select(synonym)..where(
                (tbl) =>
                    tbl.author.like('%$rawQuery%') |
                    tbl.year.like('%$rawQuery%'),
              ))
              .get(),
        );
      case SearchFilter.synonymTypeLocality:
        return _queryTaxonomyFromSynonymIds(
          await (select(synonym)..where(
                (tbl) =>
                    tbl.oldTypeLocality.like('%$rawQuery%') |
                    tbl.originalTypeLocality.like('%$rawQuery%'),
              ))
              .get(),
        );

      // MilData searches
      case SearchFilter.milDataDescription:
        return _queryTaxonomyFromMilDataIds(
          await (select(
            milData,
          )..where((tbl) => tbl.description.like('%$rawQuery%'))).get(),
        );
      case SearchFilter.milDataPhotographer:
        return _queryTaxonomyFromMilDataIds(
          await (select(
            milData,
          )..where((tbl) => tbl.photographer.like('%$rawQuery%'))).get(),
        );
      case SearchFilter.milDataLocation:
        return _queryTaxonomyFromMilDataIds(
          await (select(
            milData,
          )..where((tbl) => tbl.location.like('%$rawQuery%'))).get(),
        );
    }
  }

  Future<List<TaxonomyData>> _queryTaxonomyFromSynonymIds(
    List<SynonymData> syns,
  ) async {
    final ids = syns.map((e) => e.speciesId).whereType<int>().toSet().toList();
    if (ids.isEmpty) return [];
    return (select(taxonomy)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<List<TaxonomyData>> _queryTaxonomyFromMilDataIds(
    List<MilDataData> mils,
  ) async {
    final ids = mils.map((e) => e.mddId).whereType<int>().toSet().toList();
    if (ids.isEmpty) return [];
    return (select(taxonomy)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<List<TaxonomyData>> _searchAll(String query) {
    final queryWithUnderscore = query.replaceAll(' ', '_');
    return (select(taxonomy)..where(
          (tbl) =>
              tbl.family.like('%$query%') |
              tbl.taxonOrder.like('%$query%') |
              tbl.genus.like('%$query%') |
              tbl.specificEpithet.like('%$query%') |
              tbl.sciName.like('%$queryWithUnderscore%') |
              tbl.originalNameCombination.like('%$queryWithUnderscore%') |
              tbl.mainCommonName.like('%$query%') |
              tbl.otherCommonNames.like('%$query%') |
              tbl.countryDistribution.like('%$query%') |
              tbl.authoritySpeciesAuthor.like('%$query%') |
              tbl.distributionNotes.like('%$query%') |
              tbl.typeLocality.like('%$query%'),
        ))
        .get();
  }

  Future<List<TaxonomyData>> _searchByFamily(String rawQuery) {
    return (select(
      taxonomy,
    )..where((tbl) => tbl.family.like('%$rawQuery%'))).get();
  }

  Future<List<TaxonomyData>> _searchByGenus(String rawQuery) {
    return (select(
      taxonomy,
    )..where((tbl) => tbl.genus.like('%$rawQuery%'))).get();
  }

  Future<List<TaxonomyData>> _searchBySpecies(String rawQuery) {
    final query = rawQuery.replaceAll(' ', '_');
    return (select(
      taxonomy,
    )..where((tbl) => tbl.sciName.like('%$query%'))).get();
  }

  Future<List<TaxonomyData>> _searchByCountry(String rawQuery) async {
    return (select(
      taxonomy,
    )..where((tbl) => tbl.countryDistribution.like('%$rawQuery%'))).get();
  }
}

class MainTaxonomyData {
  const MainTaxonomyData({
    required this.id,
    required this.genus,
    required this.specificEpithet,
    required this.mainCommonName,
  });

  final int id;
  final String genus;
  final String specificEpithet;
  final String mainCommonName;

  factory MainTaxonomyData.fromTaxonomyData(TaxonomyData data) {
    return MainTaxonomyData(
      id: data.id,
      genus: data.genus ?? '',
      specificEpithet: data.specificEpithet ?? '',
      mainCommonName: data.mainCommonName ?? '',
    );
  }
}

class TreeSpeciesData {
  const TreeSpeciesData({
    required this.id,
    required this.specificEpithet,
    required this.mainCommonName,
    required this.isExtinct,
  });

  final int id;
  final String specificEpithet;
  final String mainCommonName;
  final bool isExtinct;
}

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mdd/services/database/database.dart';

part 'mdd_query.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class MddQuery extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MddQuery(super.db);

  String addVersion(String version) {
    return version;
  }

  Future<TaxonomyData> retrieveTaxonData(int mddID) async {
    return await (select(taxonomy)..where((tbl) => tbl.id.equals(mddID)))
        .getSingle();
  }

  Future<MddInfoData> retrieveMddInfo() async {
    return await (select(mddInfo).getSingle());
  }

  Future<List<MilDataData>> retrieveMilData(int mddID) async {
    return await (select(milData)..where((tbl) => tbl.mddId.equals(mddID))).get();
  }

  Future<List<SynonymData>> retrieveSynonymData(int mddID) async {
    final data = await (select(synonym)
          ..where((tbl) => tbl.speciesId.equals(mddID)))
        .get();
    if (kDebugMode) {
      print('Synonym data: $data');
    }
    return data;
  }

  // Count total synonyms
  Future<int> totalSynonyms() async {
    return await (select(synonym)).get().then((value) => value.length);
  }

  Future<List<TaxonomyData>> retrieveTaxonDataList(List<int> mddID) async {
    return await (select(taxonomy)..where((tbl) => tbl.id.isIn(mddID))).get();
  }

  Future<int> totalRecords() async {
    final groupList = await retrieveGroupList();
    return groupList.length;
  }

  Future<List<MainTaxonomyData>> retrieveSpeciesList(List<int> mddID) async {
    List<TaxonomyData> data =
        await (select(taxonomy)..where((tbl) => tbl.id.isIn(mddID))).get();
    // Convert to MainTaxonomyData and order by specific epithet
    final taxonData =
        data.map((e) => MainTaxonomyData.fromTaxonomyData(e)).toList();
    return taxonData
      ..sort((a, b) {
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

  Future<List<RandomMilImagesWithTaxonomyResult>> getRandomMilImages() async {
    return randomMilImagesWithTaxonomy().get();
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
  Future<List<MainTaxonomyData>> searchSpecies(String rawQuery,
      {required SearchFilter filterBy}) async {
    final results = await _search(rawQuery, filterBy);
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
  Future<List<MddGroupListResult>> searchTable(String rawQuery,
      {required SearchFilter filterBy}) async {
    // Search all columns for the query
    final results = await _search(rawQuery, filterBy);
    final data = results
        .map((e) => MddGroupListResult(
              id: e.id,
              family: e.family,
              taxonOrder: e.taxonOrder,
              genus: e.genus,
            ))
        .toList();
    return data;
  }

  Future<List<TaxonomyData>> _search(String rawQuery, SearchFilter filterBy) async {
    switch (filterBy) {
      case SearchFilter.all:
        return _searchAll(rawQuery);
      case SearchFilter.order:
        return (select(taxonomy)..where((tbl) => tbl.taxonOrder.like('%$rawQuery%'))).get();
      case SearchFilter.family:
        return _searchByFamily(rawQuery);
      case SearchFilter.genus:
        return _searchByGenus(rawQuery);
      case SearchFilter.species:
        return _searchBySpecies(rawQuery);
      case SearchFilter.commonName:
        return (select(taxonomy)..where((tbl) => tbl.mainCommonName.like('%$rawQuery%') | tbl.otherCommonNames.like('%$rawQuery%'))).get();
      case SearchFilter.authority:
        return (select(taxonomy)..where((tbl) => tbl.authoritySpeciesAuthor.like('%$rawQuery%'))).get();
      case SearchFilter.countryDistribution:
        return _searchByCountry(rawQuery);
      
      // Synonym searches
      case SearchFilter.synonymRootName:
        return _queryTaxonomyFromSynonymIds(
            await (select(synonym)..where((tbl) => tbl.rootName.like('%$rawQuery%'))).get());
      case SearchFilter.synonymOriginalCombination:
        final queryWithUnderscore = rawQuery.replaceAll(' ', '_');
        return _queryTaxonomyFromSynonymIds(
            await (select(synonym)..where((tbl) => tbl.originalCombination.like('%$rawQuery%') | tbl.originalCombination.like('%$queryWithUnderscore%'))).get());
      case SearchFilter.synonymAuthorYear:
        return _queryTaxonomyFromSynonymIds(
            await (select(synonym)..where((tbl) => tbl.author.like('%$rawQuery%') | tbl.year.like('%$rawQuery%'))).get());
      case SearchFilter.synonymTypeLocality:
        return _queryTaxonomyFromSynonymIds(
            await (select(synonym)..where((tbl) => tbl.oldTypeLocality.like('%$rawQuery%') | tbl.originalTypeLocality.like('%$rawQuery%'))).get());

      // MilData searches
      case SearchFilter.milDataDescription:
        return _queryTaxonomyFromMilDataIds(
            await (select(milData)..where((tbl) => tbl.description.like('%$rawQuery%'))).get());
      case SearchFilter.milDataPhotographer:
        return _queryTaxonomyFromMilDataIds(
            await (select(milData)..where((tbl) => tbl.photographer.like('%$rawQuery%'))).get());
      case SearchFilter.milDataLocation:
        return _queryTaxonomyFromMilDataIds(
            await (select(milData)..where((tbl) => tbl.location.like('%$rawQuery%'))).get());
    }
  }

  Future<List<TaxonomyData>> _queryTaxonomyFromSynonymIds(List<SynonymData> syns) async {
    final ids = syns.map((e) => e.speciesId).whereType<int>().toSet().toList();
    if (ids.isEmpty) return [];
    return (select(taxonomy)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<List<TaxonomyData>> _queryTaxonomyFromMilDataIds(List<MilDataData> mils) async {
    final ids = mils.map((e) => e.mddId).whereType<int>().toSet().toList();
    if (ids.isEmpty) return [];
    return (select(taxonomy)..where((tbl) => tbl.id.isIn(ids))).get();
  }

  Future<List<TaxonomyData>> _searchAll(String query) {
    final queryWithUnderscore = query.replaceAll(' ', '_');
    return (select(taxonomy)
          ..where(
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
                tbl.distributionNotes.like('%$query%'),
          ))
        .get();
  }

  Future<List<TaxonomyData>> _searchByFamily(String rawQuery) {
    return (select(taxonomy)..where((tbl) => tbl.family.like('%$rawQuery%')))
        .get();
  }

  Future<List<TaxonomyData>> _searchByGenus(String rawQuery) {
    return (select(taxonomy)..where((tbl) => tbl.genus.like('%$rawQuery%')))
        .get();
  }

  Future<List<TaxonomyData>> _searchBySpecies(String rawQuery) {
    final query = rawQuery.replaceAll(' ', '_');
    return (select(taxonomy)..where((tbl) => tbl.sciName.like('%$query%')))
        .get();
  }

  Future<List<TaxonomyData>> _searchByCountry(String rawQuery) async {
    return (select(taxonomy)
          ..where((tbl) => tbl.countryDistribution.like('%$rawQuery%')))
        .get();
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

import 'package:drift/drift.dart';
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

  Future<SynonymData> retrieveSynonymData(int mddID) async {
    return await (select(synonym)..where((tbl) => tbl.speciesId.equals(mddID)))
        .getSingle();
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
        return a.specificEpithet.compareTo(b.specificEpithet);
      });
  }

  Future<List<MddGroupListResult>> retrieveGroupList() async {
    return mddGroupList().get();
  }
}

enum SearchFilter { all, family, genus, species, countryDistribution }

class MDDSearch extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MDDSearch(super.db);

  /// Search and return species data
  Future<List<MainTaxonomyData>> searchSpecies(String rawQuery,
      {required SearchFilter filterBy}) async {
    final results = await _search(rawQuery, filterBy);
    final data =
        results.map((e) => MainTaxonomyData.fromTaxonomyData(e)).toList()
          ..sort((a, b) {
            return a.specificEpithet.compareTo(b.specificEpithet);
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

  Future<List<TaxonomyData>> _search(String rawQuery, SearchFilter filterBy) {
    switch (filterBy) {
      case SearchFilter.all:
        return _searchAll(rawQuery);
      case SearchFilter.family:
        return _searchByFamily(rawQuery);
      case SearchFilter.genus:
        return _searchByGenus(rawQuery);
      case SearchFilter.species:
        return _searchBySpecies(rawQuery);
      case SearchFilter.countryDistribution:
        return _searchByCountry(rawQuery);
    }
  }

  Future<List<TaxonomyData>> _searchAll(String query) {
    return (select(taxonomy)
          ..where(
            (tbl) =>
                tbl.family.like('%$query%') |
                tbl.taxonOrder.like('%$query%') |
                tbl.genus.like('%$query%') |
                tbl.specificEpithet.like('%$query%') |
                tbl.sciName.like('%$query%') |
                tbl.originalNameCombination.like('%$query%') |
                tbl.specificEpithet.like('%$query%') |
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

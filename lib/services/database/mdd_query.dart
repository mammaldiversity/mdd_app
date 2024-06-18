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

  /// Search the table for a query
  /// Returns a list of IDs
  Future<List<MddGroupListResult>> searchTable(String rawQuery) async {
    final query = rawQuery.replaceAll(' ', '_');
    // Search all columns for the query
    final results = await (select(taxonomy)
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

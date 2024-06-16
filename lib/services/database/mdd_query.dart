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

  Future<void> insertMdd(TaxonomyCompanion content) {
    return into(taxonomy).insert(content);
  }

  Future<List<MainTaxonomyData>> retrieveSpeciesList(List<int> mddID) async {
    List<TaxonomyData> data =
        await (select(taxonomy)..where((tbl) => tbl.id.isIn(mddID))).get();
    return data.map((e) => MainTaxonomyData.fromTaxonomyData(e)).toList();
  }

  Future<List<MddGroupListResult>> retrieveGroupList() async {
    return mddGroupList().get();
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

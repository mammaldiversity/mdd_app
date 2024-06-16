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
}

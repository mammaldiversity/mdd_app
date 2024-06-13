import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:test_mdd/services/database/database.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'mdd_query.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class MddQuery extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MddQuery(super.db);

  Future<void> createMdd() async {
    final String mddData =
        await rootBundle.loadString('assets/mdd_data/data.csv');

    if (kDebugMode) {
      print('Mdd data: $mddData');
    }
  }

  Future<void> insertMdd(TaxonomyCompanion content) {
    return into(taxonomy).insert(content);
  }
}

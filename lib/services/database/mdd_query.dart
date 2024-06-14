import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mdd/services/database/database.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mdd/src/rust/api/parser.dart';

part 'mdd_query.g.dart';

@DriftAccessor(
  include: {'tables.drift'},
)
class MddQuery extends DatabaseAccessor<AppDatabase> with _$MddQueryMixin {
  MddQuery(super.db);

  Future<void> createMdd(String version) async {
    final String mddData =
        await rootBundle.loadString('assets/mdd_data/data.csv');
    final dataString = await parseCsvToJson(csvData: mddData);
    final Map<String, dynamic> dataJson = json.decode(dataString);
    TaxonomyData data = TaxonomyData.fromJson(dataJson);
    await into(taxonomy).insert(data);
  }

  String addVersion(String version) {
    return version;
  }

  Future<void> insertMdd(TaxonomyCompanion content) {
    return into(taxonomy).insert(content);
  }
}

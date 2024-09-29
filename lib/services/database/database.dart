//! Main database module

import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mdd/src/rust/api/parser.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/services/app_services.dart';

part 'database.g.dart';

const int _kDatabaseVersion = 1;
const String mddVersion = '1.2.1';

@DriftDatabase(
  include: {'tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => _kDatabaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await createMddDefault(mddVersion);
        },
      );

  Future<void> createMddDefault(String version) async {
    final String mddData =
        await rootBundle.loadString('assets/mdd_data/data.csv');
    final MddInfoCompanion dbData = MddInfoCompanion.insert(
      version: Value(version),
    );
    final List<String> dataString = await parseCsvToJson(csvData: mddData);
    for (var jason in dataString) {
      final Map<String, dynamic> dataJson = json.decode(jason);
      if (kDebugMode) print('Data JSON: $dataJson');
      TaxonomyData data = TaxonomyData.fromJson(dataJson);
      await into(mddInfo).insert(dbData);
      await into(taxonomy).insert(data);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await dBPath;
    if (kDebugMode) {
      print('App database path: ${file.path}');
    }
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

Future<File> get dBPath async {
  final Directory appDocDir = await getAppDir();
  final dbPath = path.join(appDocDir.path, 'mdd.db');
  final dbFile = File(dbPath);
  if (dbFile.existsSync()) {
    await dbFile.delete();
    await dbFile.create(recursive: true);
  } else {
    await dbFile.create(recursive: true);
  }
  return dbFile;
}

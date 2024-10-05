//! Main database module

import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/src/rust/api/parser.dart';
import 'package:mdd/services/app_services.dart';

part 'database.g.dart';

const int _kDatabaseVersion = 1;
const String mddVersion = '1.13';

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
    final mddData = await rootBundle.load('assets/data/data.json.gz');
    final buffer = mddData.buffer.asUint8List();
    final MddInfoCompanion dbData = MddInfoCompanion.insert(
      version: Value(version),
    );
    final (List<String>, List<String>) data =
        await MddHelper(data: buffer).getData();

    for (var value in data.$1) {
      final Map<String, dynamic> dataJson = json.decode(value);
      TaxonomyData data = TaxonomyData.fromJson(dataJson);
      await into(mddInfo).insert(dbData);
      await into(taxonomy).insert(data);
    }

    for (var value in data.$2) {
      final Map<String, dynamic> dataJson = json.decode(value);

      SynonymData data = SynonymData.fromJson(dataJson);
      await into(synonym).insert(data);
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
  // if (dbFile.existsSync()) {
  //   await dbFile.delete();
  //   await dbFile.create(recursive: true);
  // } else {
  //   await dbFile.create(recursive: true);
  // }
  return dbFile;
}

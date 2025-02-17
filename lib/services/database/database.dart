//! Main database module

import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:mdd/services/database/model.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/src/rust/api/parser.dart';
import 'package:mdd/services/app_services.dart';

part 'database.g.dart';

const int _kDatabaseVersion = 2;

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
          await createMddDefault();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.createAll();
            await createMddDefault();
          }
        },
      );

  Future<void> createMddDefault() async {
    final mddData = await rootBundle.load('assets/data/data.json.gz');
    final buffer = mddData.buffer.asUint8List();
    final MddHelper data = await MddHelper.parse(bytes: buffer);
    await _updateMddInfo(data.version, data.releaseDate);
    for (var dataString in data.mddData) {
      if (kDebugMode) {
        print('Decoding data: $dataString');
      }
      final MddData decodedData = MddData.fromJson(json.decode(dataString));
      await _updateMdd(decodedData.speciesData);
      await _updateSynData(decodedData.synonyms);
    }
    final synonyms = List<SynonymData>.from(data.synData.map((data) {
      SynonymData.fromJson(json.decode(data));
    }));
    await _updateSynData(synonyms);
  }

  Future<void> _updateMddInfo(String version, String releaseDate) async {
    final MddInfoCompanion data = MddInfoCompanion(
      version: Value(version),
      releaseDate: Value(releaseDate),
    );
    await into(mddInfo).insert(data);
  }

  Future<void> _updateMdd(TaxonomyData data) async {
    // final Map<String, dynamic> dataJson = json.decode(mddData);
    // TaxonomyData data = TaxonomyData.fromJson(dataJson);
    await into(taxonomy).insert(data);
  }

  Future<void> _updateSynData(List<SynonymData> data) async {
    for (var value in data) {
      // final Map<String, dynamic> dataJson = json.decode(value);
      // SynonymData data = SynonymData.fromJson(dataJson);
      await into(synonym).insert(value);
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
    // delete the database file
    await dbFile.delete();
  }
  return dbFile;
}

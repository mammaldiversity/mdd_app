//! Main database module

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/services/app_services.dart';

part 'database.g.dart';

const int _kDatabaseVersion = 1;

@DriftDatabase(
  include: {'tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => _kDatabaseVersion;
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
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final dbPath = path.join(appDocDir.path, appDataDirName, 'mdd.db');
  final dbFile = File(dbPath);
  if (!dbFile.existsSync()) {
    await dbFile.create(recursive: true);
  }
  return dbFile;
}

//! Main database module

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/services/app_services.dart';

part 'database.g.dart';

const int _kDatabaseVersion = 3;

@DriftDatabase(
  include: {'tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forFile(File file) : super(NativeDatabase.createInBackground(file, logStatements: true));

  @override
  int get schemaVersion => _kDatabaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          // Pre-generated database should already have all tables and data.
          // This onCreate will only be called if the database file didn't exist.
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Add upgrade logic here if needed
        },
      );

  // Removed createMddDefault and createMilData since they are now in generate_db.dart
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await dBPath;
    if (kDebugMode) {
      print('App database path: ${file.path}');
    }
    
    if (!await file.exists()) {
      if (kDebugMode) {
        print('Database not found. Copying from assets/data/mdd.db...');
      }
      try {
        final byteData = await rootBundle.load('assets/data/mdd.db');
        final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
        await file.writeAsBytes(bytes, flush: true);
        if (kDebugMode) {
          print('Database copied successfully.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to copy database from assets: $e');
        }
      }
    }
    
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

Future<File> get dBPath async {
  final Directory appDocDir = await getAppDir();
  final dbPath = path.join(appDocDir.path, 'mdd.db');
  final dbFile = File(dbPath);
  // if (dbFile.existsSync()) {
  //   // delete the database file
  //   await dbFile.delete();
  // }
  return dbFile;
}

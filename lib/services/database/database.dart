//! Main database module

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mdd/services/app_services.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'database.g.dart';

const int _kDatabaseVersion = 3;

@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forFile(File file)
      : super(NativeDatabase.createInBackground(file, logStatements: true));

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

    bool needsCopy = false;
    ByteData? loadedAssetData;

    if (!await file.exists() || await file.length() < 1000000) {
      needsCopy = true;
    } else {
      try {
        final db = sqlite3.sqlite3.open(file.path);
        final milCountRes = db.select('SELECT count(*) as c FROM milData');
        final milCount = milCountRes.first['c'] as int;

        String? localMilVer;
        try {
          final infoRes = db.select('SELECT milVersion FROM mddInfo');
          if (infoRes.isNotEmpty) {
            localMilVer = infoRes.first['milVersion'] as String?;
          }
        } catch (_) {
          // milVersion column missing in older schemas
        }
        db.close();

        if (milCount == 0 || localMilVer == null || localMilVer.isEmpty) {
          if (kDebugMode) {
            print('MIL data or version missing from local database.');
          }
          needsCopy = true;
        } else {
          // Compare with asset DB milVersion
          try {
            loadedAssetData = await rootBundle.load('assets/data/mdd.db');
            final tempDir = await Directory.systemTemp.createTemp('mdd_ver_check');
            final tempAssetFile = File(path.join(tempDir.path, 'asset_mdd.db'));
            await tempAssetFile.writeAsBytes(
              loadedAssetData.buffer.asUint8List(
                loadedAssetData.offsetInBytes,
                loadedAssetData.lengthInBytes,
              ),
            );

            final assetDb = sqlite3.sqlite3.open(tempAssetFile.path);
            final assetInfoRes = assetDb.select('SELECT milVersion FROM mddInfo');
            String? assetMilVer;
            if (assetInfoRes.isNotEmpty) {
              assetMilVer = assetInfoRes.first['milVersion'] as String?;
            }
            assetDb.close();
            await tempDir.delete(recursive: true);

            if (assetMilVer != null && assetMilVer.isNotEmpty && assetMilVer != localMilVer) {
              if (kDebugMode) {
                print(
                  'New MIL release detected in assets ($assetMilVer vs local $localMilVer). Replacing database.',
                );
              }
              needsCopy = true;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Could not verify asset milVersion: $e');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to verify local database: $e');
        }
        needsCopy = true;
      }
    }

    if (needsCopy) {
      if (kDebugMode) {
        print(
          'Replacing/initializing database from assets/data/mdd.db...',
        );
      }
      try {
        final byteData = loadedAssetData ?? await rootBundle.load('assets/data/mdd.db');
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
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

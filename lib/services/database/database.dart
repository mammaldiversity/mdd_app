//! Main database module

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:mdd/services/app_services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'database.g.dart';

const int _kDatabaseVersion = 4;

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
      // Schema changes ship as a new bundled database, which replaces the
      // local copy whenever the app updates (see _openConnection), so there
      // is nothing to migrate in place.
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

    final String appVersion = await _currentAppVersion();
    final prefs = await SharedPreferences.getInstance();
    final String? installedFor = prefs.getString(_kInstalledForAppVersionKey);

    String? reason;
    if (!await file.exists() || await file.length() < 1000000) {
      reason = 'missing or incomplete';
    } else if (installedFor != appVersion) {
      // Every app update ships a new bundled database (MDD, MIL, schema
      // fixes), so always replace it rather than trying to merge.
      reason = 'app updated (${installedFor ?? 'unknown'} -> $appVersion)';
    } else if (!_isReadable(file)) {
      reason = 'unreadable';
    }

    if (reason != null) {
      if (kDebugMode) {
        print('Replacing database from assets: $reason');
      }
      try {
        await installBundledDatabase(file);
        await prefs.setString(_kInstalledForAppVersionKey, appVersion);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to copy database from assets: $e');
        }
      }
    }

    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

/// Preference key holding the app version that installed the local database.
const String _kInstalledForAppVersionKey = 'databaseInstalledForAppVersion';

Future<String> _currentAppVersion() async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}

bool _isReadable(File file) {
  try {
    final db = sqlite3.sqlite3.open(file.path);
    try {
      db.select('SELECT count(*) FROM milData');
      db.select('SELECT version FROM mddInfo');
      return true;
    } finally {
      db.close();
    }
  } catch (_) {
    return false;
  }
}

/// Replaces [file] with the database bundled in the app assets.
///
/// Writes to a temporary file first and renames it, so an interrupted copy
/// never leaves a half-written database behind. The connection to [file]
/// must be closed before calling this.
Future<void> installBundledDatabase(File file) async {
  final ByteData byteData = await rootBundle.load('assets/data/mdd.db');
  final File tempFile = File('${file.path}.tmp');
  await tempFile.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    flush: true,
  );
  for (final String suffix in ['-wal', '-shm', '-journal']) {
    final File sidecar = File('${file.path}$suffix');
    if (await sidecar.exists()) {
      await sidecar.delete();
    }
  }
  await tempFile.rename(file.path);
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

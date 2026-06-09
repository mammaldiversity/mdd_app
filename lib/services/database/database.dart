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

const int _kDatabaseVersion = 3;

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
          await createMilData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            await m.createAll();
            await createMddDefault();
            await createMilData();
          } else if (from == 2) {
            await m.createTable(milData);
            await createMilData();
          }
        },
      );

  Future<void> createMddDefault() async {
    final mddData = await rootBundle.load('assets/data/data.json.gz');
    final buffer = mddData.buffer.asUint8List();
    final MddHelper data = await MddHelper.parse(bytes: buffer);
    await _updateMddInfo(data.version, data.releaseDate);
    final List<TaxonomyData> allTaxonomy = [];
    final List<SynonymData> allSynonyms = [];

    for (var dataString in data.mddData) {
      final MddData decodedData = MddData.fromJson(json.decode(dataString));
      allTaxonomy.add(decodedData.speciesData);
      if (decodedData.synonyms.isNotEmpty) {
        allSynonyms.addAll(decodedData.synonyms);
      }
    }

    final List<SynonymData> extraSynonyms = data.synData
        .map((value) => SynonymData.fromJson(json.decode(value)))
        .cast<SynonymData>()
        .toList();
    allSynonyms.addAll(extraSynonyms);

    await batch((batch) {
      batch.insertAll(taxonomy, allTaxonomy);
      batch.insertAll(synonym, allSynonyms);
    });
  }

  Future<void> _updateMddInfo(String version, String releaseDate) async {
    final MddInfoCompanion data = MddInfoCompanion(
      version: Value(version),
      releaseDate: Value(releaseDate),
    );
    await into(mddInfo).insert(data);
  }

  Future<void> createMilData() async {
    final String milJsonString = await rootBundle.loadString('assets/data/mil.json');
    final List<dynamic> milList = json.decode(milJsonString);
    final List<MilDataCompanion> allMilData = milList.map((item) {
      return MilDataCompanion.insert(
        milId: item['milId']?.toString() ?? '',
        mddId: int.tryParse(item['mddId']?.toString() ?? '0') ?? 0,
        description: Value(item['description']?.toString()),
        photographer: Value(item['photographer']?.toString()),
        location: Value(item['location']?.toString()),
        distribution: Value(item['distribution']?.toString()),
        dateTaken: Value(item['dateTaken']?.toString()),
        orientation: Value(item['orientation']?.toString()),
        isUncertainIdentification: Value(item['isUncertainIdentification'] == true ? 1 : 0),
      );
    }).toList();

    await batch((batch) {
      batch.insertAll(milData, allMilData);
    });
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
  //   // delete the database file
  //   await dbFile.delete();
  // }
  return dbFile;
}

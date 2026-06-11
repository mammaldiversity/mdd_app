import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/model.dart';
import 'package:mdd/src/rust/api/parser.dart';
import 'package:mdd/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();

  final dbFile = File('assets/data/mdd.db');
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  final db = AppDatabase.forFile(dbFile);
  
  // 1. Process MDD.zip
  final mddZipPath = 'data/MDD.zip';
  if (!File(mddZipPath).existsSync()) {
    if (kDebugMode) {
      print('MDD.zip not found in data/ folder.');
    }
    exit(1);
  }
  
  if (kDebugMode) {
    print('Parsing MDD.zip...');
  }
  final mddData = await MddHelper.parseMddZip(zipPath: mddZipPath);
  
  if (kDebugMode) {
    print('Inserting MDD data...');
  }
  final List<TaxonomyData> allTaxonomy = [];
  final List<SynonymData> allSynonyms = [];

  for (var dataString in mddData.mddData) {
    final MddData decodedData = MddData.fromJson(json.decode(dataString));
    allTaxonomy.add(decodedData.speciesData);
    if (decodedData.synonyms.isNotEmpty) {
      allSynonyms.addAll(decodedData.synonyms);
    }
  }

  final List<SynonymData> extraSynonyms = mddData.synData
      .map((value) => SynonymData.fromJson(json.decode(value)))
      .cast<SynonymData>()
      .toList();
  allSynonyms.addAll(extraSynonyms);

  await db.batch((batch) {
    batch.insertAll(db.taxonomy, allTaxonomy);
    batch.insertAll(db.synonym, allSynonyms);
  });
  
  final MddInfoCompanion infoData = MddInfoCompanion(
    version: Value(mddData.version),
    releaseDate: Value(mddData.releaseDate),
  );
  await db.into(db.mddInfo).insert(infoData);

  // 2. Process MIL.tar.gz
  final milTarPath = 'data/MIL.tar.gz';
  if (!File(milTarPath).existsSync()) {
    if (kDebugMode) {
      print('MIL.tar.gz not found in data/ folder.');
    }
    exit(1);
  }

  if (kDebugMode) {
    print('Parsing MIL data...');
  }
  final milDataObj = await MilHelper.parseMilData(tarPath: milTarPath);
  
  if (kDebugMode) {
    print('Inserting MIL data...');
  }
  final List<dynamic> milList = json.decode(milDataObj.milData);
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

  await db.batch((batch) {
    batch.insertAll(db.milData, allMilData);
  });

  await db.close();
  if (kDebugMode) {
    print('Successfully generated mdd.db in assets/data/');
  }
  exit(0);
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:file_selector/file_selector.dart';

import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/model.dart';
import 'package:mdd/src/rust/api/parser.dart';
import 'package:drift/drift.dart';
import 'package:mdd/services/providers/database.dart';

enum UpdateState { idle, downloading, extracting, updating, success, error }

class UpdateStatus {
  final UpdateState state;
  final String message;
  final double progress;

  UpdateStatus({required this.state, this.message = '', this.progress = 0.0});
}

class DataUpdateNotifier extends Notifier<UpdateStatus> {
  http.Client? _activeClient;
  bool _isCancelled = false;

  @override
  UpdateStatus build() {
    return UpdateStatus(state: UpdateState.idle);
  }

  void reset() {
    state = UpdateStatus(state: UpdateState.idle);
  }

  void cancel() {
    if (state.state == UpdateState.downloading) {
      _isCancelled = true;
      _activeClient?.close();
      _activeClient = null;
      state = UpdateStatus(state: UpdateState.error, message: 'Download cancelled by user.');
    }
  }

  Future<void> downloadAndUpdateMdd() async {
    state = UpdateStatus(state: UpdateState.downloading, message: 'Downloading MDD...', progress: 0.1);
    _isCancelled = false;
    _activeClient = http.Client();
    try {
      final request = http.Request('GET', Uri.parse('https://raw.githubusercontent.com/mammaldiversity/mammaldiversity.github.io/master/assets/data/MDD.zip'));
      final response = await _activeClient!.send(request);
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(path.join(tempDir.path, 'MDD.zip'));
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        
        if (_isCancelled) return;
        await _processMddFile(file.path);
      } else {
        throw Exception('Failed to download MDD.zip (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (!_isCancelled) {
        state = UpdateStatus(state: UpdateState.error, message: e.toString());
      }
    } finally {
      _activeClient?.close();
      _activeClient = null;
    }
  }

  Future<void> importLocalMdd() async {
    try {
      const XTypeGroup zipTypeGroup = XTypeGroup(label: 'zips', extensions: <String>['zip']);
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[zipTypeGroup]);
      if (file != null) {
        state = UpdateStatus(state: UpdateState.extracting, message: 'Reading local MDD...', progress: 0.1);
        await _processMddFile(file.path);
      }
    } catch (e) {
      state = UpdateStatus(state: UpdateState.error, message: e.toString());
    }
  }

  Future<void> _processMddFile(String filePath) async {
    state = UpdateStatus(state: UpdateState.extracting, message: 'Parsing MDD.zip...', progress: 0.5);
    try {
      final mddData = await MddHelper.parseMddZip(zipPath: filePath);
      
      state = UpdateStatus(state: UpdateState.updating, message: 'Updating database...', progress: 0.8);
      final db = ref.read(databaseProvider);

      // Check version
      final currentInfo = await db.select(db.mddInfo).getSingleOrNull();
      if (currentInfo != null && currentInfo.version == mddData.version) {
        state = UpdateStatus(state: UpdateState.error, message: 'MDD is already up to date (${mddData.version}).');
        return;
      }

      final List<TaxonomyData> allTaxonomy = [];
      final List<SynonymData> allSynonyms = [];

      for (var dataString in mddData.mddData) {
        if (dataString.trim().isEmpty) continue;
        final MddData decodedData = MddData.fromJson(json.decode(dataString));
        allTaxonomy.add(decodedData.speciesData);
        if (decodedData.synonyms.isNotEmpty) {
          allSynonyms.addAll(decodedData.synonyms);
        }
      }

      final List<SynonymData> extraSynonyms = mddData.synData
          .where((value) => value.trim().isNotEmpty)
          .map((value) => SynonymData.fromJson(json.decode(value)))
          .cast<SynonymData>()
          .toList();
      allSynonyms.addAll(extraSynonyms);

      await db.transaction(() async {
        await db.delete(db.taxonomy).go();
        await db.delete(db.synonym).go();
        await db.delete(db.mddInfo).go();

        await db.batch((batch) {
          batch.insertAll(db.taxonomy, allTaxonomy);
          batch.insertAll(db.synonym, allSynonyms);
        });

        final MddInfoCompanion infoData = MddInfoCompanion(
          version: Value(mddData.version),
          releaseDate: Value(mddData.releaseDate),
        );
        await db.into(db.mddInfo).insert(infoData);
      });

      state = UpdateStatus(state: UpdateState.success, message: 'Successfully updated to MDD ${mddData.version}', progress: 1.0);
    } catch (e) {
      state = UpdateStatus(state: UpdateState.error, message: 'Extraction error: $e');
    }
  }

  Future<void> downloadAndUpdateMil() async {
    state = UpdateStatus(state: UpdateState.downloading, message: 'Fetching MIL release info...', progress: 0.1);
    _isCancelled = false;
    _activeClient = http.Client();
    try {
      final apiResponse = await _activeClient!.get(Uri.parse('https://api.github.com/repos/mammaldiversity/asm-mil/releases/latest'));
      if (apiResponse.statusCode != 200) {
        throw Exception('Failed to fetch MIL releases (HTTP ${apiResponse.statusCode})');
      }
      if (_isCancelled) return;
      
      final jsonResponse = jsonDecode(apiResponse.body);
      final assets = jsonResponse['assets'] as List;
      final asset = assets.firstWhere((a) => a['name'].toString().endsWith('.tar.gz'), orElse: () => null);
      
      if (asset == null) {
        throw Exception('No MIL.tar.gz asset found in the latest release');
      }
      
      final downloadUrl = asset['browser_download_url'];
      state = UpdateStatus(state: UpdateState.downloading, message: 'Downloading MIL data...', progress: 0.3);
      
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await _activeClient!.send(request);
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(path.join(tempDir.path, 'MIL.tar.gz'));
        final sink = file.openWrite();
        await response.stream.pipe(sink);
        
        if (_isCancelled) return;
        await _processMilFile(file.path);
      } else {
        throw Exception('Failed to download MIL.tar.gz (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (!_isCancelled) {
        state = UpdateStatus(state: UpdateState.error, message: e.toString());
      }
    } finally {
      _activeClient?.close();
      _activeClient = null;
    }
  }

  Future<void> importLocalMil() async {
    try {
      const XTypeGroup tarGroup = XTypeGroup(label: 'tar.gz', extensions: <String>['gz', 'tar', 'json']);
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[tarGroup]);
      if (file != null) {
        state = UpdateStatus(state: UpdateState.extracting, message: 'Reading local MIL...', progress: 0.1);
        await _processMilFile(file.path);
      }
    } catch (e) {
      state = UpdateStatus(state: UpdateState.error, message: e.toString());
    }
  }

  Future<void> _processMilFile(String filePath) async {
    state = UpdateStatus(state: UpdateState.extracting, message: 'Parsing MIL data...', progress: 0.5);
    try {
      final milDataObj = await MilHelper.parseMilData(tarPath: filePath);
      
      state = UpdateStatus(state: UpdateState.updating, message: 'Updating database...', progress: 0.8);
      final db = ref.read(databaseProvider);

      if (milDataObj.milData.trim().isEmpty) {
        throw Exception('The provided MIL file is empty or could not be parsed as valid JSON.');
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

      await db.transaction(() async {
        await db.delete(db.milData).go();
        await db.batch((batch) {
          batch.insertAll(db.milData, allMilData);
        });
      });

      state = UpdateStatus(state: UpdateState.success, message: 'Successfully updated MIL data', progress: 1.0);
    } catch (e) {
      state = UpdateStatus(state: UpdateState.error, message: 'Extraction error: $e');
    }
  }
}

final dataUpdateProvider = NotifierProvider<DataUpdateNotifier, UpdateStatus>(() {
  return DataUpdateNotifier();
});

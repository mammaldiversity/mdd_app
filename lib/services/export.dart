import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/system.dart';
import 'package:mdd/services/utils.dart';
import 'package:mdd/src/rust/api/parser.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

enum ExportFormat { json, csv }

const String _kOutputDir = 'exported_data';
const String _kFileName = 'export.csv';

class FileWriter {
  const FileWriter({
    required this.ref,
    required this.fileName,
    required this.format,
    this.outputDir,
  });

  final WidgetRef ref;
  final String? outputDir;
  final String fileName;
  final ExportFormat format;

  Future<XFile> toFile(List<int> mddIDs) async {
    final bool toCsv = format == ExportFormat.csv;
    final String data = await _getData(mddIDs);
    final writer = DatabaseWriter(
      jsonData: data,
      outputDir: await _getOutputDir(),
      outputFilename: fileName,
      toCsv: toCsv,
    );
    final String outputPath = await writer.write();
    return XFile(outputPath);
  }

  Future<String> _getData(List<int> mddIDs) async {
    final List<TaxonomyData> data = await MddQuery(ref.read(databaseProvider))
        .retrieveTaxonDataList(mddIDs);

    return json.encode(data);
  }

  Future<String> _getOutputDir() async {
    if (outputDir != null) {
      return outputDir!;
    }
    return _defaultOutputDir;
  }

  Future<String> get _defaultOutputDir async {
    final Directory appDir = await getAppDir();
    final outputDir = path.join(appDir.path, _kOutputDir);
    return outputDir;
  }
}

class FileExport {
  const FileExport({
    required this.ref,
    required this.mddIDs,
  });

  final WidgetRef ref;
  final List<int> mddIDs;

  Future<String?> write() async {
    final platformType = getPlatformType();
    if (platformType == PlatformType.mobile) {
      return await _writeMobile();
    } else {
      return await _saveFiles();
    }
  }

  Future<String?> _writeMobile() async {
    final file = await FileWriter(
      ref: ref,
      outputDir: null,
      fileName: _kFileName,
      format: ExportFormat.csv,
    ).toFile(mddIDs);
    await Share.shareXFiles([file]);
    return file.path;
  }

  Future<String?> _saveFiles() async {
    final outputFile = await _pickSaveFile();
    if (outputFile != null) {
      final ext = outputFile.extractExtension();
      ExportFormat format =
          ext.isEmpty ? ExportFormat.csv : _getOutputFormat(ext);
      try {
        return await _writeFile(outputFile, format);
      } catch (e) {
        if (outputFile.extractExtension().isEmpty) {
          throw Exception('No file extension provided');
        } else {
          throw Exception('Failed to write file: $e');
        }
      }
    }
    return null;
  }

  Future<String?> _writeFile(String outputFile, ExportFormat format) async {
    final writer = FileWriter(
      ref: ref,
      outputDir: path.dirname(outputFile),
      fileName: path.basename(outputFile),
      format: format,
    );
    final outputPath = await writer.toFile(mddIDs);
    return outputPath.path;
  }

  Future<String?> _pickSaveFile() async {
    final outputFile = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
      dialogTitle: 'Please select a file',
      fileName: _kFileName,
    );
    return outputFile;
  }

  ExportFormat _getOutputFormat(String fileExtension) {
    return fileExtension == 'json' ? ExportFormat.json : ExportFormat.csv;
  }
}

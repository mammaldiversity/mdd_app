import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/system.dart';
import 'package:mdd/src/rust/api/writer.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

enum ExportFormat { json, csv }

const String _kOutputDir = 'exported_data';
const String kDefaultFileName = 'export';

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
    required this.fileName,
    required this.format,
  });

  final WidgetRef ref;
  final List<int> mddIDs;
  final String fileName;
  final ExportFormat format;

  Future<String?> write(BuildContext context) async {
    final platformType = getPlatformType();
    if (platformType == PlatformType.mobile) {
      return await _writeMobile(context);
    } else {
      return await _saveDesktop();
    }
  }

  Future<String?> _writeMobile(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final file = await FileWriter(
      ref: ref,
      outputDir: null,
      fileName: '$fileName.${format.name}',
      format: format,
    ).toFile(mddIDs);
    await Share.shareXFiles(
      [file],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return file.path;
  }

  Future<String?> _saveDesktop() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: format.name.toUpperCase(),
      extensions: <String>[format.name],
    );
    final FileSaveLocation? saveLocation = await getSaveLocation(
      suggestedName: '$fileName.${format.name}',
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (saveLocation != null) {
      final String outputFile = saveLocation.path;
      final writer = FileWriter(
        ref: ref,
        outputDir: path.dirname(outputFile),
        fileName: path.basename(outputFile),
        format: format,
      );
      try {
        final outputPath = await writer.toFile(mddIDs);
        return outputPath.path;
      } catch (e) {
        throw Exception('Failed to write file: $e');
      }
    }
    return null;
  }
}

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

enum ExportFormat {
  csv('CSV', 'csv', 'text/csv'),
  tsv('TSV', 'tsv', 'text/tab-separated-values'),
  json('JSON', 'json', 'application/json');

  const ExportFormat(this.label, this.extension, this.mimeType);

  final String label;
  final String extension;
  final String mimeType;
}

const String _kOutputDir = 'exported_data';
const String kDefaultFileName = 'export';

class ExportSettings {
  final String fileName;
  final ExportFormat format;

  const ExportSettings({required this.fileName, required this.format});
}

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
    final bool toCsv = format == ExportFormat.csv || format == ExportFormat.tsv;
    final String data = await _getData(mddIDs);
    final resolvedOutputDir = await _getOutputDir();

    if (format == ExportFormat.tsv) {
      final writer = DatabaseWriter(
        jsonData: data,
        outputDir: resolvedOutputDir,
        outputFilename: '${fileName}_tmp',
        toCsv: true,
      );
      final String csvPath = await writer.write();
      final csvFile = File(csvPath);
      final csvLines = await csvFile.readAsLines();
      final tsvLines =
          csvLines.map((line) => line.split(',').join('\t')).toList();
      final tsvPath = path.join(resolvedOutputDir, '$fileName.tsv');
      await File(tsvPath).writeAsString(tsvLines.join('\n'));
      if (await csvFile.exists()) {
        await csvFile.delete();
      }
      return XFile(tsvPath);
    }

    final writer = DatabaseWriter(
      jsonData: data,
      outputDir: resolvedOutputDir,
      outputFilename: fileName,
      toCsv: toCsv,
    );
    final String outputPath = await writer.write();
    return XFile(outputPath);
  }

  Future<String> _getData(List<int> mddIDs) async {
    final List<TaxonomyData> data = await MddQuery(
      ref.read(databaseProvider),
    ).retrieveTaxonDataList(mddIDs);

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
      fileName: '$fileName.${format.extension}',
      format: format,
    ).toFile(mddIDs);
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        sharePositionOrigin: box != null
            ? (box.localToGlobal(Offset.zero) & box.size)
            : Rect.zero,
      ),
    );
    return file.path;
  }

  Future<String?> _saveDesktop() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: format.label,
      extensions: <String>[format.extension],
    );
    final FileSaveLocation? saveLocation = await getSaveLocation(
      suggestedName: '$fileName.${format.extension}',
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

class TableDataExporter {
  const TableDataExporter({
    required this.fileName,
    required this.format,
    required this.headers,
    required this.rows,
  });

  final String fileName;
  final ExportFormat format;
  final List<String> headers;
  final List<List<dynamic>> rows;

  String serialize() {
    switch (format) {
      case ExportFormat.csv:
        return toCsv(headers, rows);
      case ExportFormat.tsv:
        return toTsv(headers, rows);
      case ExportFormat.json:
        return toJson(headers, rows);
    }
  }

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
    final Directory appDir = await getAppDir();
    final outputDir = path.join(appDir.path, _kOutputDir);
    await Directory(outputDir).create(recursive: true);
    final filePath = path.join(outputDir, '$fileName.${format.extension}');
    final file = File(filePath);
    await file.writeAsString(serialize());

    final xFile = XFile(filePath, mimeType: format.mimeType);
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        sharePositionOrigin: box != null
            ? (box.localToGlobal(Offset.zero) & box.size)
            : Rect.zero,
      ),
    );
    return file.path;
  }

  Future<String?> _saveDesktop() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: format.label,
      extensions: <String>[format.extension],
    );
    final FileSaveLocation? saveLocation = await getSaveLocation(
      suggestedName: '$fileName.${format.extension}',
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (saveLocation != null) {
      final file = File(saveLocation.path);
      await file.writeAsString(serialize());
      return saveLocation.path;
    }
    return null;
  }

  static String toCsv(List<String> headers, List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escapeCsvField).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsvField).join(','));
    }
    return buffer.toString();
  }

  static String toTsv(List<String> headers, List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escapeTsvField).join('\t'));
    for (final row in rows) {
      buffer.writeln(row.map(_escapeTsvField).join('\t'));
    }
    return buffer.toString();
  }

  static String toJson(List<String> headers, List<List<dynamic>> rows) {
    final list = <Map<String, dynamic>>[];
    for (final row in rows) {
      final map = <String, dynamic>{};
      for (var i = 0; i < headers.length; i++) {
        final val = i < row.length ? row[i] : null;
        map[headers[i]] = val;
      }
      list.add(map);
    }
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(list);
  }

  static String _escapeCsvField(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  static String _escapeTsvField(dynamic value) {
    final str = value?.toString() ?? '';
    return str.replaceAll('\t', ' ').replaceAll('\r', '').replaceAll('\n', ' ');
  }
}

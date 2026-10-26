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
import 'package:mdd/src/rust/api/xlsx.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

enum ExportFormat {
  csv('CSV', 'csv', 'text/csv'),
  tsv('TSV', 'tsv', 'text/tab-separated-values'),
  json('JSON', 'json', 'application/json'),
  xlsx(
    'Excel',
    'xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );

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

  /// Also exports the synonyms of the exported species: a second file, or a
  /// second sheet for Excel.
  final bool includeSynonyms;

  const ExportSettings({
    required this.fileName,
    required this.format,
    this.includeSynonyms = false,
  });
}

/// Converts CSV text to TSV. Quoted fields keep their commas in one column;
/// tabs and line breaks inside a field become spaces.
String csvToTsv(String csv) {
  final rows = parseCsv(csv);
  if (rows.isEmpty) return '';
  return TableDataExporter.toTsv(rows.first, rows.skip(1).toList());
}

/// Parses RFC 4180 CSV: fields may be quoted, with `""` for a literal quote
/// and commas or line breaks inside the quotes.
List<List<String>> parseCsv(String csv) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < csv.length; i++) {
    final char = csv[i];
    if (inQuotes) {
      if (char != '"') {
        field.write(char);
      } else if (i + 1 < csv.length && csv[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        inQuotes = false;
      }
    } else if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      endField();
    } else if (char == '\n') {
      endRow();
    } else if (char != '\r') {
      field.write(char);
    }
  }
  // No trailing line break after the last row.
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// Name of the synonyms file written next to the species file [fileName].
String synonymFileName(String fileName, ExportFormat format) =>
    '${path.basenameWithoutExtension(fileName)}_synonyms.${format.extension}';

class FileWriter {
  const FileWriter({
    required this.ref,
    required this.fileName,
    required this.format,
    this.outputDir,
    this.includeSynonyms = false,
  });

  final WidgetRef ref;
  final String? outputDir;
  final String fileName;
  final ExportFormat format;

  /// Adds a synonyms sheet to Excel exports. Other formats write synonyms
  /// separately with [synonymsToFile].
  final bool includeSynonyms;

  Future<XFile> toFile(List<int> mddIDs) async {
    final bool toCsv = format == ExportFormat.csv || format == ExportFormat.tsv;
    final String data = await _getData(mddIDs);
    final resolvedOutputDir = await _getOutputDir();

    if (format == ExportFormat.xlsx) {
      await Directory(resolvedOutputDir).create(recursive: true);
      final xlsxPath = path.join(
        resolvedOutputDir,
        '${path.basenameWithoutExtension(fileName)}.xlsx',
      );
      await writeXlsx(
        outputPath: xlsxPath,
        sheets: [
          await speciesXlsxSheet(jsonData: data),
          if (includeSynonyms) await _synonymSheet(mddIDs),
        ],
      );
      return XFile(xlsxPath, mimeType: format.mimeType);
    }

    if (format == ExportFormat.tsv) {
      final writer = DatabaseWriter(
        jsonData: data,
        outputDir: resolvedOutputDir,
        outputFilename: '${fileName}_tmp',
        toCsv: true,
      );
      final String csvPath = await writer.write();
      final csvFile = File(csvPath);
      final tsvPath = path.join(resolvedOutputDir, '$fileName.tsv');
      await File(tsvPath).writeAsString(csvToTsv(await csvFile.readAsString()));
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

  /// Writes the synonyms of [mddIDs] to their own file next to the species
  /// file. Each row keeps its `speciesId` to link it back to a species.
  Future<XFile> synonymsToFile(List<int> mddIDs) async {
    final synonyms = await _synonymTable(mddIDs);
    final resolvedOutputDir = await _getOutputDir();
    await Directory(resolvedOutputDir).create(recursive: true);
    final filePath = path.join(
      resolvedOutputDir,
      synonymFileName(fileName, format),
    );
    await TableDataExporter(
      fileName: fileName,
      format: format,
      headers: synonyms.headers,
      rows: synonyms.rows,
    ).writeTo(filePath);
    return XFile(filePath, mimeType: format.mimeType);
  }

  Future<XlsxSheet> _synonymSheet(List<int> mddIDs) async {
    final synonyms = await _synonymTable(mddIDs);
    return XlsxSheet(
      name: 'Synonyms',
      headers: synonyms.headers,
      jsonRows: TableDataExporter.toJson(synonyms.headers, synonyms.rows),
    );
  }

  /// Synonym rows for [mddIDs]. Each keeps its `speciesId` to link it back
  /// to a species.
  Future<({List<String> headers, List<List<dynamic>> rows})> _synonymTable(
    List<int> mddIDs,
  ) async {
    final db = ref.read(databaseProvider);
    final synonyms = await MddQuery(db).retrieveSynonymDataList(mddIDs);
    final records = synonyms.map((s) => s.toJson()).toList();
    final headers = records.isNotEmpty
        ? records.first.keys.toList()
        : db.synonym.$columns.map((c) => c.name).toList();
    return (
      headers: headers,
      rows: [
        for (final record in records) [for (final h in headers) record[h]],
      ],
    );
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
    this.includeSynonyms = false,
  });

  final WidgetRef ref;
  final List<int> mddIDs;
  final String fileName;
  final ExportFormat format;
  final bool includeSynonyms;

  /// Excel keeps synonyms in a sheet of the same workbook.
  bool get _separateSynonyms => includeSynonyms && format != ExportFormat.xlsx;

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
    final writer = FileWriter(
      ref: ref,
      outputDir: null,
      fileName: '$fileName.${format.extension}',
      format: format,
      includeSynonyms: includeSynonyms,
    );
    final file = await writer.toFile(mddIDs);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          file,
          if (_separateSynonyms) await writer.synonymsToFile(mddIDs),
        ],
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
        includeSynonyms: includeSynonyms,
      );
      try {
        final outputPath = await writer.toFile(mddIDs);
        if (!_separateSynonyms) return outputPath.path;
        final synonymPath = await writer.synonymsToFile(mddIDs);
        return '${outputPath.path} and ${synonymPath.path}';
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

  /// Text formats only; Excel is binary and written by [writeTo].
  String serialize() {
    switch (format) {
      case ExportFormat.csv:
        return toCsv(headers, rows);
      case ExportFormat.tsv:
        return toTsv(headers, rows);
      case ExportFormat.json:
        return toJson(headers, rows);
      case ExportFormat.xlsx:
        throw UnsupportedError('Excel is binary; use writeTo instead.');
    }
  }

  Future<void> writeTo(String filePath) async {
    if (format == ExportFormat.xlsx) {
      await writeXlsx(
        outputPath: filePath,
        sheets: [
          XlsxSheet(
            name: 'Data',
            headers: headers,
            jsonRows: toJson(headers, rows),
          ),
        ],
      );
      return;
    }
    await File(filePath).writeAsString(serialize());
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
    await writeTo(filePath);

    final xFile = XFile(filePath, mimeType: format.mimeType);
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        sharePositionOrigin: box != null
            ? (box.localToGlobal(Offset.zero) & box.size)
            : Rect.zero,
      ),
    );
    return filePath;
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
      await writeTo(saveLocation.path);
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

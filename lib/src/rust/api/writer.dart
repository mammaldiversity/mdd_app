// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Supports writing to JSON and CSV.
class DatabaseWriter {
  final String jsonData;
  final String outputDir;
  final String outputFilename;
  final bool toCsv;

  const DatabaseWriter({
    required this.jsonData,
    required this.outputDir,
    required this.outputFilename,
    required this.toCsv,
  });

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<DatabaseWriter> newInstance(
          {required String jsonData,
          required String outputDir,
          required String outputFilename,
          required bool toCsv}) =>
      RustLib.instance.api.crateApiWriterDatabaseWriterNew(
          jsonData: jsonData,
          outputDir: outputDir,
          outputFilename: outputFilename,
          toCsv: toCsv);

  Future<String> write() =>
      RustLib.instance.api.crateApiWriterDatabaseWriterWrite(
        that: this,
      );

  @override
  int get hashCode =>
      jsonData.hashCode ^
      outputDir.hashCode ^
      outputFilename.hashCode ^
      toCsv.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseWriter &&
          runtimeType == other.runtimeType &&
          jsonData == other.jsonData &&
          outputDir == other.outputDir &&
          outputFilename == other.outputFilename &&
          toCsv == other.toCsv;
}
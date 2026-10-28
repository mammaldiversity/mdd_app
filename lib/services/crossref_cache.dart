import 'dart:convert';
import 'dart:io';

import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:path/path.dart' as path;

/// Publications fetched for one taxon so far, and where Crossref left off.
class CrossrefProgress {
  const CrossrefProgress({
    required this.works,
    required this.nextCursor,
    required this.totalResults,
    required this.scanned,
  });

  final List<CrossrefWork> works;
  final String? nextCursor;
  final int totalResults;

  /// Crossref records read so far, before filtering.
  final int scanned;

  /// Whether another page could hold more works, within
  /// [CrossrefClient.maxScanned].
  bool get hasMore =>
      nextCursor != null &&
      scanned < totalResults &&
      scanned < CrossrefClient.maxScanned;

  /// Adds [page], skipping works already listed.
  CrossrefProgress append(CrossrefPage page) {
    final Set<String> seen = {for (final work in works) work.doi};
    return CrossrefProgress(
      works: [
        ...works,
        for (final work in page.works)
          if (seen.add(work.doi)) work,
      ],
      nextCursor: page.nextCursor,
      totalResults: page.totalResults,
      scanned: scanned + page.scanned,
    );
  }

  static const CrossrefProgress empty = CrossrefProgress(
    works: [],
    nextCursor: '*',
    totalResults: 0,
    scanned: 0,
  );
}

/// Keeps fetched publications on the device for [maxAge], so reopening a
/// taxon costs Crossref no request.
class CrossrefCache {
  CrossrefCache({Future<Directory> Function()? directory, this.now = _now})
    : _directory = directory ?? _defaultDirectory;

  final Future<Directory> Function() _directory;
  final DateTime Function() now;

  static const Duration maxAge = Duration(days: 7);

  /// Files kept at most; the oldest go first.
  static const int maxEntries = 200;

  static DateTime _now() => DateTime.now();

  static Future<Directory> _defaultDirectory() async =>
      Directory(path.join((await getAppDir()).path, 'crossref_cache'));

  /// The cached progress for [name], or null when there is none, it is
  /// older than [maxAge], or it cannot be read.
  Future<CrossrefProgress?> read(String name) async {
    try {
      final File file = await _file(name);
      if (!await file.exists()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(json['fetchedAt'] as String);
      if (now().difference(fetchedAt) > maxAge) return null;
      return CrossrefProgress(
        works: [
          for (final work in json['works'] as List<dynamic>)
            CrossrefWork.fromCacheJson(work as Map<String, dynamic>),
        ],
        nextCursor: json['nextCursor'] as String?,
        totalResults: json['totalResults'] as int,
        scanned: json['scanned'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  /// Saves [progress] for [name]. A failure is ignored: the cache only
  /// saves requests.
  Future<void> write(String name, CrossrefProgress progress) async {
    try {
      final Directory dir = await _directory();
      await dir.create(recursive: true);
      final File file = await _file(name);
      await file.writeAsString(
        jsonEncode({
          'fetchedAt': now().toIso8601String(),
          'works': [for (final work in progress.works) work.toCacheJson()],
          'nextCursor': progress.nextCursor,
          'totalResults': progress.totalResults,
          'scanned': progress.scanned,
        }),
      );
      await _prune(dir);
    } catch (_) {}
  }

  Future<void> _prune(Directory dir) async {
    final List<File> files = (await dir.list().toList())
        .whereType<File>()
        .toList();
    if (files.length <= maxEntries) return;
    final modified = {for (final f in files) f: await f.lastModified()};
    files.sort((a, b) => modified[a]!.compareTo(modified[b]!));
    for (final file in files.take(files.length - maxEntries)) {
      await file.delete();
    }
  }

  /// One file per name, e.g. `rattus_rattus.json`.
  Future<File> _file(String name) async {
    final String key = name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    return File(path.join((await _directory()).path, '$key.json'));
  }
}

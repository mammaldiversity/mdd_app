import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;
import 'package:mdd/services/crossref_cache.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/providers/external_resources.dart';

/// A cache that starts from [progress] and keeps writes in memory.
class FakeCrossrefCache extends CrossrefCache {
  FakeCrossrefCache([this.progress]);

  CrossrefProgress? progress;

  @override
  Future<CrossrefProgress?> read(String name) async => progress;

  @override
  Future<void> write(String name, CrossrefProgress progress) async {
    this.progress = progress;
  }
}

/// Serves [works] from the cache, as if fetched earlier; [nextCursor] set
/// means Crossref has more.
CrossrefProgress seededProgress(
  List<CrossrefWork> works, {
  String? nextCursor,
  int scanned = 100,
  int totalResults = 100,
}) => CrossrefProgress(
  works: works,
  nextCursor: nextCursor,
  totalResults: totalResults,
  scanned: scanned,
);

/// Overrides that keep Crossref off the network: a seeded cache, an
/// unpaced gate, and [client] for any page fetched.
List<Override> crossrefOverrides({
  CrossrefProgress? progress,
  http.Client? client,
}) => [
  crossrefCacheProvider.overrideWithValue(FakeCrossrefCache(progress)),
  crossrefGateProvider.overrideWithValue(
    CrossrefRequestGate(minInterval: Duration.zero),
  ),
  if (client != null) httpClientProvider.overrideWithValue(client),
];

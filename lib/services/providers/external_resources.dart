import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mdd/services/crossref_cache.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/topojson_parser.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final gbifSummaryProvider = FutureProvider.autoDispose
    .family<GbifSummary?, String>((ref, name) {
      return GbifClient(ref.watch(httpClientProvider)).fetchSummary(name);
    });

final genBankSummaryProvider = FutureProvider.autoDispose
    .family<List<GenBankCount>, String>((ref, name) {
      return GenBankClient(ref.watch(httpClientProvider)).fetchSummary(name);
    });

final genomeSummaryProvider = FutureProvider.autoDispose
    .family<GenomeSummary, String>((ref, name) {
      return NcbiDatasetsClient(
        ref.watch(httpClientProvider),
      ).fetchSummary(name);
    });

final crossrefCacheProvider = Provider<CrossrefCache>((ref) => CrossrefCache());

/// Paces every Crossref request in the app.
final crossrefGateProvider = Provider<CrossrefRequestGate>(
  (ref) => CrossrefClient.sharedGate,
);

/// Publications naming a taxon: the first page on open, more on
/// [CrossrefWorks.loadMore].
final crossrefWorksProvider = AsyncNotifierProvider.autoDispose
    .family<CrossrefWorks, CrossrefWorksState, String>(CrossrefWorks.new);

class CrossrefWorksState {
  const CrossrefWorksState({
    required this.progress,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final CrossrefProgress progress;
  final bool isLoadingMore;

  /// The last [CrossrefWorks.loadMore] failed; the works so far remain.
  final bool loadMoreFailed;

  List<CrossrefWork> get works => progress.works;
  bool get hasMore => progress.hasMore;
}

class CrossrefWorks extends AsyncNotifier<CrossrefWorksState> {
  CrossrefWorks(this.name);

  final String name;

  CrossrefClient get _client => CrossrefClient(
    ref.read(httpClientProvider),
    gate: ref.read(crossrefGateProvider),
  );

  @override
  Future<CrossrefWorksState> build() async {
    final cache = ref.watch(crossrefCacheProvider);
    final cached = await cache.read(name);
    if (cached != null) return CrossrefWorksState(progress: cached);
    final progress = CrossrefProgress.empty.append(
      await _client.fetchPage(name),
    );
    await cache.write(name, progress);
    return CrossrefWorksState(progress: progress);
  }

  /// Fetches the next page, if there is one and none is loading.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(
      CrossrefWorksState(progress: current.progress, isLoadingMore: true),
    );
    try {
      final page = await _client.fetchPage(
        name,
        cursor: current.progress.nextCursor!,
      );
      final progress = current.progress.append(page);
      if (!ref.mounted) return;
      state = AsyncData(CrossrefWorksState(progress: progress));
      await ref.read(crossrefCacheProvider).write(name, progress);
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        CrossrefWorksState(progress: current.progress, loadMoreFailed: true),
      );
    }
  }
}

/// MDD's country distribution as map polygons, from the bundled country
/// shapes; null when the species has no distribution.
final distributionOverlayProvider = FutureProvider.autoDispose
    .family<DistributionMapData?, String>((ref, countryDistribution) async {
      if (countryDistribution.isEmpty || countryDistribution == 'NA') {
        return null;
      }
      final source = await rootBundle.loadString(
        'assets/data/countries.geojson',
      );
      final topology = Map<String, dynamic>.from(jsonDecode(source) as Map);
      return TopoJsonParser.parseDistribution(topology, countryDistribution);
    });

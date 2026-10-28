import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/release_changes.dart';
import 'package:mdd/services/statistics.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  final db = ref.watch(databaseProvider);
  return StatisticsService(MddQuery(db));
});

final statisticsProvider = FutureProvider<MddStatistics>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.getStatistics();
});

final countryDiversityStatsProvider =
    FutureProvider<List<CountryDiversityData>>((ref) {
      final service = ref.watch(statisticsServiceProvider);
      return service.getCountryDiversityStats();
    });

final releaseChangesProvider = FutureProvider<List<ReleaseChange>>((ref) async {
  final source = await rootBundle.loadString(releaseChangesAsset);
  return parseReleaseChanges(source);
});

/// Order names in phylogenetic (phylosort) sequence.
final orderSequenceProvider = FutureProvider<List<String>>((ref) {
  return MddQuery(ref.watch(databaseProvider)).retrieveOrderSequence();
});

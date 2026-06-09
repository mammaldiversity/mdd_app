import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/statistics.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  final db = ref.watch(databaseProvider);
  return StatisticsService(MddQuery(db));
});

final statisticsProvider = FutureProvider<MddStatistics>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.getStatistics();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mdd/services/external_resources.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final gbifSummaryProvider =
    FutureProvider.autoDispose.family<GbifSummary?, String>((ref, name) {
  return GbifClient(ref.watch(httpClientProvider)).fetchSummary(name);
});

final genBankSummaryProvider =
    FutureProvider.autoDispose.family<List<GenBankCount>, String>((ref, name) {
  return GenBankClient(ref.watch(httpClientProvider)).fetchSummary(name);
});

final crossrefWorksProvider =
    FutureProvider.autoDispose.family<List<CrossrefWork>, String>((ref, name) {
  return CrossrefClient(ref.watch(httpClientProvider)).fetchWorks(name);
});

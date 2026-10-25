import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

final crossrefWorksProvider = FutureProvider.autoDispose
    .family<List<CrossrefWork>, String>((ref, name) {
      return CrossrefClient(ref.watch(httpClientProvider)).fetchWorks(name);
    });

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

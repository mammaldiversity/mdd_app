import 'package:mdd/services/database/mdd_query.dart';

class MddStatistics {
  final List<StatSpeciesPerOrderResult> speciesPerOrder;
  final List<StatSpeciesPerFamilyResult> speciesPerFamily;
  final List<MapEntry<String, int>> iucnStatus;
  final List<StatSpeciesByDiscoveryDecadeResult> discoveryDecade;
  final List<StatExtinctSpeciesResult> extinctSpecies;
  final List<StatDomesticSpeciesResult> domesticSpecies;
  final List<MapEntry<String, int>> biogeographicRealm;
  final List<MapEntry<String, int>> topCountries;

  MddStatistics({
    required this.speciesPerOrder,
    required this.speciesPerFamily,
    required this.iucnStatus,
    required this.discoveryDecade,
    required this.extinctSpecies,
    required this.domesticSpecies,
    required this.biogeographicRealm,
    required this.topCountries,
  });
}

class StatisticsService {
  final MddQuery mddQuery;

  StatisticsService(this.mddQuery);

  Future<MddStatistics> getStatistics() async {
    final speciesPerOrder = await mddQuery.statSpeciesPerOrder().get();
    final speciesPerFamily = await mddQuery.statSpeciesPerFamily().get();
    final rawIucn = await mddQuery.statSpeciesByIucnStatus().get();
    final Map<String, int> iucnCounts = {};
    for (var row in rawIucn) {
      String status = row.name ?? '';
      int parenIndex = status.indexOf('(');
      if (parenIndex != -1) {
        status = status.substring(0, parenIndex).trim();
      }
      if (status.isNotEmpty) {
        iucnCounts[status] = (iucnCounts[status] ?? 0) + row.count;
      }
    }
    final cleanedIucn = iucnCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final discoveryDecade = await mddQuery.statSpeciesByDiscoveryDecade().get();
    final extinctSpecies = await mddQuery.statExtinctSpecies().get();
    final domesticSpecies = await mddQuery.statDomesticSpecies().get();
    
    final rawRealm = await mddQuery.statSpeciesByBiogeographicRealm().get();
    final Map<String, int> realmCounts = {};
    for (var row in rawRealm) {
      String realmStr = row.name ?? '';
      final realms = realmStr.split('|');
      for (var r in realms) {
        r = r.trim();
        if (r.endsWith('?')) {
          r = r.substring(0, r.length - 1).trim();
        }
        if (r.isNotEmpty && r != 'NA') {
          realmCounts[r] = (realmCounts[r] ?? 0) + row.count;
        }
      }
    }
    final cleanedRealm = realmCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final countryRows = await mddQuery.statCountryDistributions().get();
    final Map<String, int> countryCounts = {};
    for (var row in countryRows) {
      if (row == null || row.isEmpty) continue;
      final countries = row.split('|');
      for (var c in countries) {
        c = c.trim();
        if (c.isNotEmpty) {
          countryCounts[c] = (countryCounts[c] ?? 0) + 1;
        }
      }
    }

    final sortedCountries = countryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCountries = sortedCountries.take(10).toList();

    return MddStatistics(
      speciesPerOrder: speciesPerOrder,
      speciesPerFamily: speciesPerFamily,
      iucnStatus: cleanedIucn,
      discoveryDecade: discoveryDecade,
      extinctSpecies: extinctSpecies,
      domesticSpecies: domesticSpecies,
      biogeographicRealm: cleanedRealm,
      topCountries: topCountries,
    );
  }
}

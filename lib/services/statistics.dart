import 'package:mdd/services/database/mdd_query.dart';

class MddStatistics {
  final List<StatSpeciesPerOrderResult> speciesPerOrder;
  final List<StatSpeciesPerFamilyResult> speciesPerFamily;
  final List<StatSpeciesPerGenusResult> speciesPerGenus;
  final List<MapEntry<String, int>> iucnStatus;
  final List<StatSpeciesByDiscoveryDecadeResult> discoveryDecade;
  final List<StatSpeciesByDiscoveryYearResult> discoveryYear;
  final List<StatExtinctSpeciesResult> extinctSpecies;
  final List<StatDomesticSpeciesResult> domesticSpecies;
  final List<MapEntry<String, int>> biogeographicRealm;
  final List<MapEntry<String, int>> topCountries;
  final List<StatSpeciesWithMostImagesResult> speciesWithMostImages;
  final int speciesWithImagesCount;
  final int totalOrdersCount;
  final int totalFamiliesCount;
  final int totalGeneraCount;
  final int livingWildSpeciesCount;
  final int totalSpeciesCount;
  final List<StatSpeciesWithMostSynonymsResult> speciesWithMostSynonyms;
  final List<MapEntry<String, int>> typeKindProportion;

  MddStatistics({
    required this.speciesPerOrder,
    required this.speciesPerFamily,
    required this.speciesPerGenus,
    required this.iucnStatus,
    required this.discoveryDecade,
    required this.discoveryYear,
    required this.extinctSpecies,
    required this.domesticSpecies,
    required this.biogeographicRealm,
    required this.topCountries,
    required this.speciesWithMostImages,
    required this.speciesWithImagesCount,
    required this.totalOrdersCount,
    required this.totalFamiliesCount,
    required this.totalGeneraCount,
    required this.livingWildSpeciesCount,
    required this.totalSpeciesCount,
    required this.speciesWithMostSynonyms,
    required this.typeKindProportion,
  });
}

class StatisticsService {
  final MddQuery mddQuery;

  StatisticsService(this.mddQuery);

  Future<MddStatistics> getStatistics() async {
    final speciesPerOrder = await mddQuery.statSpeciesPerOrder().get();
    final speciesPerFamily = await mddQuery.statSpeciesPerFamily().get();
    final speciesPerGenus = await mddQuery.statSpeciesPerGenus().get();
    final rawIucn = await mddQuery.statSpeciesByIucnStatus().get();
    final cleanedIucn = cleanIucnStatusData(rawIucn);

    final discoveryDecade = await mddQuery.statSpeciesByDiscoveryDecade().get();
    final discoveryYear = await mddQuery.statSpeciesByDiscoveryYear().get();
    final extinctSpecies = await mddQuery.statExtinctSpecies().get();
    final domesticSpecies = await mddQuery.statDomesticSpecies().get();

    final rawRealm = await mddQuery.statSpeciesByBiogeographicRealm().get();
    final cleanedRealm = cleanBiogeographicRealmData(rawRealm);

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
    final topCountries = sortedCountries.take(15).toList();

    final speciesWithMostImages =
        await mddQuery.statSpeciesWithMostImages().get();

    final speciesWithMostSynonyms =
        await mddQuery.statSpeciesWithMostSynonyms().get();

    final rawTypeKind = await mddQuery.statTypeKindProportion().get();
    final cleanedTypeKind = cleanTypeKindData(rawTypeKind);

    // count might be 0, so fallback to 0
    final speciesWithImagesRow =
        await mddQuery.statSpeciesWithImagesCount().getSingle();
    final speciesWithImagesCount = speciesWithImagesRow;

    final totalSpeciesRow = await mddQuery.statTotalSpeciesCount().getSingle();
    final totalSpeciesCount = totalSpeciesRow;

    final totalOrdersCount = await mddQuery.statTotalOrdersCount().getSingle();
    final totalFamiliesCount = await mddQuery.statTotalFamiliesCount().getSingle();
    final totalGeneraCount = await mddQuery.statTotalGeneraCount().getSingle();
    final livingWildSpeciesCount = await mddQuery.statLivingWildSpeciesCount().getSingle();

    return MddStatistics(
      speciesPerOrder: speciesPerOrder,
      speciesPerFamily: speciesPerFamily,
      speciesPerGenus: speciesPerGenus,
      iucnStatus: cleanedIucn,
      discoveryDecade: discoveryDecade,
      discoveryYear: discoveryYear,
      extinctSpecies: extinctSpecies,
      domesticSpecies: domesticSpecies,
      biogeographicRealm: cleanedRealm,
      topCountries: topCountries,
      speciesWithMostImages: speciesWithMostImages,
      speciesWithImagesCount: speciesWithImagesCount,
      totalOrdersCount: totalOrdersCount,
      totalFamiliesCount: totalFamiliesCount,
      totalGeneraCount: totalGeneraCount,
      livingWildSpeciesCount: livingWildSpeciesCount,
      totalSpeciesCount: totalSpeciesCount,
      speciesWithMostSynonyms: speciesWithMostSynonyms,
      typeKindProportion: cleanedTypeKind,
    );
  }

  static List<MapEntry<String, int>> cleanIucnStatusData(
      List<StatSpeciesByIucnStatusResult> rawIucn) {
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
    return iucnCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<MapEntry<String, int>> cleanBiogeographicRealmData(
      List<StatSpeciesByBiogeographicRealmResult> rawRealm) {
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
    return realmCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<MapEntry<String, int>> cleanTypeKindData(
      List<StatTypeKindProportionResult> rawTypeKind) {
    final Map<String, int> typeKindCounts = {};
    for (var row in rawTypeKind) {
      String tkStr = row.name ?? '';
      final tks = tkStr.split('|');
      for (var t in tks) {
        t = t.trim();
        if (t.isNotEmpty && t != 'NA') {
          t = t[0].toUpperCase() + t.substring(1).toLowerCase();
          typeKindCounts[t] = (typeKindCounts[t] ?? 0) + row.count;
        }
      }
    }
    return typeKindCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
}

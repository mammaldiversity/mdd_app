import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/taxon_tree.dart';

/// Identifies a higher taxon, e.g. `(rank: TaxonRank.family, name: 'Muridae')`.
typedef TaxonKey = ({TaxonRank rank, String name});

/// Ranks that have their own column, in classification order. Species are
/// leaves, so they are not listed here.
const List<TaxonRank> classificationRanks = [
  TaxonRank.subclass,
  TaxonRank.infraclass,
  TaxonRank.magnorder,
  TaxonRank.superorder,
  TaxonRank.order,
  TaxonRank.suborder,
  TaxonRank.infraorder,
  TaxonRank.parvorder,
  TaxonRank.superfamily,
  TaxonRank.family,
  TaxonRank.subfamily,
  TaxonRank.tribe,
  TaxonRank.genus,
  TaxonRank.subgenus,
];

/// The value of [rank] for a species, or null when it is blank or `NA`.
String? rankValue(TaxonomyData row, TaxonRank rank) {
  final String? value = switch (rank) {
    TaxonRank.subclass => row.subclass,
    TaxonRank.infraclass => row.infraclass,
    TaxonRank.magnorder => row.magnorder,
    TaxonRank.superorder => row.superorder,
    TaxonRank.order => row.taxonOrder,
    TaxonRank.suborder => row.suborder,
    TaxonRank.infraorder => row.infraorder,
    TaxonRank.parvorder => row.parvorder,
    TaxonRank.superfamily => row.superfamily,
    TaxonRank.family => row.family,
    TaxonRank.subfamily => row.subfamily,
    TaxonRank.tribe => row.tribe,
    TaxonRank.genus => row.genus,
    TaxonRank.subgenus => row.subgenus,
    TaxonRank.species => row.sciName,
  };
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty || trimmed == 'NA' ? null : trimmed;
}

/// Whether [name] is a placeholder such as `incertae sedis` (uncertain
/// placement) rather than a real taxon, so it gets no page of its own.
bool isPlaceholderTaxon(String name) =>
    name.trim().toLowerCase() == 'incertae sedis';

/// Builds the full tree below [root], with every intermediate rank a
/// species has. Ranks a species lacks are skipped, so a genus with no
/// tribe hangs directly under its subfamily, as on mammaldiversity.org.
///
/// [rows] should be in phylogenetic order. Orders keep that order; every
/// other rank is sorted alphabetically, as in the Explore tree.
List<TaxonNode> buildFullTaxonTree(List<TaxonomyData> rows, TaxonKey root) {
  final ranks = classificationRanks
      .where((rank) => rank.index > root.rank.index)
      .toList();
  return _buildLevel(rows, ranks, root.name);
}

List<TaxonNode> _buildLevel(
  List<TaxonomyData> rows,
  List<TaxonRank> ranks,
  String parentKey,
) {
  final nodes = <TaxonNode>[];
  final speciesRows = <TaxonomyData>[];
  // Groups by the first remaining rank each species has.
  final groups = <(TaxonRank, String), List<TaxonomyData>>{};
  for (final row in rows) {
    final index = ranks.indexWhere((rank) => rankValue(row, rank) != null);
    if (index == -1) {
      speciesRows.add(row);
      continue;
    }
    final rank = ranks[index];
    groups.putIfAbsent((rank, rankValue(row, rank)!), () => []).add(row);
  }

  // Map keys keep first-seen (phylogenetic) order; the position breaks
  // ties because List.sort is not stable.
  final entries = groups.entries.toList();
  final position = {for (final (i, e) in entries.indexed) e.key: i};
  // Shallower ranks first (e.g. a subfamily before a genus that has no
  // subfamily), then alphabetical except for orders.
  entries.sort((a, b) {
    final byRank = a.key.$1.index.compareTo(b.key.$1.index);
    if (byRank != 0) return byRank;
    if (a.key.$1 != TaxonRank.order) {
      final byName = a.key.$2.compareTo(b.key.$2);
      if (byName != 0) return byName;
    }
    return position[a.key]!.compareTo(position[b.key]!);
  });

  for (final entry in entries) {
    final (rank, name) = entry.key;
    final key = '$parentKey/$name';
    final remaining = ranks.sublist(ranks.indexOf(rank) + 1);
    nodes.add(
      TaxonNode(
        rank: rank,
        name: name,
        key: key,
        children: _buildLevel(entry.value, remaining, key),
      ),
    );
  }

  speciesRows.sort(
    (a, b) => (a.specificEpithet ?? '').compareTo(b.specificEpithet ?? ''),
  );
  for (final row in speciesRows) {
    nodes.add(
      TaxonNode(
        rank: TaxonRank.species,
        name: '${row.genus ?? ''} ${row.specificEpithet ?? ''}'.trim(),
        key: 'species/${row.id}',
        mddId: row.id,
        commonName: row.mainCommonName ?? '',
        isExtinct: row.extinct == 1,
      ),
    );
  }
  return nodes;
}

/// The ranks above [root] for a species in that taxon, highest first.
List<TaxonKey> taxonLineage(TaxonomyData row, TaxonRank root) {
  return [
    for (final rank in classificationRanks)
      if (rank.index < root.index && rankValue(row, rank) != null)
        (rank: rank, name: rankValue(row, rank)!),
  ];
}

/// Summary numbers for a higher taxon page.
class HigherTaxonStats {
  const HigherTaxonStats({
    required this.childCounts,
    required this.speciesCount,
    required this.extinctCount,
    required this.domesticCount,
    required this.iucnCounts,
    required this.realms,
    required this.countryCount,
    this.firstDescribed,
    this.lastDescribed,
  });

  factory HigherTaxonStats.fromRows(List<TaxonomyData> rows, TaxonRank root) {
    final childNames = <TaxonRank, Set<String>>{};
    final iucn = <String, int>{};
    final realms = <String, int>{};
    final countries = <String>{};
    int? first;
    int? last;
    for (final row in rows) {
      for (final rank in classificationRanks) {
        if (rank.index <= root.index) continue;
        final value = rankValue(row, rank);
        if (value != null) childNames.putIfAbsent(rank, () => {}).add(value);
      }
      final status = StatisticsService.normalizeIucnStatus(row.iucnStatus);
      if (status.isNotEmpty && status != 'NA') {
        iucn[status] = (iucn[status] ?? 0) + 1;
      }
      for (final realm in StatisticsService.splitDelimitedValues(
        row.biogeographicRealm,
      )) {
        realms[realm] = (realms[realm] ?? 0) + 1;
      }
      countries.addAll(
        StatisticsService.splitDelimitedValues(row.countryDistribution),
      );
      final year = row.authoritySpeciesYear;
      if (year != null && year > 0) {
        first = first == null || year < first ? year : first;
        last = last == null || year > last ? year : last;
      }
    }

    List<MapEntry<String, int>> sorted(Map<String, int> counts) =>
        counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return HigherTaxonStats(
      childCounts: {
        for (final rank in classificationRanks)
          if (childNames.containsKey(rank)) rank: childNames[rank]!.length,
      },
      speciesCount: rows.length,
      extinctCount: rows.where((row) => row.extinct == 1).length,
      domesticCount: rows.where((row) => row.domestic == 1).length,
      iucnCounts: sorted(iucn),
      realms: sorted(realms),
      countryCount: countries.length,
      firstDescribed: first,
      lastDescribed: last,
    );
  }

  /// Number of distinct taxa at each rank below the root, in rank order.
  final Map<TaxonRank, int> childCounts;
  final int speciesCount;
  final int extinctCount;
  final int domesticCount;
  final List<MapEntry<String, int>> iucnCounts;
  final List<MapEntry<String, int>> realms;
  final int countryCount;
  final int? firstDescribed;
  final int? lastDescribed;

  int get livingCount => speciesCount - extinctCount;

  /// Species assessed as Critically Endangered, Endangered, or Vulnerable.
  int get threatenedCount => iucnCounts
      .where((e) => const {'CR', 'EN', 'VU'}.contains(e.key))
      .fold(0, (sum, e) => sum + e.value);
}

/// Everything the higher taxon page shows, loaded together.
class HigherTaxonData {
  HigherTaxonData({required this.taxon, required this.rows})
    : tree = buildFullTaxonTree(rows, taxon),
      stats = HigherTaxonStats.fromRows(rows, taxon.rank),
      lineage = rows.isEmpty ? const [] : taxonLineage(rows.first, taxon.rank);

  final TaxonKey taxon;
  final List<TaxonomyData> rows;
  final List<TaxonNode> tree;
  final HigherTaxonStats stats;
  final List<TaxonKey> lineage;
}

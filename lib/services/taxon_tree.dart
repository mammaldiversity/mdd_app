import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/species_list.dart';

enum TaxonRank { order, family, genus, species }

/// A node in the Order → Family → Genus → Species tree shown on the
/// Explore page.
class TaxonNode {
  TaxonNode({
    required this.rank,
    required this.name,
    required this.key,
    this.mddId,
    this.commonName = '',
    this.isExtinct = false,
    this.children = const [],
  }) : speciesCount = children.isEmpty
           ? 1
           : children.fold(0, (sum, child) => sum + child.speciesCount);

  final TaxonRank rank;
  final String name;

  /// Unique path key (e.g. `Carnivora/Felidae/Panthera`) used for
  /// expansion state.
  final String key;
  final int? mddId;
  final String commonName;
  final bool isExtinct;
  final List<TaxonNode> children;
  final int speciesCount;

  bool get hasChildren => children.isNotEmpty;

  bool get isItalic => rank == TaxonRank.genus || rank == TaxonRank.species;

  String get rankLabel {
    switch (rank) {
      case TaxonRank.order:
        return 'Order';
      case TaxonRank.family:
        return 'Family';
      case TaxonRank.genus:
        return 'Genus';
      case TaxonRank.species:
        return isExtinct ? 'Extinct species' : 'Living species';
    }
  }
}

/// Builds the taxon tree. Orders keep database order (the phylogenetic
/// sequence); every rank below order is sorted alphabetically.
List<TaxonNode> buildTaxonTree(
  List<MddGroupListResult> taxonList,
  Map<int, TreeSpeciesData> speciesData,
) {
  final orders = TaxonGroupService(taxonList: taxonList).groupByOrder();
  return [
    for (final order in orders.entries)
      TaxonNode(
        rank: TaxonRank.order,
        name: order.key,
        key: order.key,
        children: _buildFamilies(order.key, order.value, speciesData),
      ),
  ];
}

List<TaxonNode> _buildFamilies(
  String parentKey,
  List<MddGroupListResult> taxonList,
  Map<int, TreeSpeciesData> speciesData,
) {
  final families = TaxonGroupService(
    taxonList: taxonList,
  ).groupByFamily().entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final family in families)
      TaxonNode(
        rank: TaxonRank.family,
        name: family.key,
        key: '$parentKey/${family.key}',
        children: _buildGenera(
          '$parentKey/${family.key}',
          family.value,
          speciesData,
        ),
      ),
  ];
}

List<TaxonNode> _buildGenera(
  String parentKey,
  List<MddGroupListResult> taxonList,
  Map<int, TreeSpeciesData> speciesData,
) {
  final genera = TaxonGroupService(
    taxonList: taxonList,
  ).groupByGenus().entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final genus in genera)
      TaxonNode(
        rank: TaxonRank.genus,
        name: genus.key,
        key: '$parentKey/${genus.key}',
        children: _buildSpecies(genus.key, genus.value, speciesData),
      ),
  ];
}

List<TaxonNode> _buildSpecies(
  String genus,
  List<MddGroupListResult> taxonList,
  Map<int, TreeSpeciesData> speciesData,
) {
  final species =
      taxonList
          .map((taxon) => speciesData[taxon.id])
          .whereType<TreeSpeciesData>()
          .toList()
        ..sort((a, b) => a.specificEpithet.compareTo(b.specificEpithet));
  return [
    for (final data in species)
      TaxonNode(
        rank: TaxonRank.species,
        name: '$genus ${data.specificEpithet}',
        key: 'species/${data.id}',
        mddId: data.id,
        commonName: data.mainCommonName,
        isExtinct: data.isExtinct,
      ),
  ];
}

/// Keys of every node that has children, for "expand all".
Set<String> collectParentKeys(List<TaxonNode> nodes) {
  final keys = <String>{};
  void visit(List<TaxonNode> nodes) {
    for (final node in nodes) {
      if (node.hasChildren) {
        keys.add(node.key);
        visit(node.children);
      }
    }
  }

  visit(nodes);
  return keys;
}

/// A visible tree row, with the information needed to draw connectors.
class VisibleTaxonRow {
  const VisibleTaxonRow({
    required this.node,
    required this.depth,
    required this.isLast,
    required this.ancestorHasNext,
  });

  final TaxonNode node;
  final int depth;
  final bool isLast;

  /// For each ancestor depth (0 until depth - 1), whether that ancestor
  /// has a later sibling, so its vertical line continues past this row.
  final List<bool> ancestorHasNext;
}

/// Flattens the tree into the rows currently visible given [expanded].
List<VisibleTaxonRow> flattenVisible(
  List<TaxonNode> nodes,
  Set<String> expanded,
) {
  final rows = <VisibleTaxonRow>[];
  void visit(List<TaxonNode> nodes, int depth, List<bool> ancestors) {
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isLast = i == nodes.length - 1;
      rows.add(
        VisibleTaxonRow(
          node: node,
          depth: depth,
          isLast: isLast,
          ancestorHasNext: ancestors,
        ),
      );
      if (node.hasChildren && expanded.contains(node.key)) {
        visit(node.children, depth + 1, [...ancestors, !isLast]);
      }
    }
  }

  visit(nodes, 0, const []);
  return rows;
}

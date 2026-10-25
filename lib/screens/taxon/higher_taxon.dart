import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/screens/explore/tree_view.dart';
import 'package:mdd/screens/gallery/mil_full_screen_view.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/services/common_names.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/species_list.dart';
import 'package:mdd/services/taxon_tree.dart';

/// Opens the page for the taxon [name] at [rank], e.g. family Muridae.
void openHigherTaxonPage(BuildContext context, TaxonRank rank, String name) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => HigherTaxonPage(rank: rank, name: name),
    ),
  );
}

/// Plural rank name for counts, e.g. `genera`.
String rankPlural(TaxonRank rank) {
  switch (rank) {
    case TaxonRank.family:
      return 'families';
    case TaxonRank.subfamily:
      return 'subfamilies';
    case TaxonRank.superfamily:
      return 'superfamilies';
    case TaxonRank.genus:
      return 'genera';
    case TaxonRank.subgenus:
      return 'subgenera';
    case TaxonRank.species:
      return 'species';
    default:
      return '${rank.name}s';
  }
}

String _capitalize(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

/// A higher taxon (subclass to subgenus): photos, lineage, statistics, and
/// the full classification tree down to species.
class HigherTaxonPage extends ConsumerStatefulWidget {
  const HigherTaxonPage({super.key, required this.rank, required this.name});

  final TaxonRank rank;
  final String name;

  @override
  ConsumerState<HigherTaxonPage> createState() => _HigherTaxonPageState();
}

class _HigherTaxonPageState extends ConsumerState<HigherTaxonPage> {
  Set<String>? _expanded;

  /// Every node with children, for "expand all".
  late Set<String> _parentKeys;

  TaxonKey get _taxon => (rank: widget.rank, name: widget.name);

  void _toggle(String key) {
    setState(() {
      final expanded = _expanded!;
      expanded.contains(key) ? expanded.remove(key) : expanded.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(
            fontStyle: widget.rank.isItalic
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ),
      body: SafeArea(
        child: ref
            .watch(higherTaxonProvider(_taxon))
            .when(
              data: (data) {
                if (data.rows.isEmpty) {
                  return Center(
                    child: Text('No species found in ${widget.name}.'),
                  );
                }
                // Start with the top level open, so the page shows the
                // ranks right below this taxon.
                if (_expanded == null) {
                  _parentKeys = collectParentKeys(data.tree);
                  _expanded = {
                    for (final node in data.tree)
                      if (node.hasChildren) node.key,
                  };
                }
                return _buildLayout(context, data);
              },
              loading: () => const SimpleLoadingOnly(),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
            ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, HigherTaxonData data) {
    final tree = data.tree;
    final rows = flattenVisible(tree, _expanded!);
    final summary = _TaxonSummary(taxon: _taxon, data: data);
    final treeHeader = _TreeHeader(
      rootName: widget.name,
      isItalic: widget.rank.isItalic,
      isAllExpanded:
          _parentKeys.isNotEmpty && _expanded!.containsAll(_parentKeys),
      onExpandToggle: () => setState(() {
        _expanded = _expanded!.containsAll(_parentKeys) ? {} : {..._parentKeys};
      }),
    );
    final treeSliver = _TreeSliver(
      header: treeHeader,
      rows: rows,
      expanded: _expanded!,
      onToggle: _toggle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: summary,
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: treeSliver,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(child: summary),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: treeSliver,
            ),
          ],
        );
      },
    );
  }
}

/// Photos, name, lineage, statistics, and status for a taxon.
class _TaxonSummary extends StatelessWidget {
  const _TaxonSummary({required this.taxon, required this.data});

  final TaxonKey taxon;
  final HigherTaxonData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PhotoHero(taxon: taxon, data: data),
        const SizedBox(height: 12),
        _TaxonTitle(taxon: taxon),
        const SizedBox(height: 8),
        _LineageLadder(lineage: data.lineage, taxon: taxon),
        const SizedBox(height: 12),
        _StatTiles(stats: data.stats),
        const SizedBox(height: 12),
        _StatusCard(stats: data.stats),
      ],
    );
  }
}

class _PhotoHero extends ConsumerWidget {
  const _PhotoHero({required this.taxon, required this.data});

  final TaxonKey taxon;
  final HigherTaxonData data;

  void _open(
    BuildContext context,
    List<RandomMilImagesWithTaxonomyResult> images,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            MilFullScreenView(milItem: images[index], initialImages: images),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(higherTaxonImagesProvider(taxon)).value;
    if (images == null) {
      return const AspectRatio(aspectRatio: 3 / 2, child: SizedBox());
    }
    if (images.isEmpty) return _NoPhotos(order: data.rows.first.taxonOrder);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hero = images.first;
    final thumbnails = images.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: GestureDetector(
              onTap: () => _open(context, images, 0),
              child: Image.asset(
                'assets/mil-images/${hero.milId}.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${hero.genus ?? ''} ${hero.specificEpithet ?? ''}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                if (hero.photographer != null && hero.photographer!.isNotEmpty)
                  TextSpan(text: ' · © ${hero.photographer}'),
              ],
            ),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (thumbnails.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: thumbnails.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final image = thumbnails[index];
                return Tooltip(
                  message:
                      '${image.genus ?? ''} ${image.specificEpithet ?? ''}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _open(context, images, index + 1),
                      child: Image.asset(
                        'assets/mil-images/${image.milId}.webp',
                        width: 88,
                        height: 64,
                        fit: BoxFit.cover,
                        cacheWidth: 264,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 88),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Shown when no species in the taxon has a photo: the order's icon.
class _NoPhotos extends StatelessWidget {
  const _NoPhotos({required this.order});

  final String? order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: order == null
          ? Icon(Icons.pets, size: 48, color: colorScheme.primary)
          : SvgPicture.asset(
              'assets/order-icons/${order!.toLowerCase()}.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                colorScheme.primary,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (context) =>
                  Icon(Icons.pets, size: 48, color: colorScheme.primary),
            ),
    );
  }
}

class _TaxonTitle extends StatelessWidget {
  const _TaxonTitle({required this.taxon});

  final TaxonKey taxon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final commonName = taxon.rank == TaxonRank.order
        ? MammalianOrders().getCommonName(taxon.name)
        : '';
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taxon.rank.label,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            taxon.name,
            style: textTheme.headlineSmall?.copyWith(
              fontFamily: 'Libre Baskerville',
              fontStyle: taxon.rank.isItalic
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
          if (commonName.isNotEmpty)
            Text(
              commonName,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// The ranks above this taxon as an indented ladder, ending with the
/// taxon itself. Each higher rung opens that taxon's page.
class _LineageLadder extends StatelessWidget {
  const _LineageLadder({required this.lineage, required this.taxon});

  final List<TaxonKey> lineage;
  final TaxonKey taxon;

  static const double _indent = 12;

  @override
  Widget build(BuildContext context) {
    final rungs = [...lineage, taxon];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, rung) in rungs.indexed)
          _LadderRung(
            taxon: rung,
            indent: index * _indent,
            isCurrent: index == rungs.length - 1,
          ),
      ],
    );
  }
}

class _LadderRung extends StatelessWidget {
  const _LadderRung({
    required this.taxon,
    required this.indent,
    required this.isCurrent,
  });

  final TaxonKey taxon;
  final double indent;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final row = Padding(
      padding: EdgeInsets.fromLTRB(indent, 3, 8, 3),
      child: Row(
        children: [
          Icon(
            isCurrent
                ? Icons.radio_button_checked
                : Icons.subdirectory_arrow_right,
            size: 16,
            color: isCurrent ? colorScheme.primary : colorScheme.outline,
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 84,
            child: Text(
              taxon.rank.label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              taxon.name,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: isCurrent
                    ? colorScheme.onSurface
                    : isPlaceholderTaxon(taxon.name)
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
                fontWeight: isCurrent ? FontWeight.bold : null,
                fontStyle: taxon.rank.isItalic
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
    if (isCurrent || isPlaceholderTaxon(taxon.name)) return row;
    return Semantics(
      button: true,
      label: 'Open ${taxon.rank.label.toLowerCase()} ${taxon.name}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => openHigherTaxonPage(context, taxon.rank, taxon.name),
        child: row,
      ),
    );
  }
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.stats});

  final HigherTaxonStats stats;

  @override
  Widget build(BuildContext context) {
    // Candidates in priority order; the first four become tiles, so a
    // genus without subgenera still gets a full grid.
    final candidates = <StatCard>[];
    if (stats.childCounts.isNotEmpty) {
      final firstRank = stats.childCounts.keys.first;
      candidates.add(
        StatCard(
          title: _capitalize(rankPlural(firstRank)),
          count: stats.childCounts[firstRank]!,
        ),
      );
      if (firstRank != TaxonRank.genus &&
          stats.childCounts.containsKey(TaxonRank.genus)) {
        candidates.add(
          StatCard(title: 'Genera', count: stats.childCounts[TaxonRank.genus]!),
        );
      }
    }
    candidates.addAll([
      StatCard(title: 'Living species', count: stats.livingCount),
      StatCard(title: 'Extinct species', count: stats.extinctCount),
      StatCard(title: 'Countries', count: stats.countryCount),
      StatCard(
        title: 'Threatened',
        count: stats.threatenedCount,
        tooltip: 'Critically Endangered, Endangered, or Vulnerable',
      ),
    ]);
    final tiles = candidates.take(4).toList();
    final hasCountryTile = tiles.any((tile) => tile.title == 'Countries');

    final colorScheme = Theme.of(context).colorScheme;
    final facts = [
      if (stats.firstDescribed != null)
        stats.firstDescribed == stats.lastDescribed
            ? 'Described in ${stats.firstDescribed}'
            : 'Described ${stats.firstDescribed}–${stats.lastDescribed}',
      if (!hasCountryTile && stats.countryCount > 0)
        'Found in ${StatCard.formatCount(stats.countryCount)} '
            '${stats.countryCount == 1 ? 'country' : 'countries'}',
      if (stats.domesticCount > 0) '${stats.domesticCount} domesticated',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 520 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 4) / columns;
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final tile in tiles) SizedBox(width: width, child: tile),
              ],
            );
          },
        ),
        if (facts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              facts.join(' · '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// IUCN status bar with a legend, and the biogeographic realms.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.stats});

  final HigherTaxonStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iucn = stats.iucnCounts;
    return CommonCard(
      title: 'Conservation and range',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IUCN Red List status',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            if (iucn.isEmpty)
              Text('No assessments', style: textTheme.bodyMedium)
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      for (final entry in iucn)
                        Expanded(
                          flex: entry.value,
                          child: Tooltip(
                            message:
                                '${matchIUCNStatus(entry.key)}: ${entry.value}',
                            child: Container(
                              color: ChartPalette.getIucnColor(
                                entry.key,
                                context,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final entry in iucn)
                    Tooltip(
                      message: matchIUCNStatus(entry.key),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: ChartPalette.getIucnColor(
                                entry.key,
                                context,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.key} ${entry.value}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if (stats.realms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Biogeographic realms',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final realm in stats.realms)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${realm.key} · ${realm.value}'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TreeHeader extends StatelessWidget {
  const _TreeHeader({
    required this.rootName,
    required this.isItalic,
    required this.isAllExpanded,
    required this.onExpandToggle,
  });

  final String rootName;
  final bool isItalic;
  final bool isAllExpanded;
  final VoidCallback onExpandToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Full classification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: isAllExpanded ? 'Collapse all' : 'Expand all',
                onPressed: onExpandToggle,
                icon: Icon(
                  isAllExpanded ? Icons.unfold_less : Icons.unfold_more,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            rootName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// The classification tree in a card, as lazily built slivers so large
/// orders such as Rodentia scroll smoothly.
class _TreeSliver extends StatelessWidget {
  const _TreeSliver({
    required this.header,
    required this.rows,
    required this.expanded,
    required this.onToggle,
  });

  final Widget header;
  final List<VisibleTaxonRow> rows;
  final Set<String> expanded;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(120),
          width: 1,
        ),
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12),
            sliver: SliverList.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return TaxonTreeRow(
                  key: ValueKey(row.node.key),
                  row: row,
                  isExpanded: expanded.contains(row.node.key),
                  onToggle: onToggle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

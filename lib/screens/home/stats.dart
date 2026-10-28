import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/screens/statistics/country_table_page.dart';
import 'package:mdd/screens/statistics/page.dart';
import 'package:mdd/screens/statistics/synonym_table_page.dart';
import 'package:mdd/screens/taxon/higher_taxon.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/navigation.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/taxon_tree.dart';

/// Content width from which the home screen sets sections side by side.
const double wideLayoutMinWidth = 840;

/// The home screen dashboard below the search bar: species composition,
/// tiles that open the statistics tables, and a row of orders that open
/// their taxon pages.
class MddStatistics extends ConsumerWidget {
  const MddStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(statisticsProvider)
        .when(
          data: (stats) {
            final recentlyExtinctCount = stats.extinctSpecies
                .firstWhere(
                  (e) => e.isExtinct == 1,
                  orElse: () =>
                      StatExtinctSpeciesResult(isExtinct: 1, count: 0),
                )
                .count;
            final domesticCount = stats.domesticSpecies
                .firstWhere(
                  (e) => e.isDomestic == 1,
                  orElse: () =>
                      StatDomesticSpeciesResult(isDomestic: 1, count: 0),
                )
                .count;
            final orderSequence = ref.watch(orderSequenceProvider).value;
            final countryCount = ref
                .watch(countryDiversityStatsProvider)
                .value
                ?.length;

            final speciesCard = _SpeciesSummaryCard(
              total: stats.totalSpeciesCount,
              livingWild: stats.livingWildSpeciesCount,
              domestic: domesticCount,
              recentlyExtinct: recentlyExtinctCount,
            );
            final tiles = [
              _DashboardTile(
                title: 'Orders',
                value: StatCard.formatCount(stats.totalOrdersCount),
                onTap: () => _open(context, orderTablePage(stats)),
              ),
              _DashboardTile(
                title: 'Families',
                value: StatCard.formatCount(stats.totalFamiliesCount),
                onTap: () => _open(context, familyTablePage(stats)),
              ),
              _DashboardTile(
                title: 'Genera',
                value: StatCard.formatCount(stats.totalGeneraCount),
                onTap: () => _open(context, genusTablePage(stats)),
              ),
              _DashboardTile(
                title: 'Synonyms',
                value: StatCard.formatCount(stats.totalSynonymsCount),
                onTap: () => _open(context, const SynonymTablePage()),
              ),
              _DashboardTile(
                title: 'Images',
                value: StatCard.formatCount(stats.totalImagesCount),
                actionLabel: 'Open image gallery',
                onTap: () => ref
                    .read(selectedPageProvider.notifier)
                    .select(galleryPageIndex),
              ),
              _DashboardTile(
                title: 'Countries',
                value: countryCount == null
                    ? '…'
                    : StatCard.formatCount(countryCount),
                onTap: () => _open(context, const CountryTablePage()),
              ),
            ];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mammal Diversity Statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Wide screens put the species card beside the tiles.
                      if (constraints.maxWidth < wideLayoutMinWidth) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            speciesCard,
                            const SizedBox(height: 8),
                            _TileGrid(tiles: tiles),
                          ],
                        );
                      }
                      // Both sides take the height of the taller one.
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 2, child: speciesCard),
                            const SizedBox(width: _TileGrid.gap),
                            Expanded(
                              flex: 3,
                              child: _StretchedTileGrid(
                                tiles: tiles,
                                columns: 3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _OrderBrowser(
                    orders: stats.speciesPerOrder,
                    sequence: orderSequence,
                  ),
                ],
              ),
            );
          },
          loading: () => const SimpleLoadingMessages(),
          error: (error, stack) => Text('Error: $error'),
        );
  }

  void _open(BuildContext context, Widget page) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => page));
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    this.count = 0,
    this.display,
    this.leading,
    this.onTap,
    this.tooltip,
  });

  final String title;
  final int count;

  /// Shown in place of [count], for values such as "2.30 Gb".
  final String? display;

  /// An icon above the value.
  final Widget? leading;

  /// Makes the card a button, e.g. to open the records it counts.
  final VoidCallback? onTap;
  final String? tooltip;

  static String formatCount(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          if (leading != null) ...[leading!, const SizedBox(height: 6)],
          Text(
            display ?? formatCount(count),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      child: onTap == null
          ? content
          : Tooltip(
              message: tooltip ?? '',
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

class SpeciesSubStats extends StatelessWidget {
  const SpeciesSubStats({
    super.key,
    required this.label,
    this.value = 0,
    this.display,
    this.swatch,
  });

  final String label;
  final int value;

  /// Shown in place of [value], for values such as "41.5%".
  final String? display;

  /// A colour key drawn before the label, e.g. for a chart category.
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(90),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            display ?? StatCard.formatCount(value),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatch != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: swatch,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Total species with a bar of living wild, domestic, and recently extinct.
class _SpeciesSummaryCard extends StatelessWidget {
  const _SpeciesSummaryCard({
    required this.total,
    required this.livingWild,
    required this.domestic,
    required this.recentlyExtinct,
  });

  final int total;
  final int livingWild;
  final int domestic;
  final int recentlyExtinct;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final segments = [
      (
        label: 'living wild',
        count: livingWild,
        color: ChartPalette.getDomesticColors(context).wild,
      ),
      (
        label: 'domestic',
        count: domestic,
        color: ChartPalette.getDomesticColors(context).domestic,
      ),
      (
        label: 'recently extinct',
        count: recentlyExtinct,
        color: ChartPalette.getExtinctColors(context).extinct,
      ),
    ];
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Species',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              StatCard.formatCount(total),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            _CompositionBar(
              segments: [for (final s in segments) (s.count, s.color)],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final s in segments)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${StatCard.formatCount(s.count)} ${s.label}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A stacked bar. Every non-empty segment gets at least a few pixels, so
/// small groups such as the 17 domestic species stay visible.
class _CompositionBar extends StatelessWidget {
  const _CompositionBar({required this.segments});

  final List<(int, Color)> segments;

  @override
  Widget build(BuildContext context) {
    // Painted rather than laid out, so the bar can sit inside
    // IntrinsicHeight on wide screens.
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: CustomPaint(
        size: const Size.fromHeight(10),
        painter: _CompositionBarPainter(segments),
      ),
    );
  }
}

class _CompositionBarPainter extends CustomPainter {
  _CompositionBarPainter(this.segments);

  final List<(int, Color)> segments;

  static const double _minWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0, (sum, s) => sum + s.$1);
    if (total == 0) return;
    final widths = [
      for (final (count, _) in segments)
        count == 0 ? 0.0 : math.max(_minWidth, size.width * count / total),
    ];
    // Take the extra minimum width back from the largest segment.
    final overflow = widths.fold(0.0, (a, b) => a + b) - size.width;
    final largest = widths.indexOf(widths.reduce(math.max));
    widths[largest] -= overflow;
    var left = 0.0;
    for (final (index, (_, color)) in segments.indexed) {
      canvas.drawRect(
        Rect.fromLTWH(left, 0, widths[index], size.height),
        Paint()..color = color,
      );
      left += widths[index];
    }
  }

  @override
  bool shouldRepaint(_CompositionBarPainter oldDelegate) =>
      oldDelegate.segments != segments;
}

/// Tiles in fixed rows that stretch to fill the height they are given, for
/// sitting beside the species card.
class _StretchedTileGrid extends StatelessWidget {
  const _StretchedTileGrid({required this.tiles, required this.columns});

  final List<Widget> tiles;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < tiles.length; i += columns)
        tiles.sublist(i, math.min(i + columns, tiles.length)),
    ];
    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: _TileGrid.gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (column, tile) in row.indexed) ...[
                  if (column > 0) const SizedBox(width: _TileGrid.gap),
                  Expanded(child: tile),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Lays tiles out three per row on phones and six on wider screens.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<Widget> tiles;

  static const double gap = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 6 : 3;
        final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

/// A count that opens its table, marked with a chevron so it reads as a
/// button.
class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.value,
    required this.onTap,
    this.actionLabel = 'Open table',
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  /// What tapping does, read out by screen readers.
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DashboardCard(
      child: Semantics(
        button: true,
        label: '$title, $value. $actionLabel',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Orders in phylogenetic sequence, each opening its taxon page.
/// Phones scroll them sideways; wider screens wrap them into rows, two at
/// first.
class _OrderBrowser extends StatefulWidget {
  const _OrderBrowser({required this.orders, this.sequence});

  final List<StatSpeciesPerOrderResult> orders;

  /// Order names in display order. Until it loads, [orders] keep their
  /// largest-first order.
  final List<String>? sequence;

  @override
  State<_OrderBrowser> createState() => _OrderBrowserState();
}

class _OrderBrowserState extends State<_OrderBrowser> {
  static const double _tileWidth = 92;
  static const double _gap = 4;
  static const int _collapsedRows = 2;

  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final named = [
      for (final order in widget.orders)
        if (order.name != null && order.name!.isNotEmpty) order,
    ];
    final sequence = widget.sequence;
    if (sequence != null) {
      final position = {
        for (final (index, name) in sequence.indexed) name: index,
      };
      // Orders missing from the sequence go last; sort is stable.
      named.sort(
        (a, b) => (position[a.name] ?? sequence.length).compareTo(
          position[b.name] ?? sequence.length,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wrap = constraints.maxWidth >= 600;
        final perRow = ((constraints.maxWidth + _gap) / (_tileWidth + _gap))
            .floor();
        final collapsedCount = perRow * _collapsedRows;
        final canCollapse = wrap && named.length > collapsedCount;
        final visible = canCollapse && !_showAll
            ? named.take(collapsedCount).toList()
            : named;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Browse by order',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (canCollapse)
                  TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    child: Text(
                      _showAll ? 'Show fewer' : 'Show all ${named.length}',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (wrap)
              Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: [
                  for (final order in visible) _OrderTile(order: order),
                ],
              )
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: named.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: _gap),
                  itemBuilder: (context, index) =>
                      _OrderTile(order: named[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// An order's icon, name, and species count, opening its taxon page.
class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final StatSpeciesPerOrderResult order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = order.name!;
    return Semantics(
      button: true,
      label: 'Order $name',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openHigherTaxonPage(context, TaxonRank.order, name),
        child: SizedBox(
          width: _OrderBrowserState._tileWidth,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SvgPicture.asset(
                    'assets/order-icons/${name.toLowerCase()}.svg',
                    colorFilter: ColorFilter.mode(
                      colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (context) =>
                        Icon(Icons.pets, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The card surface shared by the dashboard pieces.
class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

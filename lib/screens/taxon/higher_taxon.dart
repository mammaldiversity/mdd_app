import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/screens/explore/tree_view.dart';
import 'package:mdd/screens/gallery/mil_full_screen_view.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/search/fields.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/shared/maps/map_controls.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/screens/taxon/distribution_map.dart';
import 'package:mdd/screens/taxon/external_resources.dart';
import 'package:mdd/services/common_names.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/distribution_map_style.dart';
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

  /// The wide layout's open tab.
  _Section _section = _Section.classification;

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
          return _buildWideLayout(context, data, treeSliver);
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

  /// Desktop: the taxon's summary in a full-width band, then the
  /// classification, distribution and publications in tabs, so neither
  /// side of the page runs on far past the other.
  Widget _buildWideLayout(
    BuildContext context,
    HigherTaxonData data,
    Widget treeSliver,
  ) {
    final sections = [
      _Section.classification,
      _Section.distribution,
      _Section.publications,
    ];
    final Widget body = switch (_section) {
      _Section.classification => treeSliver,
      _Section.distribution => SliverToBoxAdapter(
        child: _SpeciesHeatmapCard(taxon: _taxon, mapHeight: 480),
      ),
      _Section.publications => SliverToBoxAdapter(
        child: CrossrefPublicationsCard(
          name: widget.name,
          isItalic: widget.rank.isItalic,
        ),
      ),
    };
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _HeaderBand(taxon: _taxon, data: data),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTabs(
                  sections: sections,
                  current: _section,
                  onChanged: (section) => setState(() => _section = section),
                ),
              ),
            ),
            SliverPadding(padding: const EdgeInsets.all(16), sliver: body),
          ],
        ),
      ),
    );
  }
}

/// Photos beside the name, lineage, statistics, and status.
class _HeaderBand extends StatelessWidget {
  const _HeaderBand({required this.taxon, required this.data});

  final TaxonKey taxon;
  final HigherTaxonData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(120)),
      ),
      // The details set the band's height and the photos fill it, so both
      // columns end together and the export button closes the corner.
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double gap = 24;
          final double photoWidth = (constraints.maxWidth - gap) * 2 / 5;
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: photoWidth + gap),
                child: ConstrainedBox(
                  // Never shorter than a 3:2 photo.
                  constraints: BoxConstraints(minHeight: photoWidth * 2 / 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TaxonTitle(taxon: taxon),
                      const SizedBox(height: 4),
                      _LineageTrail(lineage: data.lineage),
                      const SizedBox(height: 12),
                      _StatTiles(stats: data.stats),
                      const SizedBox(height: 12),
                      _StatusCard(stats: data.stats),
                      const SizedBox(height: 12),
                      _ExportDatasetButton(
                        taxon: taxon,
                        data: data,
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: photoWidth,
                child: _PhotoHero(taxon: taxon, data: data, fillHeight: true),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The ranks above a taxon on one line, e.g. Rodentia › Myomorpha. Each
/// opens that taxon's page.
class _LineageTrail extends StatelessWidget {
  const _LineageTrail({required this.lineage});

  final List<TaxonKey> lineage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rungs = [
      for (final rung in lineage)
        if (!isPlaceholderTaxon(rung.name)) rung,
    ];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (index, rung) in rungs.indexed) ...[
          if (index > 0)
            ExcludeSemantics(
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: colorScheme.outline,
              ),
            ),
          Tooltip(
            message: rung.rank.label,
            child: Semantics(
              button: true,
              label: 'Open ${rung.rank.label.toLowerCase()} ${rung.name}',
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => openHigherTaxonPage(context, rung.rank, rung.name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    rung.name,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontStyle: rung.rank.isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum _Section {
  classification('Classification'),
  distribution('Distribution'),
  publications('Publications');

  const _Section(this.label);

  final String label;
}

/// The section tabs under the header band.
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.sections,
    required this.current,
    required this.onChanged,
  });

  final List<_Section> sections;
  final _Section current;
  final ValueChanged<_Section> onChanged;

  @override
  Widget build(BuildContext context) {
    final int index = sections.indexOf(current);
    return DefaultTabController(
      // Rebuilt with the page's tab, so the indicator always matches.
      key: ValueKey(index),
      length: sections.length,
      initialIndex: index,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (index) => onChanged(sections[index]),
        tabs: [for (final section in sections) Tab(text: section.label)],
      ),
    );
  }
}

/// Living species per country as a heatmap, with the countries holding the
/// most and a note on predicted records.
class _SpeciesHeatmapCard extends ConsumerWidget {
  const _SpeciesHeatmapCard({required this.taxon, this.mapHeight = 300});

  final TaxonKey taxon;
  final double mapHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonCard(
      title: 'Species by country',
      description:
          'Living species recorded in each country. A general overview: '
          'many species live in only part of a country.',
      child: ref
          .watch(higherTaxonHeatmapProvider(taxon))
          .when(
            data: (heatmap) => heatmap.counts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text('No country records for living species.'),
                  )
                : _heatmap(context, heatmap),
            loading: () => SizedBox(
              height: mapHeight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Unable to load the map.'),
            ),
          ),
    );
  }

  Widget _heatmap(BuildContext context, CountryHeatmap heatmap) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = DistributionMapStyleService.heatColors(
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
    final scale = heatmap.scale;
    final counts = heatmap.counts;
    final TextStyle? muted = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Species per country', style: muted),
              for (int level = 0; level < scale.levels; level++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[level],
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: colors.last, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(scale.label(level), style: textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // No wider than 2:1, the shape of the inhabited world, so a taxon
        // found on most continents fills the map once instead of repeating
        // it side by side.
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: mapHeight * 2),
            child: SizedBox(
              height: mapHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DistributionMapView(
                  data: heatmap.data,
                  levelColors: colors,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: const RecenterHint(subject: 'Countries'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Most species',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final MapEntry(key: country, value: total) in counts.top(8))
                Tooltip(
                  message: _countBreakdown(counts.byCountry[country]!),
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('$country · $total'),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _predictedNote(counts.predictedRecords),
                  style: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _countBreakdown(({int known, int predicted}) count) =>
    count.predicted == 0
    ? '${count.known} confirmed'
    : '${count.known} confirmed, ${count.predicted} predicted';

/// Explains predicted records, which the counts include.
String _predictedNote(int predictedRecords) {
  const String meaning =
      'A predicted record (marked "?" in MDD) is a country where a species '
      'is expected to occur but has not been confirmed.';
  if (predictedRecords == 0) {
    return 'No predicted records: every count is a confirmed record.';
  }
  final String records = predictedRecords == 1
      ? '1 predicted record'
      : '${StatCard.formatCount(predictedRecords)} predicted records';
  return 'Counts include $records. $meaning Open a species to see its '
      'predicted range.';
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
        const SizedBox(height: 12),
        _ExportDatasetButton(taxon: taxon, data: data),
        const SizedBox(height: 12),
        _SpeciesHeatmapCard(taxon: taxon),
        const SizedBox(height: 12),
        CrossrefPublicationsCard(
          name: taxon.name,
          isItalic: taxon.rank.isItalic,
        ),
      ],
    );
  }
}

class _PhotoHero extends ConsumerWidget {
  const _PhotoHero({
    required this.taxon,
    required this.data,
    this.fillHeight = false,
  });

  final TaxonKey taxon;
  final HigherTaxonData data;

  /// Stretches the main photo to the height it is given, cropping it,
  /// instead of keeping it at 3:2.
  final bool fillHeight;

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
      return fillHeight
          ? const SizedBox.expand()
          : const AspectRatio(aspectRatio: 3 / 2, child: SizedBox());
    }
    if (images.isEmpty) {
      return _NoPhotos(
        order: data.rows.first.taxonOrder,
        height: fillHeight ? double.infinity : 120,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hero = images.first;
    final thumbnails = images.skip(1).toList();
    final Widget photo = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () => _open(context, images, 0),
        child: Image.asset(
          'assets/mil-images/${hero.milId}.webp',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fillHeight)
          // Takes the height left over, but no taller than square: past
          // that the crop loses most of the animal, so the column ends
          // short instead.
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  SizedBox(height: constraints.maxWidth, child: photo),
            ),
          )
        else
          AspectRatio(aspectRatio: 3 / 2, child: photo),
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
  const _NoPhotos({required this.order, this.height = 120});

  final String? order;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        // A step above the cards it sits in, so its edge shows.
        color: colorScheme.surfaceContainer,
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

/// Exports every species in the taxon, and optionally their synonyms.
class _ExportDatasetButton extends StatelessWidget {
  const _ExportDatasetButton({
    required this.taxon,
    required this.data,
    this.alignment = Alignment.centerLeft,
  });

  final TaxonKey taxon;
  final HigherTaxonData data;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SpeciesExportButton(
        mddIDs: [for (final row in data.rows) row.id],
        label: 'Export dataset',
        tooltip:
            'Export ${StatCard.formatCount(data.rows.length)} species, '
            'with their synonyms if you choose',
        fileName: taxon.name,
      ),
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

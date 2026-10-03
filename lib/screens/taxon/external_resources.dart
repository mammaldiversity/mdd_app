import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/shared/maps/map_controls.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/taxon/gbif_map.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/providers/external_resources.dart';
import 'package:mdd/services/species_list.dart';
import 'package:mdd/services/system.dart';

const String externalResourcesDescription =
    'Explore this species in public databases.';

/// The note above external data, naming where it comes from.
String externalDataNote(String provider) =>
    'Fetched automatically from $provider and not curated by the MDD team. '
    'Its taxonomy may differ from MDD.';

const String gbifUnnaturalRangeNote =
    'Some records may come from outside the natural range, such as captive '
    'animals in zoos.';

/// Tiles switch from a row to a stacked column below this width.
const double _kTileRowMinWidth = 480;

enum ExternalResource {
  occurrences(
    title: 'Occurrences',
    source: 'GBIF',
    description: 'Record count and density map',
    sheetTitle: 'Species occurrences · GBIF',
    provider: 'GBIF',
    icon: ResourceIcon.occurrences,
  ),
  genetics(
    title: 'Genetics',
    source: 'GenBank',
    description: 'Genomes, genes and sequences',
    sheetTitle: 'Genetic data · GenBank',
    provider: 'NCBI (GenBank and Datasets)',
    icon: ResourceIcon.genetics,
  ),
  publications(
    title: 'Publications',
    source: 'Crossref',
    description: 'Papers naming this species',
    sheetTitle: 'Publications · Crossref',
    provider: 'Crossref',
    icon: ResourceIcon.publications,
  );

  const ExternalResource({
    required this.title,
    required this.source,
    required this.description,
    required this.sheetTitle,
    required this.provider,
    required this.icon,
  });

  final String title;
  final String source;
  final String description;
  final String sheetTitle;

  /// Every service the data is fetched from, for the data note.
  final String provider;
  final ResourceIcon icon;
}

/// Duotone icons on a 24 grid: a tinted body in the secondary colour under
/// solid marks in the primary colour (the pin on a map, a title block on a
/// page, the bands on a chromosome).
enum ResourceIcon {
  occurrences,
  genetics,
  publications,
  chromosome,
  gene,
  mitogenome,
  sequences;

  String get asset => 'assets/resource-icons/$name.svg';

  static ResourceIcon forRecord(GenBankRecord record) => switch (record) {
    GenBankRecord.assemblies => chromosome,
    GenBankRecord.genes => gene,
    GenBankRecord.mitochondrial => mitogenome,
    GenBankRecord.nucleotide => sequences,
  };
}

/// Maps the SVGs' placeholder colours (black for the marks, grey for the
/// tinted body) to theme colours.
class _ResourceIconColors extends ColorMapper {
  const _ResourceIconColors(this.primary, this.secondary);

  final Color primary;
  final Color secondary;

  static const Color _primaryKey = Color(0xFF000000);
  static const Color _secondaryKey = Color(0xFF808080);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _primaryKey) return primary;
    if (color == _secondaryKey) return secondary;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _ResourceIconColors &&
      other.primary == primary &&
      other.secondary == secondary;

  @override
  int get hashCode => Object.hash(primary, secondary);
}

/// A resource icon on a soft gradient tile.
class ResourceIconBadge extends StatelessWidget {
  const ResourceIconBadge({super.key, required this.icon, this.size = 44});

  final ResourceIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? colorScheme.onSurface : colorScheme.primary;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withAlpha(isDark ? 60 : 30),
            colorScheme.secondary.withAlpha(isDark ? 60 : 30),
          ],
        ),
      ),
      child: SvgPicture.asset(
        icon.asset,
        colorMapper: _ResourceIconColors(primary, colorScheme.secondary),
      ),
    );
  }
}

class ExternalResourcesPanel extends StatelessWidget {
  const ExternalResourcesPanel({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    final String speciesName = SpeciesText(taxonData: taxonData).speciesName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CommonCard(
        title: 'External resources',
        description: externalResourcesDescription,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isRow = constraints.maxWidth >= _kTileRowMinWidth;
              final List<Widget> tiles = [
                for (final resource in ExternalResource.values)
                  _ResourceTile(
                    resource: resource,
                    isCompact: !isRow,
                    onTap: () => showExternalResource(
                      context,
                      speciesName: speciesName,
                      countryDistribution: taxonData.countryDistribution,
                      resource: resource,
                    ),
                  ),
              ];
              if (isRow) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, tile) in tiles.indexed) ...[
                        if (index > 0) const SizedBox(width: 8),
                        Expanded(child: tile),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final (index, tile) in tiles.indexed) ...[
                    if (index > 0) const SizedBox(height: 8),
                    tile,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.resource,
    required this.isCompact,
    required this.onTap,
  });

  final ExternalResource resource;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color muted = colorScheme.onSurfaceVariant;
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          resource.title,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          resource.description,
          style: textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
    final Widget source = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(140),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        resource.source,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Material(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(120)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: isCompact
              ? Row(
                  children: [
                    ResourceIconBadge(icon: resource.icon),
                    const SizedBox(width: 12),
                    Expanded(child: text),
                    const SizedBox(width: 8),
                    source,
                    Icon(Icons.chevron_right, color: muted),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResourceIconBadge(icon: resource.icon, size: 52),
                        const Spacer(),
                        source,
                      ],
                    ),
                    const SizedBox(height: 12),
                    text,
                  ],
                ),
        ),
      ),
    );
  }
}

/// Shows a bottom sheet on small screens and a dialog on larger screens.
Future<void> showExternalResource(
  BuildContext context, {
  required String speciesName,
  required ExternalResource resource,
  String? countryDistribution,
}) {
  final Widget content = ExternalResourceSheet(
    speciesName: speciesName,
    countryDistribution: countryDistribution,
    resource: resource,
  );
  if (getScreenType(context) == ScreenType.small) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: content,
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: content,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class ExternalResourceSheet extends StatelessWidget {
  const ExternalResourceSheet({
    super.key,
    required this.speciesName,
    required this.resource,
    this.countryDistribution,
  });

  final String speciesName;
  final ExternalResource resource;

  /// MDD's country list, outlined on the occurrence map.
  final String? countryDistribution;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          speciesName,
          style: textTheme.titleLarge?.apply(
            fontFamily: 'Libre Baskerville',
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          resource.sheetTitle,
          style: textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Divider(),
        _ExternalDataNote(
          provider: resource.provider,
          extra: resource == ExternalResource.occurrences
              ? gbifUnnaturalRangeNote
              : null,
        ),
        const SizedBox(height: 8),
        Flexible(
          child: switch (resource) {
            ExternalResource.occurrences => GbifOccurrenceView(
              speciesName: speciesName,
              countryDistribution: countryDistribution,
            ),
            ExternalResource.genetics => GenBankView(speciesName: speciesName),
            ExternalResource.publications => CrossrefView(
              speciesName: speciesName,
            ),
          },
        ),
      ],
    );
  }
}

class GbifOccurrenceView extends ConsumerWidget {
  const GbifOccurrenceView({
    super.key,
    required this.speciesName,
    this.countryDistribution,
  });

  final String speciesName;
  final String? countryDistribution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(gbifSummaryProvider(speciesName))
        .when(
          data: (summary) {
            if (summary == null) {
              return const _ResourceMessage(
                'No matching species found on GBIF.',
              );
            }
            final textTheme = Theme.of(context).textTheme;
            final distribution = ref.watch(
              distributionOverlayProvider(countryDistribution ?? ''),
            );
            return ListView(
              shrinkWrap: true,
              children: [
                _DetailStatCard(
                  icon: ResourceIcon.occurrences,
                  title: 'Occurrence records',
                  value: formatCount(summary.occurrences),
                  pills: [
                    if (summary.matchedName != speciesName)
                      SpeciesSubStats(
                        label: 'Matched on GBIF as',
                        display: summary.matchedName,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _MapPanel(
                  legend: GbifMapLegend(
                    hasDistribution:
                        distribution.asData?.value?.polygons.isNotEmpty ??
                        false,
                  ),
                  // The outlines are a local asset, so waiting for them
                  // costs nothing and saves rebuilding the map style.
                  map: distribution.when(
                    data: (data) => GbifDensityMap(
                      taxonKey: summary.taxonKey,
                      extent: summary.extent,
                      distribution: data,
                    ),
                    loading: () => const _ResourceLoading(),
                    error: (_, _) => GbifDensityMap(
                      taxonKey: summary.taxonKey,
                      extent: summary.extent,
                    ),
                  ),
                  notes: [
                    Text(
                      '© GBIF · OpenMapTiles · OpenStreetMap contributors',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    const RecenterHint(subject: 'Records'),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: _SourceButton(
                    label: 'Open on GBIF',
                    onPressed: () =>
                        launchURL(GbifClient.speciesPageUrl(summary.taxonKey)),
                  ),
                ),
              ],
            );
          },
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(gbifSummaryProvider(speciesName)),
          ),
        );
  }
}

/// Keeps the map with its legend, attribution and hint in one card, laid
/// out like the distribution map: text inset, map edge to edge.
class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.legend,
    required this.map,
    this.notes = const [],
  });

  final Widget legend;
  final Widget map;
  final List<Widget> notes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(130)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: legend,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: map,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenBankView extends ConsumerWidget {
  const GenBankView({super.key, required this.speciesName});

  final String speciesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget records = ref
        .watch(genBankSummaryProvider(speciesName))
        .when(
          data: (counts) => _CardGrid(
            children: [
              for (final item in counts)
                StatCard(
                  title: item.label,
                  count: item.count,
                  leading: ResourceGlyph(
                    icon: ResourceIcon.forRecord(item.record),
                  ),
                  tooltip: 'Open in NCBI',
                  onTap: item.count > 0 ? () => launchURL(item.url) : null,
                ),
            ],
          ),
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(genBankSummaryProvider(speciesName)),
          ),
        );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GenomeSection(speciesName: speciesName),
          const _StatHeading('Records in NCBI'),
          records,
        ],
      ),
    );
  }
}

/// Genome size and gene composition from NCBI Datasets. Shows nothing for
/// species without either.
class GenomeSection extends ConsumerWidget {
  const GenomeSection({super.key, required this.speciesName});

  final String speciesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(genomeSummaryProvider(speciesName))
        .when(
          data: (summary) {
            if (summary.isEmpty) return const SizedBox.shrink();
            final GenomeAssembly? assembly = summary.assembly;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (assembly != null)
                  _GenomeCard(
                    assembly: assembly,
                    assemblyCount: summary.assemblyCount,
                    speciesName: speciesName,
                  ),
                if (assembly != null && summary.genes.total > 0)
                  const SizedBox(height: 8),
                if (summary.genes.total > 0)
                  GeneCompositionCard(genes: summary.genes),
              ],
            );
          },
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(genomeSummaryProvider(speciesName)),
          ),
        );
  }
}

/// A plain bold heading, like "Mammal Diversity Statistics".
class _StatHeading extends StatelessWidget {
  const _StatHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

/// A resource icon drawn on its own, above a stat card's value.
class ResourceGlyph extends StatelessWidget {
  const ResourceGlyph({super.key, required this.icon, this.size = 24});

  final ResourceIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        icon.asset,
        width: size,
        height: size,
        colorMapper: _ResourceIconColors(
          isDark ? colorScheme.onSurface : colorScheme.primary,
          colorScheme.secondary,
        ),
      ),
    );
  }
}

/// A headline figure with sub-stat pills, laid out like the home screen's
/// species card: icon and title, a large value, then pills.
class _DetailStatCard extends StatelessWidget {
  const _DetailStatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.pills = const [],
    this.chart,
    this.footer = const [],
  });

  final ResourceIcon icon;
  final String title;
  final String value;
  final List<Widget> pills;
  final Widget? chart;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(130)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ResourceGlyph(icon: icon),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statValueColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (chart != null) ...[const SizedBox(height: 12), chart!],
            if (pills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: pills,
              ),
            ],
            if (footer.isNotEmpty) ...[const SizedBox(height: 8), ...footer],
          ],
        ),
      ),
    );
  }
}

/// A teal text action, as used across MDD.
class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.open_in_new,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.secondary,
      visualDensity: VisualDensity.compact,
    ),
    onPressed: onPressed,
    icon: Icon(icon, size: 16),
    label: Text(label),
  );
}

class _GenomeCard extends StatelessWidget {
  const _GenomeCard({
    required this.assembly,
    required this.assemblyCount,
    required this.speciesName,
  });

  final GenomeAssembly assembly;
  final int assemblyCount;
  final String speciesName;

  @override
  Widget build(BuildContext context) {
    final size = assembly.genomeSize != null
        ? formatBases(assembly.genomeSize!)
        : null;
    final int? chromosomes = assembly.chromosomeCount;
    final String? year = assembly.releaseDate?.split('-').first;
    final String? organism = assembly.organismName;
    final bool fromOther =
        organism != null && organism.toLowerCase() != speciesName.toLowerCase();
    return _DetailStatCard(
      icon: ResourceIcon.chromosome,
      title: assembly.isReference
          ? 'Reference genome'
          : 'Best available assembly',
      value: size == null ? 'Size unknown' : '${size.value} ${size.unit}',
      pills: [
        if (chromosomes != null && chromosomes > 0)
          SpeciesSubStats(label: 'Chromosomes', value: chromosomes),
        if (assembly.assemblyLevel != null)
          SpeciesSubStats(label: 'Level', display: assembly.assemblyLevel!),
        if (assembly.gcPercent != null)
          SpeciesSubStats(label: 'GC', display: '${assembly.gcPercent}%'),
        if (year != null) SpeciesSubStats(label: 'Released', display: year),
        if (assemblyCount > 1)
          SpeciesSubStats(label: 'Assemblies', value: assemblyCount),
      ],
      footer: [
        if (fromOther)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Assembled from '),
                TextSpan(
                  text: organism,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        _SourceButton(
          label: assembly.accession,
          onPressed: () => launchURL(assembly.url),
        ),
      ],
    );
  }
}

/// Category colours from the MDD chart palette, which is checked for WCAG
/// contrast against card surfaces in both themes. Fixed per category so a
/// category keeps its colour whichever ones a species has.
Color geneCategoryColor(BuildContext context, GeneCategory category) {
  final palette = ChartPalette.getCategoricalColors(context);
  return switch (category) {
    GeneCategory.proteinCoding => palette[0],
    GeneCategory.rna => palette[1],
    GeneCategory.pseudo => palette[2],
    GeneCategory.other => palette[4],
  };
}

String _formatShare(int count, int total) {
  final double share = count / total * 100;
  // A handful of genes against thousands would round to 0%, reading as none.
  return share > 0 && share < 1 ? '<1%' : '${share.round()}%';
}

/// The total, a thin bar of how it divides, and a pill per category that
/// carries its count and share, so no share is told by colour alone.
class GeneCompositionCard extends StatelessWidget {
  const GeneCompositionCard({super.key, required this.genes});

  final GeneComposition genes;

  @override
  Widget build(BuildContext context) {
    final int total = genes.total;
    final Map<GeneCategory, int> segments = genes.byCategory;
    final String description = segments.entries
        .map((e) => '${e.key.label}: ${formatCount(e.value)}')
        .join(', ');
    return _DetailStatCard(
      icon: ResourceIcon.gene,
      title: 'Annotated genes',
      value: formatCount(total),
      chart: Semantics(
        label: description,
        child: ExcludeSemantics(
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (final (index, entry) in segments.entries.indexed) ...[
                  if (index > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: entry.value,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 3),
                      decoration: BoxDecoration(
                        color: geneCategoryColor(context, entry.key),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(index == 0 ? 4 : 0),
                          right: Radius.circular(
                            index == segments.length - 1 ? 4 : 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      pills: [
        for (final entry in segments.entries)
          SpeciesSubStats(
            label: '${entry.key.label} · ${_formatShare(entry.value, total)}',
            value: entry.value,
            swatch: geneCategoryColor(context, entry.key),
          ),
      ],
    );
  }
}

/// One column on phones, two from [_kTileRowMinWidth] up.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTwoColumn = constraints.maxWidth >= _kTileRowMinWidth;
        final double width = isTwoColumn
            ? constraints.maxWidth / 2
            : constraints.maxWidth;
        return Wrap(
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class CrossrefView extends ConsumerWidget {
  const CrossrefView({super.key, required this.speciesName});

  final String speciesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget searchMore = Center(
      child: _SourceButton(
        label: 'Search more on Crossref',
        icon: Icons.search,
        onPressed: () => launchURL(CrossrefClient.searchUrl(speciesName)),
      ),
    );
    return ref
        .watch(crossrefWorksProvider(speciesName))
        .when(
          data: (works) {
            if (works.isEmpty) {
              return ListView(
                shrinkWrap: true,
                children: [
                  const _ResourceMessage(
                    'No publications with this species in the title found.',
                  ),
                  searchMore,
                ],
              );
            }
            final groups = CrossrefClient.groupByYear(works);
            final List<CrossrefWork> sorted = [
              for (final (_, items) in groups) ...items,
            ];
            final List<int> years = [for (final (year, _) in groups) ?year];
            return ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Publications',
                        count: works.length,
                        leading: const ResourceGlyph(
                          icon: ResourceIcon.publications,
                        ),
                      ),
                    ),
                    if (years.isNotEmpty) ...[
                      Expanded(
                        child: StatCard(
                          title: 'Latest',
                          display: '${years.first}',
                          leading: const _StatIcon(Icons.event_outlined),
                        ),
                      ),
                      Expanded(
                        child: StatCard(
                          title: 'Earliest',
                          display: '${years.last}',
                          leading: const _StatIcon(Icons.history),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _PublicationList(works: sorted, speciesName: speciesName),
                const SizedBox(height: 4),
                searchMore,
              ],
            );
          },
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(crossrefWorksProvider(speciesName)),
          ),
        );
  }
}

/// A Material icon sized and coloured like a [ResourceGlyph].
class _StatIcon extends StatelessWidget {
  const _StatIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      icon,
      size: 24,
      color: isDark ? colorScheme.onSurface : colorScheme.primary,
    );
  }
}

/// Publications newest first in one card, divided by rules.
class _PublicationList extends StatelessWidget {
  const _PublicationList({required this.works, required this.speciesName});

  final List<CrossrefWork> works;
  final String speciesName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(130)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, work) in works.indexed) ...[
              if (index > 0)
                Divider(color: colorScheme.outlineVariant.withAlpha(130)),
              _Publication(work: work, speciesName: speciesName),
            ],
          ],
        ),
      ),
    );
  }
}

class _Publication extends StatelessWidget {
  const _Publication({required this.work, required this.speciesName});

  final CrossrefWork work;
  final String speciesName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String meta = [
      work.authors,
      if (work.year != null) '${work.year}',
      work.source,
    ].where((e) => e.isNotEmpty).join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: italicizeName(work.title, speciesName)),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            meta,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        Wrap(
          children: [
            _SourceButton(label: 'View', onPressed: () => launchURL(work.url)),
            _CopyCitationButton(citation: work.citation),
          ],
        ),
      ],
    );
  }
}

/// Shows "Copied" in place, since a snackbar would sit under the sheet.
class _CopyCitationButton extends StatefulWidget {
  const _CopyCitationButton({required this.citation});

  final String citation;

  @override
  State<_CopyCitationButton> createState() => _CopyCitationButtonState();
}

class _CopyCitationButtonState extends State<_CopyCitationButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.citation));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: _copy,
      icon: Icon(_copied ? Icons.check : Icons.content_copy, size: 16),
      label: Text(_copied ? 'Copied' : 'Copy citation'),
    );
  }
}

/// Splits [text] into spans with every occurrence of [name] in italics.
List<TextSpan> italicizeName(String text, String name) {
  if (name.isEmpty) return [TextSpan(text: text)];
  final List<TextSpan> spans = [];
  final String lower = text.toLowerCase();
  final String needle = name.toLowerCase();
  int start = 0;
  while (true) {
    final int index = lower.indexOf(needle, start);
    if (index < 0) break;
    if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
    spans.add(
      TextSpan(
        text: text.substring(index, index + name.length),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
    start = index + name.length;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return spans;
}

class _ExternalDataNote extends StatelessWidget {
  const _ExternalDataNote({required this.provider, this.extra});

  final String provider;

  /// A caveat specific to this source, added after the standard note.
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            [externalDataNote(provider), ?extra].join(' '),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ResourceLoading extends StatelessWidget {
  const _ResourceLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ResourceMessage extends StatelessWidget {
  const _ResourceMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(message, textAlign: TextAlign.center),
  );
}

class _ResourceError extends StatelessWidget {
  const _ResourceError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Unable to load data. Check your internet connection.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

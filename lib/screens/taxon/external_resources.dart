import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/providers/external_resources.dart';
import 'package:mdd/services/species_list.dart';
import 'package:mdd/services/system.dart';

const String externalResourcesDescription =
    'Explore this species in public databases.';

const String externalDataNote =
    'Fetched automatically from the source and not curated by the MDD team. '
    'Its taxonomy may differ from MDD. Use as additional information.';

/// Tiles switch from a row to a stacked column below this width.
const double _kTileRowMinWidth = 480;

enum ExternalResource {
  occurrences(
    title: 'Occurrences',
    source: 'GBIF',
    description: 'Record count and density map',
    sheetTitle: 'Species occurrences · GBIF',
    icon: ResourceIcon.occurrences,
  ),
  genetics(
    title: 'Genetics',
    source: 'GenBank',
    description: 'Genomes, genes and sequences',
    sheetTitle: 'Genetic data · GenBank',
    icon: ResourceIcon.genetics,
  ),
  publications(
    title: 'Publications',
    source: 'Crossref',
    description: 'Papers naming this species',
    sheetTitle: 'Publications · Crossref',
    icon: ResourceIcon.publications,
  );

  const ExternalResource({
    required this.title,
    required this.source,
    required this.description,
    required this.sheetTitle,
    required this.icon,
  });

  final String title;
  final String source;
  final String description;
  final String sheetTitle;
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
}) {
  final Widget content = ExternalResourceSheet(
    speciesName: speciesName,
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
  });

  final String speciesName;
  final ExternalResource resource;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ResourceIconBadge(icon: resource.icon, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speciesName,
                    style: textTheme.titleLarge?.apply(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    resource.sheetTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const _ExternalDataNote(),
        const SizedBox(height: 8),
        Flexible(
          child: switch (resource) {
            ExternalResource.occurrences => GbifOccurrenceView(
              speciesName: speciesName,
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
  const GbifOccurrenceView({super.key, required this.speciesName});

  final String speciesName;

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
            return ListView(
              shrinkWrap: true,
              children: [
                _DataCard(
                  title: 'Occurrence records',
                  icon: ResourceIcon.occurrences,
                  value: formatCount(summary.occurrences),
                  unit: summary.occurrences == 1 ? 'record' : 'records',
                  note: summary.matchedName != speciesName
                      ? 'Matched on GBIF as ${summary.matchedName}'
                      : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 320,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GbifDensityMap(taxonKey: summary.taxonKey),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© GBIF · OpenMapTiles · OpenStreetMap contributors',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        launchURL(GbifClient.speciesPageUrl(summary.taxonKey)),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open on GBIF'),
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

class GbifDensityMap extends StatelessWidget {
  const GbifDensityMap({super.key, required this.taxonKey});

  final int taxonKey;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return flutter_map.FlutterMap(
      options: const flutter_map.MapOptions(
        initialCenter: latlong.LatLng(18, 0),
        initialZoom: 0.5,
        minZoom: 0,
        maxZoom: 14,
        interactionOptions: flutter_map.InteractionOptions(
          flags:
              flutter_map.InteractiveFlag.all &
              ~flutter_map.InteractiveFlag.rotate,
        ),
      ),
      children: [
        flutter_map.TileLayer(
          urlTemplate: GbifClient.basemapTileUrl(isDark: isDark),
          userAgentPackageName: 'com.hhandika.mdd',
        ),
        flutter_map.TileLayer(
          urlTemplate: GbifClient.densityTileUrl(taxonKey),
          userAgentPackageName: 'com.hhandika.mdd',
        ),
      ],
    );
  }
}

class GenBankView extends ConsumerWidget {
  const GenBankView({super.key, required this.speciesName});

  final String speciesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(genBankSummaryProvider(speciesName))
        .when(
          data: (counts) => SingleChildScrollView(
            child: _CardGrid(
              children: [
                for (final item in counts)
                  _DataCard(
                    title: item.label,
                    icon: ResourceIcon.forRecord(item.record),
                    value: formatCount(item.count),
                    unit: item.count == 1 ? 'record' : 'records',
                    note: item.description,
                    linkLabel: item.count > 0 ? 'View in NCBI' : null,
                    onLink: item.count > 0 ? () => launchURL(item.url) : null,
                  ),
              ],
            ),
          ),
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(genBankSummaryProvider(speciesName)),
          ),
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
        const double gap = 8;
        final bool isTwoColumn = constraints.maxWidth >= _kTileRowMinWidth;
        final double width = isTwoColumn
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

/// A titled card with an icon, a count and an optional source link, after
/// the BioCosmos genetics cards.
class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    this.note,
    this.linkLabel,
    this.onLink,
  });

  final String title;
  final ResourceIcon icon;
  final String value;
  final String unit;
  final String? note;
  final String? linkLabel;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color muted = colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ResourceIconBadge(icon: icon, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: value,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' $unit'),
                        ],
                      ),
                      style: textTheme.titleMedium,
                    ),
                    if (note != null)
                      Text(
                        note!,
                        style: textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    if (linkLabel != null && onLink != null)
                      InkWell(
                        onTap: onLink,
                        child: Text(
                          linkLabel!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CrossrefView extends ConsumerWidget {
  const CrossrefView({super.key, required this.speciesName});

  final String speciesName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget searchMore = Center(
      child: TextButton.icon(
        onPressed: () => launchURL(CrossrefClient.searchUrl(speciesName)),
        icon: const Icon(Icons.search),
        label: const Text('Search more on Crossref'),
      ),
    );
    return ref
        .watch(crossrefWorksProvider(speciesName))
        .when(
          data: (works) => ListView(
            shrinkWrap: true,
            children: [
              if (works.isEmpty)
                const _ResourceMessage(
                  'No publications with this species in the title found.',
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${works.length} '
                    '${works.length == 1 ? 'publication' : 'publications'}'
                    ' with this species in the title',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              for (final (year, items) in CrossrefClient.groupByYear(works))
                _PublicationYear(
                  year: year,
                  works: items,
                  speciesName: speciesName,
                ),
              searchMore,
            ],
          ),
          loading: () => const _ResourceLoading(),
          error: (error, _) => _ResourceError(
            onRetry: () => ref.invalidate(crossrefWorksProvider(speciesName)),
          ),
        );
  }
}

/// A year heading over its publications, joined by a rule on the left.
class _PublicationYear extends StatelessWidget {
  const _PublicationYear({
    required this.year,
    required this.works,
    required this.speciesName,
  });

  final int? year;
  final List<CrossrefWork> works;
  final String speciesName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            year?.toString() ?? 'Unknown year',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 6, top: 4),
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorScheme.secondary.withAlpha(160),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final work in works)
                  _Publication(work: work, speciesName: speciesName),
              ],
            ),
          ),
        ],
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
    final Color muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final String byline = [
      work.authors,
      work.source,
    ].where((e) => e.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: italicizeName(work.title, speciesName)),
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (byline.isNotEmpty)
            Text(byline, style: textTheme.bodySmall?.copyWith(color: muted)),
          Text(
            'doi:${work.doi}',
            style: textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilledButton.tonalIcon(
                style: _compactButton,
                onPressed: () => launchURL(work.url),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View'),
              ),
              _CopyCitationButton(citation: work.citation),
            ],
          ),
        ],
      ),
    );
  }
}

final ButtonStyle _compactButton = ButtonStyle(
  visualDensity: VisualDensity.compact,
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
  textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13)),
);

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
    return OutlinedButton.icon(
      style: _compactButton,
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
  const _ExternalDataNote();

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
            externalDataNote,
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

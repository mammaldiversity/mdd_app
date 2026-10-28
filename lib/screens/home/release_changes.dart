import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/essential_url.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/release_changes.dart';

/// Net species change per MDD release: a ledger of losses and gains on
/// wide screens, and swipeable release cards on phones.
class TaxonomyChanges extends ConsumerWidget {
  const TaxonomyChanges({super.key});

  /// Below this width the ledger rows get too cramped for two bars.
  static const double ledgerMinWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(releaseChangesProvider).value;
    if (releases == null || releases.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(),
          const SizedBox(height: 4),
          if (constraints.maxWidth >= ledgerMinWidth)
            _ReleaseLedger(releases: releases)
          else
            _ReleaseCards(releases: releases),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Change in MDD taxonomy',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('All changes'),
          onPressed: () => launchURL(taxonomyChangesUrl),
        ),
      ],
    );
  }
}

/// Total net change beside one row per release, with lumps and removals
/// drawn left of the axis and new species drawn right of it.
class _ReleaseLedger extends StatelessWidget {
  const _ReleaseLedger({required this.releases});

  final List<ReleaseChange> releases;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = ChartPalette.getChangeColors(context);
    final totalNet = releases.fold(0, (sum, r) => sum + r.net);
    final scale = releases.fold(
      1,
      (largest, r) => math.max(largest, math.max(r.gained, r.lost)),
    );
    final headerStyle = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Since v${releases.last.prevVersion}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatSignedCount(totalNet),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _netColor(context, totalNet),
                    ),
                  ),
                  Text(
                    'net species over ${releases.length} releases',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LegendEntry(color: colors.loss, label: 'Lumps, removals'),
                  const SizedBox(height: 4),
                  _LegendEntry(
                    color: colors.gain,
                    label: 'De novo, splits, other additions',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _LedgerRow(
                    release: Text('Release', style: headerStyle),
                    loss: Text(
                      'Lost',
                      style: headerStyle,
                      textAlign: TextAlign.right,
                    ),
                    gain: Text('Gained', style: headerStyle),
                    net: Text(
                      'Net',
                      style: headerStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  for (final release in releases)
                    _ReleaseLedgerRow(release: release, scale: scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseLedgerRow extends StatelessWidget {
  const _ReleaseLedgerRow({required this.release, required this.scale});

  final ReleaseChange release;

  /// The count that fills a whole bar.
  final int scale;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = ChartPalette.getChangeColors(context);
    return Tooltip(
      message: _breakdown(release),
      child: Semantics(
        label:
            'Version ${release.version}: '
            '${formatSignedCount(release.net)} net species. '
            '${_breakdown(release)}',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant.withAlpha(130)),
            ),
          ),
          child: _LedgerRow(
            release: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('v${release.version}', style: textTheme.labelLarge),
                if (release.releaseDate != null)
                  Text(
                    _formatDate(release.releaseDate!),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            loss: _Bar(
              value: release.lost,
              scale: scale,
              color: colors.loss,
              alignment: Alignment.centerRight,
            ),
            gain: _Bar(
              value: release.gained,
              scale: scale,
              color: colors.gain,
              alignment: Alignment.centerLeft,
            ),
            net: Text(
              formatSignedCount(release.net),
              textAlign: TextAlign.right,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _netColor(context, release.net),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The column layout shared by the ledger header and its rows. Losses get
/// less room than gains because releases add far more species than they
/// lump.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.release,
    required this.loss,
    required this.gain,
    required this.net,
  });

  final Widget release;
  final Widget loss;
  final Widget gain;
  final Widget net;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 88, child: release),
          Expanded(flex: 2, child: loss),
          const SizedBox(width: 2),
          Expanded(flex: 3, child: gain),
          SizedBox(width: 56, child: net),
        ],
      ),
    );
  }
}

/// A bar with its count, growing from [alignment] towards the other side.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.scale,
    required this.color,
    required this.alignment,
  });

  final int value;
  final int scale;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final fromRight = alignment == Alignment.centerRight;
    final label = Text(
      '$value',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Leave room for the count beside the longest bar.
        final width = math.max(0.0, constraints.maxWidth - 28) * value / scale;
        final bar = Container(
          width: value == 0 ? 0 : math.max(2, width),
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.horizontal(
              left: fromRight ? const Radius.circular(3) : Radius.zero,
              right: fromRight ? Radius.zero : const Radius.circular(3),
            ),
          ),
        );
        return Row(
          mainAxisAlignment: fromRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: fromRight
              ? [label, const SizedBox(width: 4), bar]
              : [bar, const SizedBox(width: 4), label],
        );
      },
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// One card per release, newest first, swiped sideways.
class _ReleaseCards extends StatefulWidget {
  const _ReleaseCards({required this.releases});

  final List<ReleaseChange> releases;

  @override
  State<_ReleaseCards> createState() => _ReleaseCardsState();
}

class _ReleaseCardsState extends State<_ReleaseCards> {
  final _controller = PageController(viewportFraction: 0.86);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final releases = widget.releases;
    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: releases.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ReleaseCard(release: releases[index]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < releases.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release});

  final ReleaseChange release;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = ChartPalette.getChangeColors(context);
    final mutedStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final segments = [
      (release.deNovo, colors.gain),
      (release.split + release.added, colors.gain.withAlpha(140)),
      (release.lost, colors.loss),
    ];
    return Semantics(
      label:
          'Version ${release.version}: '
          '${formatSignedCount(release.net)} net species. '
          '${_breakdown(release)}',
      excludeSemantics: true,
      child: DashboardCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  'v${release.version}',
                  if (release.releaseDate != null)
                    _formatDate(release.releaseDate!),
                ].join(' · '),
                style: mutedStyle,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatSignedCount(release.net),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _netColor(context, release.net),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('net species', style: mutedStyle),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (count, color) in segments)
                        if (count > 0)
                          Expanded(
                            flex: count,
                            child: ColoredBox(color: color),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _breakdown(release),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: mutedStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _breakdown(ReleaseChange release) => [
  '${release.deNovo} de novo',
  '${release.split} splits',
  '${release.lump} lumps',
  if (release.added > 0) '${release.added} other additions',
  if (release.removed > 0) '${release.removed} removed',
].join(' · ');

Color _netColor(BuildContext context, int net) {
  final colors = ChartPalette.getChangeColors(context);
  if (net > 0) return colors.gain;
  if (net < 0) return colors.loss;
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.year}';

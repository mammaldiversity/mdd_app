import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/taxon/species.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/taxon_tree.dart';

/// Horizontal space per tree level.
const double _treeIndent = 22;

/// Offset of each level's vertical connector within its indent column.
const double _lineOffset = 10;

/// Root heading of the tree view.
class TreeRootHeading extends StatelessWidget {
  const TreeRootHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Text(
        'Mammalia',
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// One visible node of the taxon tree: connector lines plus a pill.
class TaxonTreeRow extends ConsumerWidget {
  const TaxonTreeRow({super.key, required this.row, required this.isExpanded});

  final VisibleTaxonRow row;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = row.node;
    return CustomPaint(
      painter: TreeConnectorPainter(
        depth: row.depth,
        isLast: row.isLast,
        ancestorHasNext: row.ancestorHasNext,
        color: Theme.of(context).colorScheme.outline,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16 + (row.depth + 1) * _treeIndent,
          right: 16,
          top: 4,
          bottom: 4,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TaxonPill(
            node: node,
            isExpanded: isExpanded,
            onTap: () {
              if (node.hasChildren) {
                ref.read(expandedTaxaProvider.notifier).toggle(node.key);
              } else if (node.mddId != null) {
                ref.read(currentMddIDProvider.notifier).setMddID(node.mddId!);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SpeciesPage(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Draws the tree connectors for a row, adapted from the
/// mammaldiversity.org tree view: a vertical line for every ancestor whose
/// branch continues, and an elbow (├ or └) into this row's pill.
class TreeConnectorPainter extends CustomPainter {
  const TreeConnectorPainter({
    required this.depth,
    required this.isLast,
    required this.ancestorHasNext,
    required this.color,
  });

  final int depth;
  final bool isLast;
  final List<bool> ancestorHasNext;
  final Color color;

  double _columnX(int level) => 16 + level * _treeIndent + _lineOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final centerY = size.height / 2;

    for (var level = 0; level < depth; level++) {
      if (ancestorHasNext[level]) {
        final x = _columnX(level);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    final x = _columnX(depth);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, isLast ? centerY : size.height),
      paint,
    );
    canvas.drawLine(
      Offset(x, centerY),
      Offset(16 + (depth + 1) * _treeIndent, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(TreeConnectorPainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.isLast != isLast ||
        oldDelegate.color != color ||
        oldDelegate.ancestorHasNext != ancestorHasNext;
  }
}

/// A rounded taxon label: toggle, rank, name, and child count.
class TaxonPill extends StatelessWidget {
  const TaxonPill({
    super.key,
    required this.node,
    required this.isExpanded,
    required this.onTap,
  });

  final TaxonNode node;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Tertiary matches the website's spectra pills: light teal in light
    // mode, deep teal in dark mode.
    final onPill = colorScheme.onSurface;

    return Material(
      color: colorScheme.tertiary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: onPill.withAlpha(120)),
                  ),
                ),
                child: node.hasChildren
                    ? Text(
                        isExpanded ? '–' : '+',
                        textAlign: TextAlign.center,
                        semanticsLabel: isExpanded ? 'Collapse' : 'Expand',
                        style: textTheme.titleMedium?.copyWith(color: onPill),
                      )
                    : Icon(Icons.pets, size: 14, color: onPill),
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.rankLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: node.isExtinct
                            ? colorScheme.error
                            : onPill.withAlpha(180),
                      ),
                    ),
                    Text(
                      node.isExtinct ? '${node.name} †' : node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: onPill,
                        fontStyle: node.isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (node.hasChildren) ...[
                const SizedBox(width: 8),
                Text(
                  '· ${node.children.length}',
                  style: textTheme.bodySmall?.copyWith(
                    // Primary is a dark brown in both themes; lighten it so
                    // the count stays readable on the dark pill.
                    color: colorScheme.brightness == Brightness.dark
                        ? Color.lerp(colorScheme.primary, Colors.white, 0.6)
                        : colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

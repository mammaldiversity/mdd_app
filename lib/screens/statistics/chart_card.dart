import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/card.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double height;
  final Widget? action;
  final Widget? footer;
  final VoidCallback? onViewTable;
  final String viewTableLabel;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.height = 300,
    this.action,
    this.footer,
    this.onViewTable,
    this.viewTableLabel = 'View Table',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget? headerAction = action;

    Widget? effectiveFooter = footer;
    if (effectiveFooter == null && onViewTable != null) {
      effectiveFooter = Center(
        child: OutlinedButton.icon(
          onPressed: onViewTable,
          icon: const Icon(
            Icons.table_chart_outlined,
            size: 18,
          ),
          label: Text(viewTableLabel),
          style: OutlinedButton.styleFrom(
            elevation: 0,
            side: BorderSide(
              color: colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    return CommonCard(
      title: title,
      action: headerAction,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withAlpha(120),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: height, child: chart),
            if (effectiveFooter != null) ...[
              const SizedBox(height: 12),
              effectiveFooter,
            ],
          ],
        ),
      ),
    );
  }
}

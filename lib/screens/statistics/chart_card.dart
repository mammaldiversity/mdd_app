import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/card.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double height;
  final Widget? action;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.height = 300,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      title: title,
      action: action,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withAlpha(120),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        child: SizedBox(height: height, child: chart),
      ),
    );
  }
}

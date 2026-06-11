import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/card.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double height;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: SizedBox(height: height, child: chart),
      ),
    );
  }
}

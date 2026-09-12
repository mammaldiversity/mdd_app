import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ResponsivePieChartBuilder =
    Widget Function(BuildContext context, double radiusScale);

/// Sizes pie charts to the card height with the legend on the right.
///
/// Below [breakpoint], the chart and legend share one horizontal scroll view
/// so the chart keeps its size and legend labels stay on a single line.
class ResponsivePieChartLayout extends StatelessWidget {
  const ResponsivePieChartLayout({
    super.key,
    required this.chartBuilder,
    required this.legend,
  });

  static const double breakpoint = 380;
  static const double _minimumNarrowChartExtent = 160;
  static const double _visibleNarrowLegendExtent = 64;
  static const double _gap = 8;
  // fl_chart draws sections outside the center space, so the donut's outer
  // edge is centerSpaceRadius (38) + touched section radius (66).
  static const double _maximumOuterRadius = 38 + 66;
  static const double _chartPadding = 4;

  final ResponsivePieChartBuilder chartBuilder;
  final Widget legend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        if (constraints.maxWidth < breakpoint) {
          // Fill the height, but keep part of the legend in view so it is
          // clear the row scrolls.
          final chartExtent = math.min(
            height,
            math.max(
              _minimumNarrowChartExtent,
              constraints.maxWidth - _gap - _visibleNarrowLegendExtent,
            ),
          );
          final minLegendWidth = math.max(
            0.0,
            constraints.maxWidth - chartExtent - _gap,
          );

          return SingleChildScrollView(
            key: const ValueKey('responsive-pie-chart-narrow'),
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: height,
              child: Row(
                children: [
                  _buildChart(context, chartExtent),
                  const SizedBox(width: _gap),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minLegendWidth),
                    child: IntrinsicWidth(child: _buildLegend(height)),
                  ),
                ],
              ),
            ),
          );
        }

        return Row(
          key: const ValueKey('responsive-pie-chart-wide'),
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, chartConstraints) {
                  final extent = math.min(
                    chartConstraints.maxWidth,
                    chartConstraints.maxHeight,
                  );
                  return Center(child: _buildChart(context, extent));
                },
              ),
            ),
            const SizedBox(width: _gap),
            Expanded(child: _buildLegend(height)),
            const SizedBox(width: _gap),
          ],
        );
      },
    );
  }

  Widget _buildChart(BuildContext context, double extent) {
    final usableRadius = math.max(0.0, extent / 2 - _chartPadding);
    final radiusScale = usableRadius / _maximumOuterRadius;

    return SizedBox.square(
      dimension: extent,
      child: chartBuilder(context, radiusScale),
    );
  }

  Widget _buildLegend(double minHeight) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        // Lets the legend's Column center itself when it is shorter than
        // the chart.
        constraints: BoxConstraints(minHeight: minHeight),
        child: legend,
      ),
    );
  }
}

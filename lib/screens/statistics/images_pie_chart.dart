import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/statistics.dart';

class ImagesPieChart extends StatefulWidget {
  const ImagesPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<ImagesPieChart> createState() => _ImagesPieChartState();
}

class _ImagesPieChartState extends State<ImagesPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.totalSpeciesCount == 0) return const SizedBox.shrink();
    final withImages = widget.stats.speciesWithImagesCount;
    final total = widget.stats.totalSpeciesCount;
    final withoutImages = total - withImages;
    final withPct =
        total > 0 ? (withImages / total * 100).toStringAsFixed(1) : '0';
    final withoutPct =
        total > 0 ? (withoutImages / total * 100).toStringAsFixed(1) : '0';
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SegmentedButton<bool>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Donut', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Pie', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_isDonut},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isDonut = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: _isDonut ? 38 : 0,
                      sections: [
                        _buildSection(
                          0,
                          withImages,
                          colorScheme.primary,
                        ),
                        _buildSection(
                          1,
                          withoutImages,
                          colorScheme.outlineVariant.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Indicator(
                      color: colorScheme.primary,
                      text: 'With: $withImages ($withPct%)',
                      isSquare: true,
                      textColor: colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Indicator(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                      text: 'Without: $withoutImages ($withoutPct%)',
                      isSquare: true,
                      textColor: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _buildSection(int index, int count, Color color) {
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 58.0 : 50.0;
    const shadows = [Shadow(color: Colors.black45, blurRadius: 4)];

    return PieChartSectionData(
      color: color,
      value: count.toDouble(),
      title: '$count',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: shadows,
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/screens/statistics/indicator.dart';

class ImagesPieChart extends StatefulWidget {
  final MddStatistics stats;

  const ImagesPieChart({super.key, required this.stats});

  @override
  State<ImagesPieChart> createState() => _ImagesPieChartState();
}

class _ImagesPieChartState extends State<ImagesPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.totalSpeciesCount == 0) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1.3,
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
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: double.nan,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Indicator(
                  color: Colors.blue.shade700,
                  text: 'With Images (${widget.stats.speciesWithImagesCount})',
                  isSquare: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Indicator(
                  color: Colors.grey.shade400,
                  text:
                      'Without Images (${widget.stats.totalSpeciesCount - widget.stats.speciesWithImagesCount})',
                  isSquare: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final withImages = widget.stats.speciesWithImagesCount;
    final withoutImages = widget.stats.totalSpeciesCount - withImages;

    return [
      _buildSection(0, withImages, Colors.blue.shade700),
      _buildSection(1, withoutImages, Colors.grey.shade400),
    ];
  }

  PieChartSectionData _buildSection(int index, int count, Color color) {
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 20.0 : 12.0;
    final radius = isTouched ? 60.0 : 50.0;
    const shadows = [Shadow(color: Colors.black87, blurRadius: 4)];

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

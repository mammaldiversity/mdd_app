import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

class DomesticPieChart extends StatefulWidget {
  const DomesticPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<DomesticPieChart> createState() => _DomesticPieChartState();
}

class _DomesticPieChartState extends State<DomesticPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  @override
  Widget build(BuildContext context) {
    final List<StatDomesticSpeciesResult> data = widget.stats.domesticSpecies;
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold<int>(0, (sum, e) => sum + e.count);
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
                      sections: _showingSections(data),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((e) {
                  final isDomestic = e.isDomestic == 1;
                  final pct = total > 0
                      ? (e.count / total * 100).toStringAsFixed(1)
                      : '0';
                  final label = isDomestic ? 'Domestic' : 'Wild';
                  final color = isDomestic
                      ? Colors.amber.shade700
                      : Colors.green.shade700;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Indicator(
                      color: color,
                      text: '$label: ${e.count} ($pct%)',
                      isSquare: true,
                      textColor: colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(
    List<StatDomesticSpeciesResult> data,
  ) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 58.0 : 50.0;
      const shadows = [Shadow(color: Colors.black45, blurRadius: 4)];

      final isDomestic = e.isDomestic == 1;
      final count = e.count;
      final color = isDomestic ? Colors.amber.shade700 : Colors.green.shade700;

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
    }).toList();
  }
}

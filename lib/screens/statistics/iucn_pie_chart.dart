import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/statistics.dart';

class IucnPieChart extends StatefulWidget {
  const IucnPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<IucnPieChart> createState() => _IucnPieChartState();
}

class _IucnPieChartState extends State<IucnPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  static const Map<String, Color> iucnColors = {
    'EX': Colors.black87,
    'EW': Color(0xFF4A148C),
    'CR': Colors.red,
    'EN': Colors.orange,
    'VU': Color(0xFFF57F17),
    'NT': Color(0xFF8BC34A),
    'LC': Colors.green,
    'DD': Colors.grey,
    'NE': Colors.blueGrey,
  };

  static const Map<String, int> iucnOrder = {
    'EX': 0,
    'EW': 1,
    'CR': 2,
    'EN': 3,
    'VU': 4,
    'NT': 5,
    'LC': 6,
    'DD': 7,
    'NE': 8,
  };

  static String _getFullIucnName(String code) {
    const map = {
      'EX': 'Extinct',
      'EW': 'Extinct in Wild',
      'CR': 'Critically Endangered',
      'EN': 'Endangered',
      'VU': 'Vulnerable',
      'NT': 'Near Threatened',
      'LC': 'Least Concern',
      'DD': 'Data Deficient',
      'NE': 'Not Evaluated',
    };
    return map[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> rawData = widget.stats.iucnStatus;
    if (rawData.isEmpty) return const SizedBox.shrink();

    final List<MapEntry<String, int>> data = List.from(rawData)
      ..sort((a, b) {
        final orderA = iucnOrder[a.key] ?? 99;
        final orderB = iucnOrder[b.key] ?? 99;
        return orderA.compareTo(orderB);
      });

    final total = data.fold<int>(0, (sum, e) => sum + e.value);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((e) {
                      final pct = total > 0
                          ? (e.value / total * 100).toStringAsFixed(1)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Indicator(
                          color: iucnColors[e.key] ?? Colors.grey,
                          text:
                              '${e.key} - ${_getFullIucnName(e.key)}: ${e.value} ($pct%)',
                          isSquare: true,
                          textColor: colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Note: Caveats (e.g. 'VU (as Species A)') are aggregated into primary status.",
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(
    List<MapEntry<String, int>> data,
  ) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 66.0 : 58.0;

      final count = e.value;
      final isLarge = count > 300 || isTouched;
      final color = iucnColors[e.key] ?? Colors.grey;
      final textColor =
          color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: isLarge ? '$count' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
    }).toList();
  }
}

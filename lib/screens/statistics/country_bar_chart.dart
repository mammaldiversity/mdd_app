import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';

class CountryBarChart extends StatelessWidget {
  final MddStatistics stats;

  const CountryBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.topCountries.isEmpty) return const SizedBox.shrink();
    final data = stats.topCountries;
    double maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final textColor = Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = data.length * (20.0 + 12.0) + 50.0;
        final chartWidth = requiredWidth > constraints.maxWidth ? requiredWidth : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                groupsSpace: 12,
                maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final xAxisLabel = data[group.x.toInt()].key;
              return BarTooltipItem(
                '$xAxisLabel\n',
                const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                
                String text = data[index].key;
                if (text == 'United States of America') text = 'USA';
                else if (text == 'Democratic Republic of the Congo') text = 'DR Congo';
                else if (text == 'Papua New Guinea') text = 'PNG';
                else if (text == 'Central African Republic') text = 'CAR';
                else if (text.length > 12) text = '${text.substring(0, 10)}...';

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.8,
                    child: Text(text, style: TextStyle(fontSize: 10, color: textColor), overflow: TextOverflow.ellipsis),
                  ),
                );
              },
              reservedSize: 80,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => const SizedBox.shrink(),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: Colors.green,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList(),
      ),
            ),
          ),
        );
      },
    );
  }
}

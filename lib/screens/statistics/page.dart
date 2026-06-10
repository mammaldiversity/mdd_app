import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/statistics/chart_card.dart';
import 'package:mdd/screens/statistics/country_bar_chart.dart';
import 'package:mdd/screens/statistics/decade_bar_chart.dart';
import 'package:mdd/screens/statistics/domestic_pie_chart.dart';
import 'package:mdd/screens/statistics/extinct_pie_chart.dart';
import 'package:mdd/screens/statistics/family_bar_chart.dart';
import 'package:mdd/screens/statistics/iucn_pie_chart.dart';
import 'package:mdd/screens/statistics/order_bar_chart.dart';
import 'package:mdd/screens/statistics/realm_pie_chart.dart';
import 'package:mdd/services/providers/statistics.dart';

class MddStats extends ConsumerStatefulWidget {
  const MddStats({super.key});

  @override
  ConsumerState<MddStats> createState() => _MddStatsState();
}

class _MddStatsState extends ConsumerState<MddStats> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      body: statsAsync.when(
        data: (stats) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;

              Widget buildRow(Widget chart1, Widget chart2) {
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: chart1),
                      const SizedBox(width: 16),
                      Expanded(child: chart2),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chart1,
                      const SizedBox(height: 16),
                      chart2,
                    ],
                  );
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  buildRow(
                    ChartCard(
                      title: 'Species Diversity by Order',
                      chart: OrderBarChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Species Diversity by Family (Top 15)',
                      chart: FamilyBarChart(stats: stats),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'Species Richness by Country (Top 10)',
                      chart: CountryBarChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Species Descriptions by Decade',
                      chart: DecadeBarChart(stats: stats),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'IUCN Red List Conservation Status',
                      chart: IucnPieChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Distribution by Biogeographic Realm',
                      chart: RealmPieChart(stats: stats),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'Extinct vs. Extant',
                      chart: ExtinctPieChart(stats: stats),
                      height: 200,
                    ),
                    ChartCard(
                      title: 'Domesticated vs. Wild',
                      chart: DomesticPieChart(stats: stats),
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/statistics/chart_card.dart';
import 'package:mdd/screens/statistics/country_bar_chart.dart';
import 'package:mdd/screens/statistics/decade_bar_chart.dart';
import 'package:mdd/screens/statistics/domestic_pie_chart.dart';
import 'package:mdd/screens/statistics/extinct_pie_chart.dart';
import 'package:mdd/screens/statistics/family_bar_chart.dart';
import 'package:mdd/screens/statistics/genus_bar_chart.dart';
import 'package:mdd/screens/statistics/iucn_pie_chart.dart';
import 'package:mdd/screens/statistics/order_bar_chart.dart';
import 'package:mdd/screens/statistics/realm_pie_chart.dart';
import 'package:mdd/screens/statistics/year_bar_chart.dart';
import 'package:mdd/screens/statistics/images_bar_chart.dart';
import 'package:mdd/screens/statistics/images_pie_chart.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/screens/shared/info_card.dart';

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
                  const InfoCard(
                      text:
                          'View visual summaries and metrics on mammalian diversity, geography, and conservation.'),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'Species Diversity by Order (Top 15)',
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
                      title: 'Species Diversity by Genus (Top 15)',
                      chart: GenusBarChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Species Richness by Country (Top 15)',
                      chart: CountryBarChart(stats: stats),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'Species Descriptions by Decade',
                      chart: DecadeBarChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Species Descriptions by Year (Top 15)',
                      chart: YearBarChart(stats: stats),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildRow(
                    ChartCard(
                      title: 'Species with Most Images (Top 15)',
                      chart: ImagesBarChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Proportion of Species with Images',
                      chart: ImagesPieChart(stats: stats),
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
                      title: 'Extinct vs. Extant Species',
                      chart: ExtinctPieChart(stats: stats),
                    ),
                    ChartCard(
                      title: 'Domesticated vs. Wild Species',
                      chart: DomesticPieChart(stats: stats),
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

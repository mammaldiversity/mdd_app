import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/statistics/chart_card.dart';
import 'package:mdd/screens/statistics/country_bar_chart.dart';
import 'package:mdd/screens/statistics/country_table_page.dart';
import 'package:mdd/screens/statistics/decade_bar_chart.dart';
import 'package:mdd/screens/statistics/domestic_pie_chart.dart';
import 'package:mdd/screens/statistics/extinct_pie_chart.dart';
import 'package:mdd/screens/statistics/family_bar_chart.dart';
import 'package:mdd/screens/statistics/genus_bar_chart.dart';
import 'package:mdd/screens/statistics/images_bar_chart.dart';
import 'package:mdd/screens/statistics/images_pie_chart.dart';
import 'package:mdd/screens/statistics/iucn_pie_chart.dart';
import 'package:mdd/screens/statistics/order_bar_chart.dart';
import 'package:mdd/screens/statistics/realm_pie_chart.dart';
import 'package:mdd/screens/statistics/stat_table_page.dart';
import 'package:mdd/screens/statistics/synonyms_bar_chart.dart';
import 'package:mdd/screens/statistics/type_kind_pie_chart.dart';
import 'package:mdd/screens/statistics/year_bar_chart.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';

class MddStats extends ConsumerStatefulWidget {
  const MddStats({super.key});

  @override
  ConsumerState<MddStats> createState() => _MddStatsState();
}

class _MddStatsState extends ConsumerState<MddStats> {
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  StatTablePage _orderTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species Diversity by Order',
      infoText:
          'Complete summary of mammal species counts per taxonomic order.',
      exportDefaultFileName: 'order_diversity',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Order'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.speciesPerOrder.map((e) {
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final name = e.name ?? 'Unknown';
        return StatTableRow(
          values: [name, count, '$pct%'],
          searchText: name,
        );
      }).toList(),
    );
  }

  StatTablePage _familyTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species Diversity by Family',
      infoText:
          'Complete summary of mammal species counts per taxonomic family.',
      exportDefaultFileName: 'family_diversity',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Family'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.speciesPerFamily.map((e) {
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final name = e.name ?? 'Unknown';
        return StatTableRow(
          values: [name, count, '$pct%'],
          searchText: name,
        );
      }).toList(),
    );
  }

  StatTablePage _genusTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species Diversity by Genus',
      infoText: 'Complete summary of mammal species counts per genus.',
      exportDefaultFileName: 'genus_diversity',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Genus', isItalic: true),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.speciesPerGenus.map((e) {
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final name = e.name ?? 'Unknown';
        return StatTableRow(
          values: [name, count, '$pct%'],
          searchText: name,
        );
      }).toList(),
    );
  }

  StatTablePage _decadeTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species Descriptions by Decade',
      infoText:
          'Complete distribution of mammal species descriptions grouped by decade.',
      exportDefaultFileName: 'descriptions_by_decade',
      defaultSortColumnIndex: 0,
      defaultSortAscending: true,
      columns: const [
        StatTableColumn(title: 'Decade'),
        StatTableColumn(title: 'Species Described', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.discoveryDecade.map((e) {
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final decade = e.decade != null ? '${e.decade}s' : 'Unknown';
        return StatTableRow(
          values: [decade, count, '$pct%'],
          searchText: decade,
        );
      }).toList(),
    );
  }

  StatTablePage _yearTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species Descriptions by Year',
      infoText:
          'Complete distribution of mammal species descriptions by publication year.',
      exportDefaultFileName: 'descriptions_by_year',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Year'),
        StatTableColumn(title: 'Species Described', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.discoveryYear.map((e) {
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final year = e.year?.toString() ?? 'Unknown';
        return StatTableRow(
          values: [year, count, '$pct%'],
          searchText: year,
        );
      }).toList(),
    );
  }

  StatTablePage _imagesTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species with Most Images',
      infoText:
          'Mammal species ranked by number of documented images in the database.',
      exportDefaultFileName: 'species_with_most_images',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Species', isItalic: true),
        StatTableColumn(title: 'Images Count', numeric: true),
        StatTableColumn(title: 'Percentage of Images', numeric: true),
      ],
      rows: stats.speciesWithMostImages.map((e) {
        final count = e.imageCount;
        final total = stats.totalImagesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final species = '${e.genus ?? ''} ${e.specificEpithet ?? ''}'.trim();
        return StatTableRow(
          values: [species, count, '$pct%'],
          searchText: species,
        );
      }).toList(),
    );
  }

  StatTablePage _imagesPieTablePage(MddStatistics stats) {
    final withImg = stats.speciesWithImagesCount;
    final withoutImg = stats.totalSpeciesCount - stats.speciesWithImagesCount;
    final total = stats.totalSpeciesCount;
    final withPct =
        total > 0 ? (withImg / total * 100).toStringAsFixed(2) : '0.00';
    final withoutPct =
        total > 0 ? (withoutImg / total * 100).toStringAsFixed(2) : '0.00';

    return StatTablePage(
      title: 'Proportion of Species with Images',
      infoText:
          'Comparison of mammal species with documented images versus those without.',
      exportDefaultFileName: 'species_with_images_proportion',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Category'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: [
        StatTableRow(
          values: ['With Images', withImg, '$withPct%'],
          searchText: 'With Images',
        ),
        StatTableRow(
          values: ['Without Images', withoutImg, '$withoutPct%'],
          searchText: 'Without Images',
        ),
      ],
    );
  }

  StatTablePage _synonymsTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Species with the Most Names and Synonyms',
      infoText:
          'Mammal species ranked by number of recorded synonyms and historical names.',
      exportDefaultFileName: 'species_with_most_synonyms',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Species', isItalic: true),
        StatTableColumn(title: 'Synonyms Count', numeric: true),
        StatTableColumn(title: 'Percentage of Synonyms', numeric: true),
      ],
      rows: stats.speciesWithMostSynonyms.map((e) {
        final count = e.count;
        final total = stats.totalSynonymsCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        final species = '${e.genus ?? ''} ${e.specificEpithet ?? ''}'.trim();
        return StatTableRow(
          values: [species, count, '$pct%'],
          searchText: species,
        );
      }).toList(),
    );
  }

  StatTablePage _typeKindTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Proportion of Type Kind',
      infoText:
          'Distribution of specimen type designations across mammalian species.',
      exportDefaultFileName: 'type_kind_proportion',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Type Kind'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.typeKindProportion.map((e) {
        final count = e.value;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        return StatTableRow(
          values: [e.key, count, '$pct%'],
          searchText: e.key,
        );
      }).toList(),
    );
  }

  StatTablePage _iucnTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'IUCN Red List Conservation Status',
      infoText:
          'Distribution of mammal species across IUCN Red List conservation categories.',
      exportDefaultFileName: 'iucn_conservation_status',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'IUCN Status'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.iucnStatus.map((e) {
        final count = e.value;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        return StatTableRow(
          values: [e.key, count, '$pct%'],
          searchText: e.key,
        );
      }).toList(),
    );
  }

  StatTablePage _realmTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Distribution by Biogeographic Realm',
      infoText:
          'Distribution of mammal species occurrences across major biogeographic realms.',
      exportDefaultFileName: 'biogeographic_realm_distribution',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Realm'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.biogeographicRealm.map((e) {
        final count = e.value;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        return StatTableRow(
          values: [e.key, count, '$pct%'],
          searchText: e.key,
        );
      }).toList(),
    );
  }

  StatTablePage _extinctTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Extinct vs. Extant Species',
      infoText:
          'Breakdown of recent extinct species compared to extant (living) mammal species.',
      exportDefaultFileName: 'extinct_vs_extant_species',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Status'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.extinctSpecies.map((e) {
        final isExtinct = e.isExtinct == 1;
        final status = isExtinct ? 'Extinct' : 'Extant';
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        return StatTableRow(
          values: [status, count, '$pct%'],
          searchText: status,
        );
      }).toList(),
    );
  }

  StatTablePage _domesticTablePage(MddStatistics stats) {
    return StatTablePage(
      title: 'Domesticated vs. Wild Species',
      infoText:
          'Breakdown of domesticated species compared to wild mammal species.',
      exportDefaultFileName: 'domesticated_vs_wild_species',
      defaultSortColumnIndex: 1,
      defaultSortAscending: false,
      columns: const [
        StatTableColumn(title: 'Category'),
        StatTableColumn(title: 'Species Count', numeric: true),
        StatTableColumn(title: 'Percentage', numeric: true),
      ],
      rows: stats.domesticSpecies.map((e) {
        final isDomestic = e.isDomestic == 1;
        final category = isDomestic ? 'Domesticated' : 'Wild';
        final count = e.count;
        final total = stats.totalSpeciesCount;
        final pct =
            total > 0 ? (count / total * 100).toStringAsFixed(2) : '0.00';
        return StatTableRow(
          values: [category, count, '$pct%'],
          searchText: category,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const InfoCard(
                      text: 'View visual summaries and metrics on mammalian '
                          'diversity, geography, and conservation.',
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Species Diversity by Order',
                        chart: OrderBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_orderTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Species Diversity by Family',
                        chart: FamilyBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_familyTablePage(stats)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Species Diversity by Genus',
                        chart: GenusBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_genusTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Species Diversity by Country',
                        chart: CountryBarChart(stats: stats),
                        viewTableLabel: 'View Full Country Table',
                        onViewTable: () =>
                            _navigateTo(const CountryTablePage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Species Descriptions by Decade',
                        chart: DecadeBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_decadeTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Species Descriptions by Year',
                        chart: YearBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_yearTablePage(stats)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Species with Most Images',
                        chart: ImagesBarChart(stats: stats),
                        onViewTable: () => _navigateTo(_imagesTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Proportion of Species with Images',
                        chart: ImagesPieChart(stats: stats),
                        onViewTable: () =>
                            _navigateTo(_imagesPieTablePage(stats)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Species with the Most Names and Synonyms',
                        chart: SynonymsBarChart(stats: stats),
                        onViewTable: () =>
                            _navigateTo(_synonymsTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Proportion of Type Kind',
                        chart: TypeKindPieChart(stats: stats),
                        onViewTable: () =>
                            _navigateTo(_typeKindTablePage(stats)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'IUCN Red List Conservation Status',
                        chart: IucnPieChart(stats: stats),
                        onViewTable: () => _navigateTo(_iucnTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Distribution by Biogeographic Realm',
                        chart: RealmPieChart(stats: stats),
                        onViewTable: () => _navigateTo(_realmTablePage(stats)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChartRow(
                      isWide: isWide,
                      chart1: ChartCard(
                        title: 'Extinct vs. Extant Species',
                        chart: ExtinctPieChart(stats: stats),
                        onViewTable: () =>
                            _navigateTo(_extinctTablePage(stats)),
                      ),
                      chart2: ChartCard(
                        title: 'Domesticated vs. Wild Species',
                        chart: DomesticPieChart(stats: stats),
                        onViewTable: () =>
                            _navigateTo(_domesticTablePage(stats)),
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
      ),
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({
    required this.chart1,
    required this.chart2,
    required this.isWide,
  });

  final Widget chart1;
  final Widget chart2;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: chart1),
          const SizedBox(width: 16),
          Expanded(child: chart2),
        ],
      );
    }
    return Column(
      children: [
        chart1,
        const SizedBox(height: 16),
        chart2,
      ],
    );
  }
}

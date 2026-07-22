import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/statistics.dart';

class CountrySpeciesPage extends ConsumerWidget {
  final CountryDiversityData countryData;

  const CountrySpeciesPage({
    super.key,
    required this.countryData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speciesAsync =
        ref.watch(mainTaxonomyDataProvider(countryData.speciesIds));

    final String extinctText = countryData.totalExtinctSpecies > 0
        ? ' and ${countryData.totalExtinctSpecies} extinct'
        : '';
    final String descriptionText =
        'The mammalian diversity of ${countryData.countryName} consists of '
        '${countryData.totalLivingSpecies} living$extinctText species in '
        '${countryData.totalOrders} orders, ${countryData.totalFamilies} families, '
        'and ${countryData.totalGenera} genera. '
        'Excludes widespread and domesticated species.';

    return Scaffold(
      appBar: AppBar(
        title: Text(countryData.countryName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InfoCard(text: descriptionText),
            ),
            Expanded(
              child: speciesAsync.when(
                data: (List<MainTaxonomyData> speciesList) {
                  if (speciesList.isEmpty) {
                    return const Center(
                      child: Text('No species found for this country.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: speciesList.length,
                    itemBuilder: (context, index) {
                      final species = speciesList[index];
                      return SpeciesTile(
                        taxonData: species,
                        isOddIndex: index.isOdd,
                      );
                    },
                  );
                },
                loading: () => const DataLoadingMessages(isSimple: false),
                error: (error, stack) =>
                    Center(child: Text('Error loading species: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

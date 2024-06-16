import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';

class SearchSpecies extends ConsumerStatefulWidget {
  const SearchSpecies({super.key});

  @override
  SearchSpeciesState createState() => SearchSpeciesState();
}

class SearchSpeciesState extends ConsumerState<SearchSpecies> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddSpeciesListResult> speciesList) {
            return ListView(
              children: <Widget>[
                ..._groupByOrder(speciesList).entries.map(
                  (MapEntry<String, List<MddSpeciesListResult>> entry) {
                    return ExpansionTile(
                      title: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      children: <Widget>[
                        SpeciesGroups(speciesList: entry.value),
                      ],
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    )),
                Text('Retrieving MDD list...'),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        );
  }

  Map<String, List<MddSpeciesListResult>> _groupByOrder(
      List<MddSpeciesListResult> speciesList) {
    final Map<String, List<MddSpeciesListResult>> groupedSpecies =
        <String, List<MddSpeciesListResult>>{};
    for (final MddSpeciesListResult species in speciesList) {
      if (groupedSpecies.containsKey(species.taxonOrder)) {
        groupedSpecies[species.taxonOrder]?.add(species);
      } else {
        groupedSpecies[species.taxonOrder ?? ''] = <MddSpeciesListResult>[
          species
        ];
      }
    }
    return groupedSpecies;
  }
}

class SpeciesGroups extends StatelessWidget {
  const SpeciesGroups({super.key, required this.speciesList});

  final List<MddSpeciesListResult> speciesList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...speciesList.map(
          (MddSpeciesListResult species) {
            return SpeciesTile(
              genus: species.genus ?? '',
              specificEpithet: species.specificEpithet ?? '',
              mainCommonName: species.mainCommonName ?? '',
            );
          },
        ),
      ],
    );
  }
}

class SpeciesTile extends StatelessWidget {
  const SpeciesTile({
    super.key,
    required this.genus,
    required this.specificEpithet,
    required this.mainCommonName,
  });

  final String genus;
  final String specificEpithet;
  final String mainCommonName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$genus $specificEpithet',
        style: Theme.of(context).textTheme.titleMedium?.apply(
              fontStyle: FontStyle.italic,
            ),
      ),
      subtitle: Text(
        mainCommonName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

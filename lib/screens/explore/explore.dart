import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/form.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/species_list.dart';

class ExploreSpecies extends ConsumerStatefulWidget {
  const ExploreSpecies({super.key});

  @override
  ExploreSpeciesState createState() => ExploreSpeciesState();
}

class ExploreSpeciesState extends ConsumerState<ExploreSpecies> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddGroupListResult> speciesList) {
            return ListView(
              children: <Widget>[
                ..._groupByOrder(speciesList).entries.map(
                  (MapEntry<String, List<MddGroupListResult>> entry) {
                    return ExpansionTile(
                      title: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      children: <Widget>[FamilyGroups(taxonList: entry.value)],
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Text('Error: $error. Stack trace: $stackTrace'),
          ),
        );
  }

  Map<String, List<MddGroupListResult>> _groupByOrder(
      List<MddGroupListResult> taxonList) {
    return TaxonGroupService(taxonList: taxonList).groupByOrder();
  }
}

class FamilyGroups extends StatelessWidget {
  const FamilyGroups({super.key, required this.taxonList});

  final List<MddGroupListResult> taxonList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ..._groupByFamily(taxonList).entries.map(
          (MapEntry<String, List<MddGroupListResult>> entry) {
            return ExpansionTile(
              leading: Icon(Icons.list_outlined,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: <Widget>[
                SpeciesGroups(
                    taxonIDList: entry.value.map((e) => e.id).toList()),
              ],
            );
          },
        ),
      ],
    );
  }

  Map<String, List<MddGroupListResult>> _groupByFamily(
      List<MddGroupListResult> taxonList) {
    return TaxonGroupService(taxonList: taxonList).groupByFamily();
  }
}

class SpeciesGroups extends ConsumerWidget {
  const SpeciesGroups({super.key, required this.taxonIDList});

  final List<int> taxonIDList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(mainTaxonomyDataProvider(taxonIDList)).when(
          data: (List<MainTaxonomyData> speciesList) {
            return Column(
              children: <Widget>[
                ...speciesList.map(
                  (MainTaxonomyData taxonData) {
                    return SpeciesTile(taxonData: taxonData);
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    )),
                Text('Retrieving species list...'),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

class SpeciesTile extends ConsumerWidget {
  const SpeciesTile({
    super.key,
    required this.taxonData,
  });

  final MainTaxonomyData taxonData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          visualDensity: VisualDensity.compact,
          tileColor: Theme.of(context).colorScheme.primary.withAlpha(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            '${taxonData.genus} ${taxonData.specificEpithet}',
            style: Theme.of(context).textTheme.titleMedium?.apply(
                  fontStyle: FontStyle.italic,
                ),
          ),
          subtitle: Text(
            taxonData.mainCommonName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.info_outline),
          onTap: () {
            ref.read(currentMddIDProvider.notifier).setMddID(taxonData.id);
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SpeciesPage(),
              ),
            );
          },
        ));
  }
}

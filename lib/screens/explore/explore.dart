import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreSpecies extends ConsumerStatefulWidget {
  const ExploreSpecies({super.key});

  @override
  ExploreSpeciesState createState() => ExploreSpeciesState();
}

class ExploreSpeciesState extends ConsumerState<ExploreSpecies> {
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
              speciesData: species,
            );
          },
        ),
      ],
    );
  }
}

class SpeciesTile extends ConsumerWidget {
  const SpeciesTile({
    super.key,
    required this.speciesData,
  });

  final MddSpeciesListResult speciesData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          visualDensity: VisualDensity.compact,
          tileColor:
              Theme.of(context).colorScheme.tertiaryContainer.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            '${speciesData.genus} ${speciesData.specificEpithet}',
            style: Theme.of(context).textTheme.titleMedium?.apply(
                  fontStyle: FontStyle.italic,
                ),
          ),
          subtitle: Text(
            speciesData.mainCommonName ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite_border_outlined),
            onPressed: () {
              ref.read(taxonDataProvider.notifier).setMddID(speciesData.id);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SpeciesPage(),
                ),
              );
            },
          ),
          onTap: () {
            ref.read(taxonDataProvider.notifier).setMddID(speciesData.id);
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

class SpeciesPage extends ConsumerWidget {
  const SpeciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxon Information'),
      ),
      body: Center(
        child: ref.watch(taxonDataProvider).when(
              data: (TaxonomyData taxonData) {
                return TaxonForm(taxonData: taxonData);
              },
              loading: () => const CircularProgressIndicator(),
              error: (Object error, StackTrace stackTrace) {
                return Text('Error: $error');
              },
            ),
      ),
    );
  }
}

class TaxonForm extends StatelessWidget {
  const TaxonForm({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('MDD ID: ${taxonData.id}'),
            Text('${taxonData.genus} ${taxonData.specificEpithet}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.apply(fontStyle: FontStyle.italic)),
            Text(
              '${taxonData.mainCommonName}',
            ),
            const SizedBox(height: 8),
            ContentText(
              title: 'Authority citation',
              content: taxonData.authoritySpeciesCitation,
            ),
            const SizedBox(height: 8),
            ContentText(
              title: 'Authority publication link',
              content: taxonData.authoritySpeciesLink,
              isUrl: true,
            ),
            const SizedBox(height: 16),
            ContentText(
              title: 'Nominal name',
              content: taxonData.nominalNames,
            ),
            const SizedBox(height: 16),
            ContentText(
              title: 'Type locality',
              content: taxonData.typeLocality,
            ),
            const SizedBox(height: 8),
            ContentText(
              title: 'Distribution',
              content: taxonData.distributionNotes,
            ),
            const SizedBox(height: 16),
            ContentText(
              title: 'IUCN Red List status',
              content: _matchIucnStatus(taxonData.iucnStatus),
            ),
          ],
        ),
      ),
    );
  }

  String _matchIucnStatus(String? iucnStatus) {
    switch (iucnStatus) {
      case 'LC':
        return 'Least Concern';
      case 'NT':
        return 'Near Threatened';
      case 'VU':
        return 'Vulnerable';
      case 'EN':
        return 'Endangered';
      case 'CR':
        return 'Critically Endangered';
      case 'EW':
        return 'Extinct in the Wild';
      case 'EX':
        return 'Extinct';
      default:
        return 'Not Evaluated';
    }
  }
}

class ContentText extends StatelessWidget {
  const ContentText({
    super.key,
    required this.title,
    required this.content,
    this.isUrl = false,
  });

  final String title;
  final String? content;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        isUrl
            ? InkWell(
                child: Text(
                  content ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  _launchURL(content ?? '');
                },
              )
            : Text(
                content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
      ],
    );
  }

  void _launchURL(String url) async {
    // Open URL
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

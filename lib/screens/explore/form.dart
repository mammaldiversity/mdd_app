import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:url_launcher/url_launcher.dart';

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

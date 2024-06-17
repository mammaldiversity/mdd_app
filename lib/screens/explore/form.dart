import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/species_list.dart';
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
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            SpeciesDetails(taxonData: taxonData),
            Expanded(
              child: OtherDetails(taxonData: taxonData),
            )
          ],
        ));
  }
}

class SpeciesDetails extends StatelessWidget {
  const SpeciesDetails({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Column(
        children: <Widget>[
          SpeciesTextView(taxonData: taxonData),
          const SizedBox(height: 4),
          Text(
            '${taxonData.mainCommonName}',
            style: Theme.of(context).textTheme.titleMedium?.apply(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}

class OtherDetails extends StatelessWidget {
  const OtherDetails({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(height: 8),
        Center(
          child: Text('MDD ID: ${taxonData.id}'),
        ),
        ContentText(
          title: 'Authority citation',
          content: taxonData.authoritySpeciesCitation,
        ),
        ContentText(
          title: 'Authority publication link',
          content: taxonData.authoritySpeciesLink,
          isUrl: true,
        ),
        ContentText(
          title: 'Original name as described',
          content: taxonData.originalNameCombination?.replaceAll('_', ' '),
          isItalic: true,
        ),
        ContentText(
          title: 'Nominal names',
          content: taxonData.nominalNames,
        ),
        ContentText(
          title: 'Other common names',
          content: taxonData.otherCommonNames,
        ),
        ContentText(
          title: 'Holotype voucher catalogue number',
          content: taxonData.holotypeVoucher,
        ),
        ContentText(
          title: 'Type locality',
          content: taxonData.typeLocality,
        ),
        ContentText(
          title: 'Country distribution',
          content: taxonData.countryDistribution,
        ),
        ContentText(
          title: 'Distribution notes',
          content: taxonData.distributionNotes,
        ),
        ContentText(
          title: 'Distribution references',
          content: taxonData.distributionNotesCitation,
        ),
        if (taxonData.taxonomyNotes != 'NA')
          ContentText(
            title: 'Taxonomy notes',
            content: taxonData.taxonomyNotes,
          ),
        if (taxonData.taxonomyNotesCitation != 'NA')
          ContentText(
            title: 'Taxonomy notes citation',
            content: taxonData.taxonomyNotesCitation,
          ),
        ContentText(
          title: 'IUCN Red List status',
          content: matchIUCNStatus(taxonData.iucnStatus),
        ),
      ],
    );
  }
}

class SpeciesTextView extends StatelessWidget {
  const SpeciesTextView({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    final SpeciesText speciesText = SpeciesText(taxonData: taxonData);
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: speciesText.speciesName,
              style: Theme.of(context).textTheme.titleLarge?.apply(
                    fontFamily: 'Libre Baskerville',
                    fontStyle: FontStyle.italic,
                    fontWeightDelta: 1,
                    fontSizeDelta: 4,
                    letterSpacingDelta: 1,
                  ),
            ),
            const TextSpan(text: '\n'),
            TextSpan(
              text: speciesText.speciesAuthorCitation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ));
  }
}

class ContentText extends StatelessWidget {
  const ContentText({
    super.key,
    required this.title,
    required this.content,
    this.isUrl = false,
    this.isItalic = false,
  });

  final String title;
  final String? content;
  final bool isUrl;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return content != null && content!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
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
                        style: isItalic
                            ? Theme.of(context).textTheme.bodyMedium?.apply(
                                  fontStyle: FontStyle.italic,
                                )
                            : Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          )
        : const SizedBox.shrink();
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

class UrlText extends StatelessWidget {
  const UrlText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

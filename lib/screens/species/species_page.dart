import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/species/synonyms.dart';
import 'package:mdd/screens/species/taxonomy.dart';
import 'package:mdd/services/app_services.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/species_list.dart';

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
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: OtherDetails(taxonData: taxonData)),
            ),
            const SizedBox(height: 80, child: SynonymList()),
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
        ClassificationContainer(taxonData: taxonData),
        const SizedBox(height: 4),
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
          content: taxonData.typeVoucher,
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
        ContentText(
          title: 'Species Permalink',
          content: generatePermanentLink(taxonData.id),
          isUrl: true,
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
                    letterSpacingDelta: 0.8,
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
                    ? UrlText(content: content)
                    : StandardText(content: content, isItalic: isItalic),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class UrlText extends StatelessWidget {
  const UrlText({super.key, required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        content ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.apply(
              decoration: TextDecoration.underline,
            ),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        launchURL(content ?? '');
      },
    );
  }
}

class StandardText extends StatelessWidget {
  const StandardText({
    super.key,
    required this.content,
    required this.isItalic,
  });

  final String? content;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return Text(
      _cleanText(content),
      style: isItalic
          ? Theme.of(context).textTheme.bodyMedium?.apply(
                fontStyle: FontStyle.italic,
                letterSpacingDelta: 0.8,
              )
          : Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  String _cleanText(String? text) {
    if (text == null) {
      return '';
    }
    // We use middle dot as a separator for
    // easier reading in the database
    return text.replaceAll('|', ' • ');
  }
}

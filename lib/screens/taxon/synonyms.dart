import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/taxon/common.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/system.dart';

class SynonymList extends ConsumerWidget {
  const SynonymList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(synonymDataProvider).when(
          data: (synonymData) {
            return synonymData.isNotEmpty
                ? SynonymContainer(data: synonymData)
                : const Center(child: Text('No synonyms found.'));
          },
          loading: () => const SimpleLoadingOnly(),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

class SynonymContainer extends StatelessWidget {
  const SynonymContainer({super.key, required this.data});

  final List<db.SynonymData> data;

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        const Divider(),
        const SizedBox(height: 8),
        Text('Synonyms', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        screenType != ScreenType.small
            ? Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: data
                    .map(
                      (synonymData) => SynonymCard(data: synonymData),
                    )
                    .toList(),
              )
            : Column(
                children: data
                    .map(
                      (synonymData) => SynonymCard(data: synonymData),
                    )
                    .toList(),
              ),
      ]),
    );
  }
}

class SynonymCard extends StatefulWidget {
  const SynonymCard({super.key, required this.data});

  final db.SynonymData data;

  @override
  State<SynonymCard> createState() => _SynonymCardState();
}

class _SynonymCardState extends State<SynonymCard> {
  @override
  Widget build(BuildContext context) {
    final String taxonName = _createSynName();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: OutlinedButton(
        child: Text(
          taxonName,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          _showDetails(getScreenType(context), taxonName);
        },
      ),
    );
  }

  String _createSynName() {
    final String author = widget.data.author ?? '';
    final String species = widget.data.species ?? '';
    final String year = widget.data.year ?? '';
    if (widget.data.authorityParentheses == 1) {
      return '$species ($author, $year)';
    } else {
      return '$species $author $year';
    }
  }

  // Show modal sheet on mobile and alert dialog on desktop
  void _showDetails(ScreenType screenType, String taxonName) {
    if (screenType == ScreenType.small) {
      showModalBottomSheet(
        context: context,
        enableDrag: true,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        builder: (BuildContext context) {
          return SynonymDetails(
            data: widget.data,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SynonymDetails(data: widget.data),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}

class SynonymTitle extends StatelessWidget {
  const SynonymTitle({
    super.key,
    required this.species,
    required this.author,
    required this.year,
    required this.withParentheses,
  });

  final String? species;
  final String? author;
  final String? year;
  final bool withParentheses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            species ?? '',
            style: Theme.of(context).textTheme.titleLarge?.apply(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            _getAuthority(),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _getAuthority() {
    if (withParentheses) {
      return '($author, $year)';
    } else {
      return '$author $year';
    }
  }
}

class SynonymDetails extends StatelessWidget {
  const SynonymDetails({
    super.key,
    required this.data,
  });

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SynonymTitle(
          species: data.species,
          author: data.author,
          year: data.year,
          withParentheses: data.authorityParentheses == 1,
        ),
        Expanded(
          child: OtherSynonymData(data: data),
        ),
      ],
    );
  }
}

class OtherSynonymData extends StatelessWidget {
  const OtherSynonymData({super.key, required this.data});

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContentText(
            title: "Family",
            content: data.family,
          ),
          ContentText(
            title: "Holotype",
            content: data.holotype,
          ),
          ContentText(
            title: "Name Usages",
            content: data.nameUsages,
          ),
          ContentText(
            title: "Authority Citation",
            content: data.authorityCitation,
          ),
          ContentText(
            title: "Authority Link",
            content: data.authorityLink,
            isUrl: true,
          ),
          ContentText(
            title: "Authority Page",
            content: data.authorityPage,
          ),
          ContentText(
            title: "Authority Page Link",
            content: data.authorityPageLink,
            isUrl: true,
          ),
          ContentText(
            title: "Authority Publication",
            content: data.citationGroup,
          ),
          ContentText(
            title: "Authority Publication Link",
            content: data.citationKind,
          ),
          ContentText(
            title: "Comments",
            content: data.comments,
          ),
        ],
      ),
    );
  }
}

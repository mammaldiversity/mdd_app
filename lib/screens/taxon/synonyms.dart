import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/taxon/common.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/synonyms.dart';
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
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
    final ({String authorYear, String name}) synName =
        SynonymName(data: widget.data).getSynonym();
    return '${synName.name} ${synName.authorYear}';
  }

  // Show modal sheet on mobile and alert dialog on desktop
  void _showDetails(ScreenType screenType, String taxonName) {
    if (screenType == ScreenType.small) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        builder: (BuildContext context) {
          return SynonymSheet(
            data: widget.data,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SynonymDialogs(
            data: widget.data,
          );
        },
      );
    }
  }
}

class SynonymDialogs extends StatelessWidget {
  const SynonymDialogs({
    super.key,
    required this.data,
  });

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: SynonymSheet(data: data),
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
  }
}

class SynonymSheet extends StatelessWidget {
  const SynonymSheet({
    super.key,
    required this.data,
  });

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    final ({String authorYear, String name}) synName =
        SynonymName(data: data).getSynonym();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SynonymTitle(
          synName: synName.name,
          authorYear: synName.authorYear,
        ),
        Flexible(
          child: OtherSynonymData(data: data),
        ),
      ],
    );
  }
}

class SynonymTitle extends StatelessWidget {
  const SynonymTitle(
      {super.key, required this.synName, required this.authorYear});

  final String synName;
  final String authorYear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            synName,
            style: Theme.of(context).textTheme.titleLarge?.apply(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            authorYear,
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
            title: "Root Name",
            content: data.rootName,
            isItalic: true,
          ),
          ContentText(
            title: "Validity Status",
            content: data.validity,
          ),
          ContentText(
            title: "Nomenclature Status",
            content: data.nomenclatureStatus,
          ),
          ContentText(
            title: "Type Material",
            content: data.holotype,
          ),
          ContentText(
            title: "Type Kind",
            content: data.typeKind,
          ),
          ContentText(
            title: "Type Specimen Link",
            content: data.typeSpecimenLink,
            isUrl: true,
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
            title: "Name Usages",
            content: data.nameUsages,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/taxon/common.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/synonyms.dart';
import 'package:mdd/services/system.dart';

const String synonymDescription =
    'Present and past (if available) associated names to the species.';

class SynonymList extends ConsumerWidget {
  const SynonymList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(synonymDataProvider).when(
          data: (synonymData) {
            return synonymData.isNotEmpty
                ? SynonymContainer(data: synonymData)
                : const Center(
                    child: Text('No associated names and synonyms found.'),
                  );
          },
          loading: () => const SizedBox.shrink(),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

class SynonymContainer extends StatefulWidget {
  const SynonymContainer({super.key, required this.data});

  final List<db.SynonymData> data;

  @override
  State<SynonymContainer> createState() => _SynonymContainerState();
}

class _SynonymContainerState extends State<SynonymContainer> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    final bool hasMore = widget.data.length > 10;
    final List<db.SynonymData> displayData =
        _showAll || !hasMore ? widget.data : widget.data.take(10).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CommonCard(
        title: 'Names and synonyms',
        description: synonymDescription,
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              screenType != ScreenType.small
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: displayData
                          .map((synonymData) => SynonymCard(data: synonymData))
                          .toList(),
                    )
                  : Column(
                      children: displayData
                          .map((synonymData) => SynonymCard(data: synonymData))
                          .toList(),
                    ),
              if (hasMore && !_showAll) ...[
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showAll = true;
                    });
                  },
                  child: Text(
                    'Show all (${widget.data.length}) synonyms',
                  ),
                ),
              ],
            ],
          ),
        ),
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
    final SynonymName synonymObj = SynonymName(data: widget.data);
    final ({String authorYear, String name}) synName = synonymObj.getSynonym();
    final String separator = synonymObj.getAuthoritySeparator();
    return '${synName.name}$separator${synName.authorYear}';
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
          return SynonymSheet(data: widget.data);
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SynonymDialogs(data: widget.data);
        },
      );
    }
  }
}

class SynonymDialogs extends StatelessWidget {
  const SynonymDialogs({super.key, required this.data});

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
  const SynonymSheet({super.key, required this.data});

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    final SynonymName synonymObj = SynonymName(data: data);
    final ({String authorYear, String name}) synName = synonymObj.getSynonym();
    return SelectionArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SynonymTitle(
            synName: synName.name,
            authorYear: synName.authorYear,
            separator: synonymObj.getAuthoritySeparator(),
          ),
          Flexible(child: OtherSynonymData(data: data)),
        ],
      ),
    );
  }
}

class SynonymTitle extends StatelessWidget {
  const SynonymTitle({
    super.key,
    required this.synName,
    required this.authorYear,
    required this.separator,
  });

  final String synName;
  final String authorYear;
  final String separator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            '$synName${separator.trimRight()}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.apply(fontStyle: FontStyle.italic),
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
          ContentText(title: "Family", content: data.family),
          ContentText(
            title: "Root name",
            content: data.rootName,
            isItalic: true,
          ),
          ContentText(title: "Validity status", content: data.validity),
          ContentText(
            title: "Nomenclatural status",
            content: data.nomenclatureStatus,
          ),
          ContentText(title: "Type", content: data.holotype),
          ContentText(title: "Type kind", content: data.typeKind),
          ContentText(
            title: "Original type locality",
            content: data.originalTypeLocality,
          ),
          ContentText(
            title: "Type locality",
            content: SynonymName(data: data).createStructuredTypeLocality(),
          ),
          ContentText(
            title: "Type specimen URI",
            content: data.typeSpecimenLink,
            isUrl: true,
          ),
          ContentText(title: "Authority page", content: data.authorityPage),
          ContentText(
            title: "Authority page URI",
            content: data.authorityPageLink,
            isUrl: true,
          ),
          ContentText(
            title: "Authority publication",
            content: data.citationGroup,
          ),
          ContentText(title: "Name usages", content: data.nameUsages),
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/screens/taxon/higher_taxon.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/system.dart';
import 'package:mdd/services/taxon_tree.dart';

class ClassificationContainer extends StatelessWidget {
  const ClassificationContainer({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    return CommonCard(
      title: 'Taxonomy',
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: screenType == ScreenType.small
            ? Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SubOrderAndHigherTaxa(taxonData: taxonData),
                  LowerInfraOrderTaxa(taxonData: taxonData),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SubOrderAndHigherTaxa(taxonData: taxonData)),
                  Expanded(child: LowerInfraOrderTaxa(taxonData: taxonData)),
                ],
              ),
      ),
    );
  }
}

class SubOrderAndHigherTaxa extends StatelessWidget {
  const SubOrderAndHigherTaxa({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClassificationData(rank: TaxonRank.subclass, name: taxonData.subclass),
        ClassificationData(
          rank: TaxonRank.infraclass,
          name: taxonData.infraclass,
        ),
        ClassificationData(
          rank: TaxonRank.magnorder,
          name: taxonData.magnorder,
        ),
        ClassificationData(
          rank: TaxonRank.superorder,
          name: taxonData.superorder,
        ),
        ClassificationData(rank: TaxonRank.order, name: taxonData.taxonOrder),
        ClassificationData(rank: TaxonRank.suborder, name: taxonData.suborder),
      ],
    );
  }
}

class LowerInfraOrderTaxa extends StatelessWidget {
  const LowerInfraOrderTaxa({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClassificationData(
          rank: TaxonRank.infraorder,
          name: taxonData.infraorder,
        ),
        ClassificationData(
          rank: TaxonRank.parvorder,
          name: taxonData.parvorder,
        ),
        ClassificationData(
          rank: TaxonRank.superfamily,
          name: taxonData.superfamily,
        ),
        ClassificationData(rank: TaxonRank.family, name: taxonData.family),
        ClassificationData(
          rank: TaxonRank.subfamily,
          name: taxonData.subfamily,
        ),
        ClassificationData(rank: TaxonRank.tribe, name: taxonData.tribe),
        ClassificationData(rank: TaxonRank.genus, name: taxonData.genus),
        ClassificationData(rank: TaxonRank.subgenus, name: taxonData.subgenus),
      ],
    );
  }
}

/// One "Rank: Name" row. The name links to the taxon's page.
class ClassificationData extends StatefulWidget {
  const ClassificationData({super.key, required this.rank, required this.name});

  final TaxonRank rank;
  final String? name;

  @override
  State<ClassificationData> createState() => _ClassificationDataState();
}

class _ClassificationDataState extends State<ClassificationData> {
  late final TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () => openHigherTaxonPage(context, widget.rank, widget.name!);

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    if (name == null || name.isEmpty || name == 'NA') {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLink = !isPlaceholderTaxon(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${widget.rank.label}: ',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: name,
              recognizer: isLink ? _recognizer : null,
              mouseCursor: isLink ? SystemMouseCursors.click : null,
              semanticsLabel: isLink
                  ? 'Open ${widget.rank.label.toLowerCase()} $name'
                  : null,
              style: textTheme.bodyMedium?.copyWith(
                color: isLink ? colorScheme.primary : null,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: colorScheme.primary.withAlpha(120),
                fontStyle: widget.rank.isItalic
                    ? FontStyle.italic
                    : FontStyle.normal,
                letterSpacing: widget.rank.isItalic ? 0.8 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

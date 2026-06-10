import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/system.dart';

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
        ClassificationData(
          rank: 'Subclass',
          name: taxonData.subclass,
        ),
        ClassificationData(
          rank: 'Infraclass',
          name: taxonData.infraclass,
        ),
        ClassificationData(
          rank: 'Magnorder',
          name: taxonData.magnorder,
        ),
        ClassificationData(
          rank: 'Superorder',
          name: taxonData.superorder,
        ),
        ClassificationData(
          rank: 'Order',
          name: taxonData.taxonOrder,
        ),
        ClassificationData(
          rank: 'Suborder',
          name: taxonData.suborder,
        ),
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
          rank: 'Infraorder',
          name: taxonData.infraorder,
        ),
        ClassificationData(
          rank: 'Parvorder',
          name: taxonData.parvorder,
        ),
        ClassificationData(
          rank: 'Superfamily',
          name: taxonData.superfamily,
        ),
        ClassificationData(
          rank: 'Family',
          name: taxonData.family,
        ),
        ClassificationData(
          rank: 'Subfamily',
          name: taxonData.subfamily,
        ),
        ClassificationData(
          rank: 'Tribe',
          name: taxonData.tribe,
        ),
        ClassificationData(
          rank: 'Genus',
          name: taxonData.genus,
          isItalic: true,
        ),
      ],
    );
  }
}

class ClassificationData extends StatelessWidget {
  const ClassificationData({
    super.key,
    required this.rank,
    required this.name,
    this.isItalic = false,
  });

  final String rank;
  final String? name;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return name != null && name != 'NA'
        ? Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$rank: ',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  TextSpan(
                    text: name!,
                    style: isItalic
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.8,
                            )
                        : Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

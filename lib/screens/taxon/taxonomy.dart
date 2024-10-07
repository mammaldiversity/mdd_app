import 'package:flutter/material.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/system.dart';

class ClassificationContainer extends StatelessWidget {
  const ClassificationContainer({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    return Center(
        child: Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withAlpha(32),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Text(
              'Taxonomy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          screenType == ScreenType.small
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
                    SubOrderAndHigherTaxa(taxonData: taxonData),
                    LowerInfraOrderTaxa(taxonData: taxonData),
                  ],
                ),
        ],
      ),
    ));
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
        ? RichText(
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '$rank: ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                TextSpan(
                  text: name,
                  style: isItalic
                      ? Theme.of(context).textTheme.bodyMedium?.apply(
                            fontStyle: FontStyle.italic,
                            letterSpacingDelta: 0.8,
                          )
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ))
        : const SizedBox.shrink();
  }
}

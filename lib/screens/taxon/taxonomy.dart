import 'package:flutter/material.dart';
import 'package:mdd/services/database/database.dart';

class ClassificationContainer extends StatelessWidget {
  const ClassificationContainer({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      constraints: const BoxConstraints(maxWidth: 400),
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
          const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}

class ClassificationData extends StatelessWidget {
  const ClassificationData({
    super.key,
    required this.rank,
    required this.name,
  });

  final String rank;
  final String? name;

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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ))
        : const SizedBox.shrink();
  }
}

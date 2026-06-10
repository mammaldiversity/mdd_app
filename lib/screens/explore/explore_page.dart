import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/taxon/species.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/species_list.dart';
import 'package:mdd/services/common_names.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdd/screens/shared/info_card.dart';

class ExploreSpecies extends ConsumerStatefulWidget {
  const ExploreSpecies({super.key});

  @override
  ExploreSpeciesState createState() => ExploreSpeciesState();
}

class ExploreSpeciesState extends ConsumerState<ExploreSpecies> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddGroupListResult> speciesList) {
            return ListView(children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: InfoCard(text: 'Browse the taxonomy of mammals, from order down to species. Click on a species to view its details or use the search bar to find a specific species.'),
              ),
              ..._groupByOrder(speciesList).entries.map(
                (MapEntry<String, List<MddGroupListResult>> entry) {
                  return ExpansionTile(
                    iconColor: Theme.of(context).colorScheme.secondary,
                    leading: SvgPicture.asset(
                      'assets/order-icons/${entry.key.toLowerCase()}.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (BuildContext context) =>
                          const Icon(Icons.pets, size: 24),
                    ),
                    title: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      MammalianOrders().getCommonName(entry.key),
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: <Widget>[FamilyGroups(taxonList: entry.value)],
                  );
                },
              ),
            ]);
          },
          loading: () => const DataLoadingMessages(isSimple: false),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text('Error: $error. Stack trace: $stackTrace'),
          ),
        );
  }

  Map<String, List<MddGroupListResult>> _groupByOrder(
      List<MddGroupListResult> taxonList) {
    return TaxonGroupService(taxonList: taxonList).groupByOrder();
  }
}

class FamilyGroups extends StatelessWidget {
  const FamilyGroups({super.key, required this.taxonList});

  final List<MddGroupListResult> taxonList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ..._groupByFamily(taxonList).entries.map(
          (MapEntry<String, List<MddGroupListResult>> entry) {
            return ExpansionTile(
              iconColor: Theme.of(context).colorScheme.secondary,
              leading: Icon(Icons.view_list_rounded,
                  color:
                      Theme.of(context).colorScheme.secondary.withAlpha(200)),
              title: Text(entry.key,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis),
              children: <Widget>[
                GenusGroup(taxonList: entry.value),
              ],
            );
          },
        ),
      ],
    );
  }

  Map<String, List<MddGroupListResult>> _groupByFamily(
      List<MddGroupListResult> taxonList) {
    return TaxonGroupService(taxonList: taxonList).groupByFamily();
  }
}

class GenusGroup extends StatelessWidget {
  const GenusGroup({super.key, required this.taxonList});

  final List<MddGroupListResult> taxonList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ..._groupByGenus(taxonList).entries.map(
          (MapEntry<String, List<MddGroupListResult>> entry) {
            return ExpansionTile(
              iconColor: Theme.of(context).colorScheme.secondary,
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withAlpha(40),
              title: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.apply(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              children: <Widget>[
                SpeciesGroups(
                    taxonIDList: entry.value.map((e) => e.id).toList()),
              ],
            );
          },
        ),
      ],
    );
  }

  Map<String, List<MddGroupListResult>> _groupByGenus(
      List<MddGroupListResult> taxonList) {
    return TaxonGroupService(taxonList: taxonList).groupByGenus();
  }
}

class SpeciesGroups extends ConsumerWidget {
  const SpeciesGroups({super.key, required this.taxonIDList});

  final List<int> taxonIDList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(mainTaxonomyDataProvider(taxonIDList)).when(
          data: (List<MainTaxonomyData> speciesList) {
            return Column(
              children: <Widget>[
                // map list tile with index
                ...List.generate(speciesList.length, (index) {
                  return SpeciesTile(
                    taxonData: speciesList[index],
                    isOddIndex: index.isOdd,
                  );
                }),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    )),
                Text('Retrieving species list...'),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

class SpeciesTileImage extends ConsumerStatefulWidget {
  const SpeciesTileImage({super.key, required this.mddId});
  final int mddId;

  @override
  ConsumerState<SpeciesTileImage> createState() => _SpeciesTileImageState();
}

class _SpeciesTileImageState extends ConsumerState<SpeciesTileImage> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int length) {
    _timer?.cancel();
    if (length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % length;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final milDataAsync = ref.watch(milDataFamilyProvider(widget.mddId));

    return milDataAsync.when(
      data: (data) {
        final landscapeImages =
            data.where((e) => e.orientation == 'landscape').toList();
        if (landscapeImages.isEmpty) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child:
                const Center(child: Icon(Icons.image_not_supported, size: 24)),
          );
        }

        if (_timer == null && landscapeImages.length > 1) {
          _startTimer(landscapeImages.length);
        }

        final safeIndex = _currentIndex % landscapeImages.length;
        final image = landscapeImages[safeIndex];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            'assets/mil-images/${image.milId}.webp',
            key: ValueKey(image.milId),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.broken_image, size: 24)),
            ),
          ),
        );
      },
      loading: () => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.error_outline, size: 24)),
      ),
    );
  }
}

class SpeciesTile extends ConsumerWidget {
  const SpeciesTile({
    super.key,
    required this.taxonData,
    required this.isOddIndex,
  });

  final MainTaxonomyData taxonData;
  final bool isOddIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultTileColor = isOddIndex
        ? Theme.of(context).colorScheme.secondary.withAlpha(32)
        : Color.lerp(
            Theme.of(context).colorScheme.secondary.withAlpha(32),
            Theme.of(context).colorScheme.surface,
            0.1,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: defaultTileColor,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 100,
                child: SpeciesTileImage(mddId: taxonData.id),
              ),
              Material(
                type: MaterialType.transparency,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                      left: 116, right: 16, top: 8, bottom: 8),
                  title: Text(
                    '${taxonData.genus} ${taxonData.specificEpithet}',
                    style: Theme.of(context).textTheme.titleMedium?.apply(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  subtitle: Text(
                    taxonData.mainCommonName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.info_outline, size: 20),
                  onTap: () {
                    ref
                        .read(currentMddIDProvider.notifier)
                        .setMddID(taxonData.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const SpeciesPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

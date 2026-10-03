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
import 'package:mdd/screens/explore/tree_view.dart';
import 'package:mdd/services/providers/settings.dart';
import 'package:mdd/services/taxon_tree.dart';

class ExploreSpecies extends ConsumerStatefulWidget {
  const ExploreSpecies({super.key});

  @override
  ExploreSpeciesState createState() => ExploreSpeciesState();
}

class ExploreSpeciesState extends ConsumerState<ExploreSpecies> {
  @override
  Widget build(BuildContext context) {
    final viewMode =
        ref.watch(exploreViewModeProvider).value ?? ExploreViewMode.list;

    return SafeArea(
      child: ref
          .watch(speciesListProvider)
          .when(
            data: (List<MddGroupListResult> speciesList) {
              final showInfo = ref.watch(showInfoTextProvider).value ?? false;
              final headers = <Widget>[
                if (showInfo)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: InfoCard(
                      text: 'Browse the taxonomy of mammals, from order down to species. Switch between the list and tree views, and tap a species to view its details.',
                    ),
                  ),
              ];
              // The toolbar stays pinned while the content scrolls.
              return Column(
                children: [
                  ExploreToolbar(viewMode: viewMode),
                  Expanded(
                    child: viewMode == ExploreViewMode.tree
                        ? _TreeContent(headers: headers)
                        : _ListContent(
                            headers: headers,
                            speciesList: speciesList,
                          ),
                  ),
                ],
              );
            },
            loading: () => const DataLoadingMessages(isSimple: false),
            error: (Object error, StackTrace stackTrace) =>
                Center(child: Text('Error: $error. Stack trace: $stackTrace')),
          ),
    );
  }
}

/// List/tree switch plus expand and collapse all.
class ExploreToolbar extends ConsumerWidget {
  const ExploreToolbar({super.key, required this.viewMode});

  final ExploreViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(taxonTreeProvider).value;
    final hasExpanded = ref.watch(
      expandedTaxaProvider.select((state) => state.keys.isNotEmpty),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          SegmentedButton<ExploreViewMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ExploreViewMode.list,
                icon: Icon(Icons.view_list_outlined),
                label: Text('List'),
              ),
              ButtonSegment(
                value: ExploreViewMode.tree,
                icon: Icon(Icons.account_tree_outlined),
                label: Text('Tree'),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (selection) {
              ref
                  .read(exploreViewModeProvider.notifier)
                  .setMode(selection.first);
            },
          ),
          const Spacer(),
          IconButton(
            tooltip: hasExpanded ? 'Collapse all' : 'Expand all',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasExpanded ? Icons.unfold_less : Icons.unfold_more,
                key: ValueKey(hasExpanded),
              ),
            ),
            onPressed: hasExpanded
                ? () => ref.read(expandedTaxaProvider.notifier).collapseAll()
                : tree == null
                    ? null
                    : () =>
                        ref.read(expandedTaxaProvider.notifier).expandAll(tree),
          ),
        ],
      ),
    );
  }
}

class _TreeContent extends ConsumerWidget {
  const _TreeContent({required this.headers});

  final List<Widget> headers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(expandedTaxaProvider).keys;
    return ref
        .watch(taxonTreeProvider)
        .when(
          data: (tree) {
            final rows = flattenVisible(tree, expanded);
            final leading = headers.length + 1;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: leading + rows.length,
              itemBuilder: (context, index) {
                if (index < headers.length) return headers[index];
                if (index == headers.length) return const TreeRootHeading();
                final row = rows[index - leading];
                return TaxonTreeRow(
                  key: ValueKey(row.node.key),
                  row: row,
                  isExpanded: expanded.contains(row.node.key),
                );
              },
            );
          },
          loading: () => const DataLoadingMessages(isSimple: false),
          error: (Object error, StackTrace stackTrace) =>
              Center(child: Text('Error: $error')),
        );
  }
}

class _ListContent extends ConsumerWidget {
  const _ListContent({required this.headers, required this.speciesList});

  final List<Widget> headers;
  final List<MddGroupListResult> speciesList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = TaxonGroupService(taxonList: speciesList)
        .groupByOrder()
        .entries
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length + headers.length,
      itemBuilder: (context, index) {
        if (index < headers.length) return headers[index];

        final entry = entries[index - headers.length];
        final commonName = MammalianOrders().getCommonName(entry.key);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(130),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _SyncedExpansionTile(
              taxonKey: entry.key,
              iconColor: colorScheme.primary,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/order-icons/${entry.key.toLowerCase()}.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (BuildContext context) =>
                      Icon(Icons.pets, size: 24, color: colorScheme.primary),
                ),
              ),
              title: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  if (commonName.isNotEmpty) commonName,
                  _speciesCountLabel(entry.value.length),
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: FamilyGroups(
                    parentKey: entry.key,
                    taxonList: entry.value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _speciesCountLabel(int count) =>
    count == 1 ? '1 species' : '$count species';

/// An [ExpansionTile] whose open state is stored in [expandedTaxaProvider],
/// so it survives switching views and responds to expand/collapse all.
class _SyncedExpansionTile extends ConsumerWidget {
  const _SyncedExpansionTile({
    required this.taxonKey,
    required this.iconColor,
    required this.tilePadding,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
  });

  final String taxonKey;
  final Color iconColor;
  final EdgeInsetsGeometry tilePadding;
  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(
      expandedTaxaProvider.select((state) => state.keys.contains(taxonKey)),
    );
    final generation = ref.watch(
      expandedTaxaProvider.select((state) => state.generation),
    );
    return ExpansionTile(
      key: ValueKey('$taxonKey#$generation'),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (value) =>
          ref.read(expandedTaxaProvider.notifier).setExpanded(taxonKey, value),
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: iconColor,
      collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      tilePadding: tilePadding,
      leading: leading,
      title: title,
      subtitle: subtitle,
      children: children,
    );
  }
}

class FamilyGroups extends StatelessWidget {
  const FamilyGroups({
    super.key,
    required this.parentKey,
    required this.taxonList,
  });

  final String parentKey;
  final List<MddGroupListResult> taxonList;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final families = _groupByFamily(taxonList).entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: List.generate(families.length, (index) {
        final entry = families[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withAlpha(140),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(90),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _SyncedExpansionTile(
              taxonKey: '$parentKey/${entry.key}',
              iconColor: colorScheme.secondary,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 2,
              ),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.list_outlined,
                  size: 20,
                  color: colorScheme.secondary,
                ),
              ),
              title: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _speciesCountLabel(entry.value.length),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
                  child: GenusGroup(
                    parentKey: '$parentKey/${entry.key}',
                    taxonList: entry.value,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Map<String, List<MddGroupListResult>> _groupByFamily(
    List<MddGroupListResult> taxonList,
  ) {
    return TaxonGroupService(taxonList: taxonList).groupByFamily();
  }
}

class GenusGroup extends StatelessWidget {
  const GenusGroup({
    super.key,
    required this.parentKey,
    required this.taxonList,
  });

  final String parentKey;
  final List<MddGroupListResult> taxonList;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final genera = _groupByGenus(taxonList).entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: List.generate(genera.length, (index) {
        final entry = genera[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withAlpha(160),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(80),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _SyncedExpansionTile(
              taxonKey: '$parentKey/${entry.key}',
              iconColor: colorScheme.tertiary,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              leading: Icon(
                Icons.label_outlined,
                size: 24,
                color: colorScheme.outlineVariant,
              ),
              title: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                _speciesCountLabel(entry.value.length),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SpeciesGroups(
                    taxonIDList: entry.value.map((e) => e.id).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Map<String, List<MddGroupListResult>> _groupByGenus(
    List<MddGroupListResult> taxonList,
  ) {
    return TaxonGroupService(taxonList: taxonList).groupByGenus();
  }
}

class SpeciesGroups extends ConsumerWidget {
  const SpeciesGroups({super.key, required this.taxonIDList});

  final List<int> taxonIDList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(mainTaxonomyDataProvider(taxonIDList))
        .when(
          data: (List<MainTaxonomyData> speciesList) {
            return Column(
              children: <Widget>[
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
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return milDataAsync.when(
      data: (data) {
        final landscapeImages = data
            .where((e) => e.orientation == 'landscape')
            .toList();
        if (landscapeImages.isEmpty) {
          return Container(
            color: colorScheme.surfaceContainerHighest.withAlpha(120),
            child: Center(
              child: Icon(
                Icons.pets,
                size: 20,
                color: colorScheme.onSurfaceVariant.withAlpha(120),
              ),
            ),
          );
        }

        if (_timer == null && landscapeImages.length > 1) {
          _startTimer(landscapeImages.length);
        }

        final safeIndex = _currentIndex % landscapeImages.length;
        final image = landscapeImages[safeIndex];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Image.asset(
            'assets/mil-images/${image.milId}.webp',
            key: ValueKey(image.milId),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surfaceContainerHighest.withAlpha(120),
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant.withAlpha(120),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        color: colorScheme.surfaceContainerHighest.withAlpha(120),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Container(
        color: colorScheme.surfaceContainerHighest.withAlpha(120),
        child: Center(
          child: Icon(
            Icons.error_outline,
            size: 20,
            color: colorScheme.onSurfaceVariant.withAlpha(120),
          ),
        ),
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
    final colorScheme = Theme.of(context).colorScheme;

    final tileBackgroundColor = isOddIndex
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow.withAlpha(150);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: tileBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(100),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(currentMddIDProvider.notifier).setMddID(taxonData.id);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SpeciesPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: double.infinity,
                    child: SpeciesTileImage(mddId: taxonData.id),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${taxonData.genus} ${taxonData.specificEpithet}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          if (taxonData.mainCommonName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              taxonData.mainCommonName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant.withAlpha(160),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

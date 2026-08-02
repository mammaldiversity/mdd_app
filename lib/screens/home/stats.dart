import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/statistics.dart';

class MddStatistics extends ConsumerWidget {
  const MddStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(statisticsProvider).when(
          data: (stats) {
            final recentlyExtinctCount = stats.extinctSpecies
                .firstWhere(
                  (e) => e.isExtinct == 1,
                  orElse: () =>
                      StatExtinctSpeciesResult(isExtinct: 1, count: 0),
                )
                .count;
            final domesticCount = stats.domesticSpecies
                .firstWhere(
                  (e) => e.isDomestic == 1,
                  orElse: () =>
                      StatDomesticSpeciesResult(isDomestic: 1, count: 0),
                )
                .count;

            final livingCount = stats.totalSpeciesCount - recentlyExtinctCount;

            return Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mammal Diversity Statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Orders',
                          count: stats.totalOrdersCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Families',
                          count: stats.totalFamiliesCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Genera',
                          count: stats.totalGeneraCount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SpeciesDetailedStatCard(
                    total: stats.totalSpeciesCount,
                    living: livingCount,
                    livingWild: stats.livingWildSpeciesCount,
                    recentlyExtinct: recentlyExtinctCount,
                    domestic: domesticCount,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Names & Synonyms',
                          count: stats.totalSynonymsCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          title: 'Images',
                          count: stats.totalImagesCount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const SimpleLoadingMessages(),
          error: (error, stack) => Text('Error: $error'),
        );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.title, required this.count});

  final String title;
  final int count;

  static String formatCount(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(
              formatCount(count),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SpeciesDetailedStatCard extends StatelessWidget {
  const SpeciesDetailedStatCard({
    super.key,
    required this.total,
    required this.living,
    required this.livingWild,
    required this.recentlyExtinct,
    required this.domestic,
  });

  final int total;
  final int living;
  final int livingWild;
  final int recentlyExtinct;
  final int domestic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Species',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              StatCard.formatCount(total),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 12,
              runSpacing: 12,
              children: [
                SpeciesSubStats(label: 'Living', value: living),
                SpeciesSubStats(label: 'Living Wild', value: livingWild),
                SpeciesSubStats(label: 'Domestic', value: domestic),
                SpeciesSubStats(
                  label: 'Recently Extinct',
                  value: recentlyExtinct,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SpeciesSubStats extends StatelessWidget {
  const SpeciesSubStats({super.key, required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(90),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            StatCard.formatCount(value),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

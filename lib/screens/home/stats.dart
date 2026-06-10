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
                .firstWhere((e) => e.isExtinct == 1,
                    orElse: () =>
                        StatExtinctSpeciesResult(isExtinct: 1, count: 0))
                .count;
            final domesticCount = stats.domesticSpecies
                .firstWhere((e) => e.isDomestic == 1,
                    orElse: () =>
                        StatDomesticSpeciesResult(isDomestic: 1, count: 0))
                .count;

            final livingCount = stats.totalSpeciesCount - recentlyExtinctCount;

            return Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mammal Diversity Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: StatCard(
                              title: 'Orders', count: stats.totalOrdersCount)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: StatCard(
                              title: 'Families',
                              count: stats.totalFamiliesCount)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: StatCard(
                              title: 'Genera', count: stats.totalGeneraCount)),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color:
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
    return Card(
      elevation: 0,
      color:
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Species',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              total.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 24,
              runSpacing: 16,
              children: [
                SpeciesSubStats(label: 'Living', value: living),
                SpeciesSubStats(label: 'Living Wild', value: livingWild),
                SpeciesSubStats(
                    label: 'Recently Extinct', value: recentlyExtinct),
                SpeciesSubStats(label: 'Domestic', value: domestic),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SpeciesSubStats extends StatelessWidget {
  const SpeciesSubStats({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

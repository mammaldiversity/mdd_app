import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/settings.dart';

class InfoCard extends ConsumerWidget {
  final String text;

  const InfoCard({super.key, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(showInfoTextProvider).when(
          data: (showInfo) {
            if (!showInfo) return const SizedBox.shrink();
            return Material(
              color: Theme.of(context).colorScheme.secondary.withAlpha(800),
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(showInfoTextProvider.notifier).toggle(false);
                      },
                      child: Icon(Icons.close,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}

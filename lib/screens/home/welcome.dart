import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/providers/settings.dart';

const String _welcomeText = 'The Mammal Diversity Database (MDD) '
    'is a comprehensive, constantly updated resource for '
    'the classification and nomenclature of living and recently extinct '
    '(i.e., since ~1500 CE) species and higher taxa of mammals.';

class Welcome extends ConsumerWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(showWelcomeTextProvider).when(
        data: (showWelcome) {
          if (showWelcome) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: const WelcomeText()),
                ));
          } else {
            return const SizedBox.shrink();
          }
        },
        loading: () => const SimpleLoadingOnly(),
        error: (Object error, StackTrace stackTrace) {
          return Text('Error: $error');
        });
  }
}

class WelcomeText extends ConsumerWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(16),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      ref.read(showWelcomeTextProvider.notifier).toggle(false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              _welcomeText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

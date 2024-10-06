import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/providers/settings.dart';

const String _welcomeText = 'The Mammal Diversity Database of '
    'the American Society of Mammalogists (ASM) '
    'is your home base for tracking the latest '
    'taxonomic changes to living and recently extinct '
    '(i.e., since ~1500 CE) species and higher taxa of mammals.';

class Welcome extends ConsumerWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(isFirstRunProvider).when(
        data: (isFirstRun) {
          if (isFirstRun) {
            return const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: WelcomeText());
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

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Welcome",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            _welcomeText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/settings.dart';

class DataLoadingMessages extends ConsumerWidget {
  const DataLoadingMessages({super.key, required this.isSimple});

  final bool isSimple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ref.watch(isFirstRunProvider).when(
            data: (isFirstRun) {
              if (isFirstRun) {
                return isSimple
                    ? const SimpleLoadingMessages()
                    : const FirstRunLoadingMessages();
              } else {
                return const SimpleLoadingMessages();
              }
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
          ),
    );
  }
}

class FirstRunLoadingMessages extends StatelessWidget {
  const FirstRunLoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            )),
        Text('Retrieving and parsing MDD data... ⏳'),
        Text(
          'These may take several minutes. '
          'We are making sure you can access the data offline'
          ' from anywhere in the world. 🌍',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SimpleLoadingMessages extends StatelessWidget {
  const SimpleLoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            )),
        Text('Retrieving MDD data... ⏳'),
      ],
    );
  }
}

class SimpleLoadingOnly extends StatelessWidget {
  const SimpleLoadingOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary.withAlpha(80),
        ),
      ),
    );
  }
}

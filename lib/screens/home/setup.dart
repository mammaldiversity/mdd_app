import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/loadings.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ListView(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(32),
                borderRadius: BorderRadius.circular(16),
              ),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset("assets/animations/species.gif"),
                  ),
                  const SizedBox(height: 16),
                  const SetupHeadline(),
                  const SizedBox(height: 16),
                  const OtherFeatures(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SimpleLoadingOnly(),
                const SizedBox(height: 16),
                Text(
                  '⏳ Setting up MDD...',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'It may take several minutes.\n'
                  'Keep this app open until setup is complete.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}

class SetupHeadline extends StatelessWidget {
  const SetupHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'MDD is aimed to promote rigorous study of mammal diversity worldwide.',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Libre Baskerville',
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class OtherFeatures extends StatelessWidget {
  const OtherFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(
            'App Features:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Offline access '
            '• Advanced search '
            '• Partial data export '
            '• MDD statistics '
            '• More...',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ]));
  }
}

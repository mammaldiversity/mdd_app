import 'package:flutter/material.dart';
import 'package:mdd/screens/shared/loadings.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to MDD'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/animations/species.gif"),
                const SizedBox(height: 16),
                const SimpleLoadingOnly(),
                Text(
                  'Setting up MDD... ⏳',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'This may take several minutes. '
                  'We are making sure you can access the data offline.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

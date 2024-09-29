import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/species.dart';

class SynonymData extends ConsumerWidget {
  const SynonymData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(synonymDataProvider).when(
          data: (synonymData) {
            return Text('Synonym: ${synonymData.speciesId}');
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';

class SpeciesCount extends ConsumerWidget {
  const SpeciesCount({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddGroupListResult> speciesList) {
            return Text('Species count: ${speciesList.length}');
          },
          loading: () => const SimpleLoadingMessages(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

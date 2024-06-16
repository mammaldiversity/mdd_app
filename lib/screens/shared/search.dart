import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/species.dart';

class SearchField extends ConsumerWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        leading: const Icon(Icons.search),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0), // Convert int to double
        hintText: 'Search for a species',
        onChanged: (String value) {
          if (value.isNotEmpty) {
            ref.read(speciesListProvider.notifier).search(value);
          } else {
            ref.invalidate(speciesListProvider);
          }
        },
      ),
    );
  }
}

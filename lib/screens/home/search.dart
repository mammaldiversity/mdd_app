import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';

class SearchField extends ConsumerWidget {
  const SearchField({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        focusNode: focusNode,
        leading: const Icon(Icons.search),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onSurface.withAlpha(32),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0), // Convert int to double
        hintText: 'Search database',
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

class SearchInfo extends ConsumerWidget {
  const SearchInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddGroupListResult> speciesList) {
            int recordLength = speciesList.length;
            return ref.watch(totalRecordsProvider).when(
                  data: (int totalRecords) {
                    return totalRecords == recordLength
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                speciesList.isEmpty
                                    ? 'No record found'
                                    : 'Found ${speciesList.length} of $totalRecords records',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          );
                  },
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  ),
                  error: (Object error, StackTrace? stackTrace) {
                    return Text('Error: $error');
                  },
                );
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

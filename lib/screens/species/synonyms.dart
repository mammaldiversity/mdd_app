import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/database/database.dart' as db;

class SynonymList extends ConsumerWidget {
  const SynonymList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(synonymDataProvider).when(
          data: (synonymData) {
            return synonymData.isNotEmpty
                ? SynonymContainer(data: synonymData)
                : const Text('No synonyms found');
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object error, StackTrace stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}

class SynonymContainer extends StatelessWidget {
  const SynonymContainer({super.key, required this.data});

  final List<db.SynonymData> data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(data[index].speciesId.toString()),
        );
      },
    );
  }
}

class SynonymPage extends StatelessWidget {
  const SynonymPage({super.key, required this.data});

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

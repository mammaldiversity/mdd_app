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
                : const Center(child: Text('No synonyms found.'));
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        const Divider(indent: 8, endIndent: 8),
        const SizedBox(height: 8),
        Text('Synonyms', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...data.map(
          (synonymData) => SynonymCard(data: synonymData),
        ),
      ]),
    );
  }
}

class SynonymCard extends StatelessWidget {
  const SynonymCard({super.key, required this.data});

  final db.SynonymData data;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Text(
        _createSynName(),
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _createSynName() {
    final String author = data.author ?? '';
    final String species = data.species ?? '';
    final String year = data.year ?? '';
    if (data.authorityParentheses == 1) {
      return '$species ($author, $year)';
    } else {
      return '$species $author $year';
    }
  }
}

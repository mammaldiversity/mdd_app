import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore.dart';
import 'package:mdd/screens/home/search.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';

class SearchDatabasePage extends StatefulWidget {
  const SearchDatabasePage({super.key});

  @override
  State<SearchDatabasePage> createState() => _SearchDatabasePageState();
}

class _SearchDatabasePageState extends State<SearchDatabasePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Database'),
        automaticallyImplyLeading: false,
        actions: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: SearchField(focusNode: _focusNode),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _focusNode.unfocus();
                  Navigator.pop(context);
                }),
          )
        ],
      ),
      body: const Center(
        child: SpeciesListView(),
      ),
    );
  }
}

class SpeciesListView extends ConsumerWidget {
  const SpeciesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(speciesListProvider).when(
      data: (List<MddGroupListResult> speciesList) {
        return ListView.builder(
          itemCount: speciesList.length,
          itemBuilder: (BuildContext context, int index) {
            return SpeciesGroups(
              taxonIDList: speciesList.map((e) => e.id).toList(),
            );
          },
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return Text('Error: $error');
      },
    );
  }
}

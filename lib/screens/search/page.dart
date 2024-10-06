import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/shared/search.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';

class SearchDatabasePage extends ConsumerStatefulWidget {
  const SearchDatabasePage({super.key, required this.controller});

  final TextEditingController controller;

  @override
  SearchDatabasePageState createState() => SearchDatabasePageState();
}

class SearchDatabasePageState extends ConsumerState<SearchDatabasePage> {
  final FocusNode _focusNode = FocusNode();
  SearchFilter _selectedOption = SearchFilter.all;

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
            child: CommonSearchField(
              focusNode: _focusNode,
              controller: widget.controller,
              onChanged: _searchDatabase,
              onClear: () {
                widget.controller.clear();
                ref.invalidate(searchDatabaseProvider);
                setState(() {});
              },
              onFiltering: () {
                _showFilteringOptions();
              },
            ),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: TextButton(
                child: const Text('Done'),
                onPressed: () {
                  _focusNode.unfocus();
                  widget.controller.clear();
                  Navigator.pop(context);
                }),
          )
        ],
      ),
      body: const Center(
        child: SpeciesListView(),
      ),
      bottomSheet: const SearchDatabaseInfo(),
    );
  }

  void _searchDatabase(String? query) {
    setState(() {
      if (query != null || query!.isNotEmpty) {
        ref
            .read(searchDatabaseProvider.notifier)
            .search(query, filterBy: _selectedOption);
      } else {
        ref.invalidate(searchDatabaseProvider);
      }
    });
  }

  void _showFilteringOptions() {
    SearchFilterView(
      selectedOption: _selectedOption,
      onSelected: (SearchFilter? option) {
        if (option != null) {
          _selectedOption = option;
        }
        if (widget.controller.text.isNotEmpty) {
          _searchDatabase(widget.controller.text);
        }
        Navigator.pop(context);
      },
    ).showFilteringOptions(context);
  }
}

class SpeciesListView extends ConsumerWidget {
  const SpeciesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(searchDatabaseProvider).when(
      data: (List<MainTaxonomyData> speciesList) {
        return ListView.builder(
          itemCount: speciesList.length,
          itemBuilder: (BuildContext context, int index) {
            return SpeciesTile(
              taxonData: speciesList[index],
              isOddIndex: index.isOdd,
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

class SearchDatabaseInfo extends ConsumerWidget {
  const SearchDatabaseInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(searchDatabaseProvider).when(
      data: (List<MainTaxonomyData> speciesList) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          child: SearchResultInfo(
            foundRecords: speciesList.map((e) => e.id).toList(),
          ),
        );
      },
      loading: () {
        return const CircularProgressIndicator();
      },
      error: (Object error, StackTrace? stackTrace) {
        return Text('Error: $error');
      },
    );
  }
}

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          Text(
            'No results found',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

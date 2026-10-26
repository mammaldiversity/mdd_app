import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/search/fields.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/shared/rule_filter_panel.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/rule_filter.dart';

class SearchDatabasePage extends ConsumerStatefulWidget {
  const SearchDatabasePage({super.key, required this.controller});

  final TextEditingController controller;

  @override
  SearchDatabasePageState createState() => SearchDatabasePageState();
}

class SearchDatabasePageState extends ConsumerState<SearchDatabasePage> {
  final FocusNode _focusNode = FocusNode();
  SearchFilter _selectedOption = SearchFilter.all;
  RuleFilter<SearchFilter> _rules = const RuleFilter();
  bool _showRules = false;

  static final List<RuleField<SearchFilter>> _ruleFields = [
    for (final field in SearchFilter.values)
      RuleField(
        key: field,
        label: switch (field.group) {
          FilterGroup.synonym => 'Synonym ${field.displayName}',
          FilterGroup.milData => 'Image ${field.displayName}',
          _ => field.displayName,
        },
      ),
  ];

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
                  _searchDatabase('');
                },
                onFiltering: () {
                  _showFilteringOptions();
                },
                activeRuleCount: _rules.activeRules.length,
                onRules: () => setState(() => _showRules = !_showRules),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: TextButton(
              child: const Text('Done'),
              onPressed: () {
                _focusNode.unfocus();
                widget.controller.clear();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InfoCard(
                text:
                    'Search for a species using the search bar above. '
                    'You can also filter search results, '
                    'add rules to filter by specific fields, '
                    'update your search settings, '
                    'and export your findings. '
                    'Please note that search results may not exactly match those on the website '
                    'due to differences in the underlying architecture. '
                    'The app provides more granular control over filtering your results.',
              ),
            ),
            if (_showRules)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: RuleFilterPanel<SearchFilter>(
                    fields: _ruleFields,
                    filter: _rules,
                    onChanged: (rules) {
                      setState(() => _rules = rules);
                      _searchDatabase(widget.controller.text);
                    },
                  ),
                ),
              ),
            const Expanded(child: SpeciesListView()),
          ],
        ),
      ),
      bottomSheet: const SearchDatabaseInfo(),
    );
  }

  void _searchDatabase(String query) {
    setState(() {
      if (query.isNotEmpty || _rules.isActive) {
        ref
            .read(searchDatabaseProvider.notifier)
            .search(query, filterBy: _selectedOption, rules: _rules);
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
        if (widget.controller.text.isNotEmpty || _rules.isActive) {
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
    return ref
        .watch(searchDatabaseProvider)
        .when(
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
            return const Center(child: SimpleLoadingOnly());
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
    return ref
        .watch(searchDatabaseProvider)
        .when(
          data: (List<MainTaxonomyData> speciesList) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: SearchResultInfo(
                foundRecords: speciesList.map((e) => e.id).toList(),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
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
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: color),
          Text('No results found', style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/search/fields.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/shared/rule_filter_panel.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/debouncer.dart';
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
  final Debouncer _searchDebouncer = Debouncer();

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
    _searchDebouncer.cancel();
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
                onChanged: (_) => _scheduleSearch(),
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
                _searchDebouncer.cancel();
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
                      _rules = rules;
                      _scheduleSearch();
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

  /// Searches once typing pauses, so fast typing doesn't redraw the
  /// results on every keystroke.
  void _scheduleSearch() {
    // Rebuild now for the clear button and the rules panel.
    setState(() {});
    _searchDebouncer(() {
      if (mounted) _searchDatabase(widget.controller.text);
    });
  }

  void _searchDatabase(String query) {
    _searchDebouncer.cancel();
    final search = ref.read(searchDatabaseProvider.notifier);
    if (query.isNotEmpty || _rules.isActive) {
      search.search(query, filterBy: _selectedOption, rules: _rules);
    } else {
      search.clear();
    }
    setState(() {});
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
          // Show the previous results while a new search runs.
          skipLoadingOnReload: true,
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
          skipLoadingOnReload: true,
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

import 'package:flutter/material.dart';
import 'package:mdd/services/database/mdd_query.dart';

class CommonSearchField extends StatefulWidget {
  const CommonSearchField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onFiltering,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFiltering;

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        focusNode: widget.focusNode,
        controller: widget.controller,
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
        trailing: [
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: widget.onClear,
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: widget.onFiltering,
          ),
        ],
        onChanged: widget.onChanged,
      ),
    );
  }
}

class SearchFilterOptions extends StatelessWidget {
  const SearchFilterOptions({
    super.key,
    required this.selectedOption,
    required this.onSelected,
  });

  final SearchFilter selectedOption;
  final ValueChanged<SearchFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('All'),
          onTap: () {
            onSelected(SearchFilter.all);
          },
          selected: selectedOption == SearchFilter.all,
        ),
        ListTile(
          title: const Text('Family'),
          onTap: () {
            onSelected(SearchFilter.family);
          },
          selected: selectedOption == SearchFilter.family,
        ),
        ListTile(
          title: const Text('Genus'),
          onTap: () {
            onSelected(SearchFilter.genus);
          },
          selected: selectedOption == SearchFilter.genus,
        ),
        ListTile(
          title: const Text('Species'),
          onTap: () {
            onSelected(SearchFilter.species);
          },
          selected: selectedOption == SearchFilter.species,
        ),
      ],
    );
  }
}

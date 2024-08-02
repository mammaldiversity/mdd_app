import 'package:flutter/material.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/system.dart';
import 'package:mdd/services/utils.dart';

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
  final void Function(SearchFilter?) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SearchFilter.values
              .map(
                (option) => RadioListTile<SearchFilter>(
                  title: Text(option.name.enumToSentenceCase()),
                  value: option,
                  groupValue: selectedOption,
                  onChanged: onSelected,
                ),
              )
              .toList(),
        ));
  }
}

class SearchFilterView {
  const SearchFilterView({
    required this.selectedOption,
    required this.onSelected,
  });

  final SearchFilter selectedOption;
  final void Function(SearchFilter?) onSelected;

  void showFilteringOptions(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    if (screenType == ScreenType.small) {
      showFilteringModalSheet(context);
    } else {
      showFilteringDialog(context);
    }
  }

  void showFilteringModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (context) => SearchFilterOptions(
        selectedOption: selectedOption,
        onSelected: onSelected,
      ),
    );
  }

  void showFilteringDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Filter'),
        content: SearchFilterOptions(
          selectedOption: selectedOption,
          onSelected: onSelected,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

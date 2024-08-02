import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/export.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/system.dart';
import 'package:mdd/services/utils.dart';
import 'package:path/path.dart' as path;

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

class SearchResultInfo extends ConsumerWidget {
  const SearchResultInfo({
    super.key,
    required this.foundRecords,
  });

  final List<int> foundRecords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int foundRecordCount = foundRecords.length;
    return ref.watch(totalRecordsProvider).when(
          data: (int totalRecords) {
            return totalRecords == foundRecordCount || foundRecordCount == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Found $foundRecordCount of $totalRecords records',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          VerticalDivider(
                            thickness: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(80),
                          ),
                          SearchExportButton(mddIDs: foundRecords),
                        ],
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
  }
}

class SearchExportButton extends ConsumerStatefulWidget {
  const SearchExportButton({super.key, required this.mddIDs});

  final List<int> mddIDs;

  @override
  SearchExportButtonState createState() => SearchExportButtonState();
}

class SearchExportButtonState extends ConsumerState<SearchExportButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.adaptive.share),
      tooltip: 'Share results',
      onPressed: () async {
        try {
          await _exportRecords();
        } catch (e) {
          if (mounted) {
            _showSnackBar(e.toString());
          }
        }
      },
    );
  }

  Future<void> _exportRecords() async {
    String? result = await FileExport(ref: ref, mddIDs: widget.mddIDs).write();
    if (result != null) {
      final platformType = getPlatformType();
      final outputPath =
          platformType == PlatformType.mobile ? path.basename(result) : result;
      _showSnackBar('Done! File saved as $outputPath');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(msg),
      ),
    );
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

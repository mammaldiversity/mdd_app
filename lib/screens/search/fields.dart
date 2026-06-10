import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/export.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/system.dart';

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
            color: Theme.of(context).colorScheme.onSurface,
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RadioGroup<SearchFilter>(
          groupValue: selectedOption,
          onChanged: onSelected,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterGroupWidget(
                title: 'General',
                group: FilterGroup.general,
                selectedOption: selectedOption,
                onSelected: onSelected,
              ),
              const Divider(),
              FilterGroupWidget(
                title: 'Taxonomy',
                group: FilterGroup.taxonomy,
                selectedOption: selectedOption,
                onSelected: onSelected,
              ),
              const Divider(),
              FilterGroupWidget(
                title: 'Synonyms',
                group: FilterGroup.synonym,
                selectedOption: selectedOption,
                onSelected: onSelected,
              ),
              const Divider(),
              FilterGroupWidget(
                title: 'Images Data',
                group: FilterGroup.milData,
                selectedOption: selectedOption,
                onSelected: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterGroupWidget extends StatelessWidget {
  const FilterGroupWidget({
    super.key,
    required this.title,
    required this.group,
    required this.selectedOption,
    required this.onSelected,
  });

  final String title;
  final FilterGroup group;
  final SearchFilter selectedOption;
  final void Function(SearchFilter?) onSelected;

  @override
  Widget build(BuildContext context) {
    final options = SearchFilter.values.where((e) => e.group == group).toList();
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...options.map(
          (option) => RadioListTile<SearchFilter>(
            title: Text(option.displayName),
            value: option,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
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
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SearchInfoBox(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.6),
                            child: Text(
                              'Found $foundRecordCount of $totalRecords records',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SearchInfoBox(
                            padding: 8,
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.6),
                            child: SearchExportButton(mddIDs: foundRecords),
                          ),
                        ],
                      ),
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

class SearchInfoBox extends StatelessWidget {
  const SearchInfoBox(
      {super.key, required this.child, this.color, this.padding = 16});

  final double padding;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: child));
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
      icon: Icon(
        Icons.adaptive.share,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      tooltip: 'Export',
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
    final ExportSettings? settings = await showDialog<ExportSettings>(
      context: context,
      builder: (context) => const ExportDialog(),
    );

    if (settings != null && mounted) {
      // Delay slightly to ensure the Flutter dialog is fully closed before opening the native file picker
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      String? result = await FileExport(
        ref: ref,
        mddIDs: widget.mddIDs,
        fileName: settings.fileName,
        format: settings.format,
      ).write(context);
      final platformType = getPlatformType();
      if (platformType == PlatformType.desktop && mounted && result != null) {
        _showSnackBar('Done! File saved as $result');
      }
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
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SearchFilterOptions(
            selectedOption: selectedOption,
            onSelected: onSelected,
          );
        },
      ),
    );
  }

  void showFilteringDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Filter'),
        content: SizedBox(
          width: double.maxFinite,
          child: SearchFilterOptions(
            selectedOption: selectedOption,
            onSelected: onSelected,
          ),
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

class ExportSettings {
  final String fileName;
  final ExportFormat format;

  ExportSettings({required this.fileName, required this.format});
}

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late TextEditingController _filenameController;
  ExportFormat _format = ExportFormat.csv;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController(text: kDefaultFileName);
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _filenameController,
            decoration: const InputDecoration(
              labelText: 'Filename',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<ExportFormat>(
            segments: const [
              ButtonSegment(value: ExportFormat.csv, label: Text('CSV')),
              ButtonSegment(value: ExportFormat.json, label: Text('JSON')),
            ],
            selected: {_format},
            onSelectionChanged: (Set<ExportFormat> newSelection) {
              setState(() {
                _format = newSelection.first;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_filenameController.text.trim().isEmpty) return;
            Navigator.of(context).pop(
              ExportSettings(
                fileName: _filenameController.text.trim(),
                format: _format,
              ),
            );
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}

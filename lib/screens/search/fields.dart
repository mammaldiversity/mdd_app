import 'package:material_ui/material_ui.dart';
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
    this.activeRuleCount = 0,
    this.onRules,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFiltering;

  /// Shown as a badge on the rules button.
  final int activeRuleCount;

  /// Toggles the rules panel. The button is hidden when null.
  final VoidCallback? onRules;

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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            tooltip: 'Search in field',
            onPressed: widget.onFiltering,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          if (widget.onRules != null)
            IconButton(
              tooltip: 'Filter rules',
              icon: Badge.count(
                count: widget.activeRuleCount,
                isLabelVisible: widget.activeRuleCount > 0,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: widget.onRules,
              color: widget.activeRuleCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
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
  const SearchResultInfo({super.key, required this.foundRecords});

  final List<int> foundRecords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final int foundRecordCount = foundRecords.length;

    return ref
        .watch(totalRecordsProvider)
        .when(
          data: (int totalRecords) {
            return totalRecords == foundRecordCount || foundRecordCount == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SearchInfoBox(
                            color: colorScheme.secondaryContainer,
                            borderColor: colorScheme.outlineVariant.withAlpha(
                              160,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Found $foundRecordCount of $totalRecords records',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SearchInfoBox(
                            padding: 4,
                            color: colorScheme.primaryContainer,
                            borderColor: colorScheme.outlineVariant.withAlpha(
                              160,
                            ),
                            child: SpeciesExportButton(
                              mddIDs: foundRecords,
                              tooltip: 'Export search results',
                              iconColor: colorScheme.onPrimaryContainer,
                            ),
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
  const SearchInfoBox({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding = 16,
  });

  final double padding;
  final Color? color;
  final Color? borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: color ?? colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? colorScheme.outlineVariant.withAlpha(140),
          width: 1,
        ),
      ),
      child: Center(child: child),
    );
  }
}

/// Exports the species [mddIDs], and optionally their synonyms, after
/// asking for a file name and format.
class SpeciesExportButton extends ConsumerStatefulWidget {
  const SpeciesExportButton({
    super.key,
    required this.mddIDs,
    required this.tooltip,
    this.fileName = kDefaultFileName,
    this.iconColor,
    this.label,
  });

  final List<int> mddIDs;
  final String tooltip;

  /// Shows a labelled button instead of an icon alone.
  final String? label;

  /// The file name the export dialog starts with.
  final String fileName;
  final Color? iconColor;

  @override
  SpeciesExportButtonState createState() => SpeciesExportButtonState();
}

class SpeciesExportButtonState extends ConsumerState<SpeciesExportButton> {
  @override
  Widget build(BuildContext context) {
    final Widget icon = Icon(
      Icons.adaptive.share,
      size: 20,
      color: widget.iconColor,
    );
    final String? label = widget.label;
    if (label != null) {
      return Tooltip(
        message: widget.tooltip,
        child: OutlinedButton.icon(
          onPressed: _onPressed,
          icon: icon,
          label: Text(label),
        ),
      );
    }
    return IconButton(
      icon: icon,
      tooltip: widget.tooltip,
      onPressed: _onPressed,
    );
  }

  Future<void> _onPressed() async {
    try {
      await _exportRecords();
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    }
  }

  Future<void> _exportRecords() async {
    final ExportSettings? settings = await showDialog<ExportSettings>(
      context: context,
      builder: (context) => ExportDialog(initialFileName: widget.fileName),
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
        includeSynonyms: settings.includeSynonyms,
      ).write(context);
      final platformType = getPlatformType();
      if (platformType == PlatformType.desktop && mounted && result != null) {
        _showSnackBar(
          settings.includeSynonyms && settings.format != ExportFormat.xlsx
              ? 'Done! Files saved as $result'
              : 'Done! File saved as $result',
        );
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 10), content: Text(msg)),
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

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key, this.initialFileName = kDefaultFileName});

  final String initialFileName;

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late TextEditingController _filenameController;
  ExportFormat _format = ExportFormat.csv;
  bool _includeSynonyms = false;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController(text: widget.initialFileName);
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
            // Keeps the synonyms file name below in sync.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SegmentedButton<ExportFormat>(
            segments: const [
              ButtonSegment(value: ExportFormat.csv, label: Text('CSV')),
              ButtonSegment(value: ExportFormat.tsv, label: Text('TSV')),
              ButtonSegment(value: ExportFormat.json, label: Text('JSON')),
              ButtonSegment(value: ExportFormat.xlsx, label: Text('Excel')),
            ],
            selected: {_format},
            onSelectionChanged: (Set<ExportFormat> newSelection) {
              setState(() {
                _format = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _includeSynonyms,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Include synonyms'),
            subtitle: Text(
              _format == ExportFormat.xlsx
                  ? 'Added as a Synonyms sheet'
                  : 'Saved as ${synonymFileName(_filenameController.text.trim(), _format)}',
            ),
            onChanged: (value) =>
                setState(() => _includeSynonyms = value ?? false),
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
                includeSynonyms: _includeSynonyms,
              ),
            );
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}

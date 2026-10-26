import 'package:material_ui/material_ui.dart';
import 'package:mdd/screens/shared/rule_filter_panel.dart';
import 'package:mdd/services/debouncer.dart';
import 'package:mdd/services/rule_filter.dart';

/// Whether a table row passes the simple search and the rules.
///
/// [searchColumn] limits the simple search to one column; null searches
/// [searchText], which covers every column.
bool tableRowMatches({
  required List<dynamic> values,
  required String searchText,
  required String query,
  required int? searchColumn,
  required RuleFilter<int> rules,
}) {
  if (query.isNotEmpty) {
    final text = searchColumn == null || searchColumn >= values.length
        ? searchText
        : values[searchColumn].toString();
    if (!text.toLowerCase().contains(query.toLowerCase())) return false;
  }
  return rules.matches(
    (rule) =>
        rule.field < values.length &&
        matchesCell(values[rule.field], rule.operator, rule.value),
  );
}

/// Simple search with a column picker, plus a rules panel for statistics
/// tables. Rule fields are keyed by column index.
///
/// Typing in the search box or the rules reaches [onQueryChanged] and
/// [onRulesChanged] after a short pause, so the table doesn't redraw on
/// every keystroke.
class TableFilterBar extends StatefulWidget {
  const TableFilterBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.columns,
    required this.searchColumn,
    required this.rules,
    required this.onQueryChanged,
    required this.onSearchColumnChanged,
    required this.onRulesChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final List<RuleField<int>> columns;
  final int? searchColumn;
  final RuleFilter<int> rules;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int?> onSearchColumnChanged;
  final ValueChanged<RuleFilter<int>> onRulesChanged;

  @override
  State<TableFilterBar> createState() => _TableFilterBarState();
}

class _TableFilterBarState extends State<TableFilterBar> {
  bool _showRules = false;
  final Debouncer _queryDebouncer = Debouncer();
  final Debouncer _rulesDebouncer = Debouncer();

  /// Shown in the panel right away; the parent gets it after the pause.
  late RuleFilter<int> _rules = widget.rules;

  @override
  void dispose() {
    _queryDebouncer.cancel();
    _rulesDebouncer.cancel();
    super.dispose();
  }

  void _onRulesChanged(RuleFilter<int> rules) {
    setState(() => _rules = rules);
    _rulesDebouncer(() => widget.onRulesChanged(rules));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchField = TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withAlpha(180),
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  _queryDebouncer.cancel();
                  widget.onQueryChanged('');
                },
              ),
            _ColumnPicker(
              columns: widget.columns,
              selected: widget.searchColumn,
              onSelected: widget.onSearchColumnChanged,
            ),
            const SizedBox(width: 6),
          ],
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
      onChanged: (value) {
        // Rebuild now so the clear button tracks the text.
        setState(() {});
        _queryDebouncer(() => widget.onQueryChanged(value.trim()));
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 8),
            RulesButton(
              activeCount: _rules.activeRules.length,
              isExpanded: _showRules,
              compact: MediaQuery.sizeOf(context).width < 600,
              onPressed: () => setState(() => _showRules = !_showRules),
            ),
          ],
        ),
        if (_showRules) ...[
          const SizedBox(height: 8),
          RuleFilterPanel<int>(
            fields: widget.columns,
            filter: _rules,
            onChanged: _onRulesChanged,
          ),
        ],
      ],
    );
  }
}

class _ColumnPicker extends StatelessWidget {
  const _ColumnPicker({
    required this.columns,
    required this.selected,
    required this.onSelected,
  });

  final List<RuleField<int>> columns;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = selected == null
        ? 'All columns'
        : columns.firstWhere((c) => c.key == selected).label;
    // -1 stands in for "all columns"; PopupMenuButton ignores null values.
    return PopupMenuButton<int>(
      tooltip: 'Search in column',
      initialValue: selected ?? -1,
      onSelected: (value) => onSelected(value < 0 ? null : value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: -1, child: Text('All columns')),
        for (final column in columns)
          PopupMenuItem(value: column.key, child: Text(column.label)),
      ],
      child: Container(
        constraints: const BoxConstraints(maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}

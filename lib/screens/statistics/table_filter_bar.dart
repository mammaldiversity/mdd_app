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
    final compact = MediaQuery.sizeOf(context).width < ruleSheetMaxWidth;
    final searchColumn = widget.searchColumn;
    final searchField = TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: searchColumn == null
            ? widget.hintText
            : 'Search ${_columnLabel(widget.columns, searchColumn)}…',
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withAlpha(180),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6, right: 4),
          child: _ColumnPicker(
            columns: widget.columns,
            selected: searchColumn,
            compact: compact,
            onSelected: widget.onSearchColumnChanged,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minHeight: 40),
        suffixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  _queryDebouncer.cancel();
                  setState(() {});
                  widget.onQueryChanged('');
                },
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
          horizontal: 12,
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
              isExpanded: _showRules && !compact,
              compact: compact,
              onPressed: compact
                  ? () => showRuleFilterSheet<int>(
                      context: context,
                      fields: widget.columns,
                      filter: _rules,
                      onChanged: _onRulesChanged,
                    )
                  : () => setState(() => _showRules = !_showRules),
            ),
          ],
        ),
        // Small screens edit rules in a bottom sheet instead.
        if (_showRules && !compact) ...[
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

String _columnLabel(List<RuleField<int>> columns, int key) =>
    columns.firstWhere((c) => c.key == key).label;

/// Picks the column the search box looks in, from the start of the search
/// field: the search icon and the column name on wide screens, the icon
/// alone on narrow ones. A picked column tints the button.
class _ColumnPicker extends StatelessWidget {
  const _ColumnPicker({
    required this.columns,
    required this.selected,
    required this.compact,
    required this.onSelected,
  });

  final List<RuleField<int>> columns;
  final int? selected;
  final bool compact;
  final ValueChanged<int?> onSelected;

  static const String _allColumns = 'All columns';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = this.selected;
    final label = selected == null
        ? _allColumns
        : _columnLabel(columns, selected);
    final picked = selected != null;
    final foreground = picked
        ? colorScheme.onSecondaryContainer
        : colorScheme.primary;
    final icon = Icon(Icons.manage_search, size: 20, color: foreground);

    // -1 stands in for "all columns"; PopupMenuButton ignores null values.
    return PopupMenuButton<int>(
      tooltip: 'Search in column: $label',
      initialValue: selected ?? -1,
      onSelected: (value) => onSelected(value < 0 ? null : value),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: -1,
          checked: selected == null,
          child: const Text(_allColumns),
        ),
        const PopupMenuDivider(),
        for (final column in columns)
          CheckedPopupMenuItem(
            value: column.key,
            checked: column.key == selected,
            child: Text(column.label),
          ),
      ],
      child: Container(
        height: 36,
        constraints: BoxConstraints(minWidth: 36, maxWidth: compact ? 36 : 180),
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 10),
        decoration: BoxDecoration(
          color: picked
              ? colorScheme.secondaryContainer
              : compact
              ? Colors.transparent
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: compact
            ? Center(child: icon)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: foreground),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 18, color: foreground),
                ],
              ),
      ),
    );
  }
}

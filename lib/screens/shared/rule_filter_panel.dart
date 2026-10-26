import 'package:material_ui/material_ui.dart';
import 'package:mdd/services/rule_filter.dart';

/// A column or field that rules can filter on.
class RuleField<T> {
  const RuleField({
    required this.key,
    required this.label,
    this.numeric = false,
  });

  final T key;
  final String label;
  final bool numeric;
}

/// Toggles the rules panel and shows how many rules are active.
class RulesButton extends StatelessWidget {
  const RulesButton({
    super.key,
    required this.activeCount,
    required this.isExpanded,
    required this.onPressed,
    this.compact = false,
  });

  final int activeCount;
  final bool isExpanded;
  final VoidCallback onPressed;

  /// Icon only, with the count as a badge, for narrow screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlighted = activeCount > 0 || isExpanded;
    final foregroundColor = highlighted
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final side = BorderSide(
      color: highlighted ? colorScheme.primary : colorScheme.outline,
    );
    if (compact) {
      return IconButton.outlined(
        tooltip: 'Filter rules',
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: foregroundColor,
          side: side,
        ),
        icon: Badge.count(
          count: activeCount,
          isLabelVisible: activeCount > 0,
          child: const Icon(Icons.filter_list),
        ),
        onPressed: onPressed,
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        foregroundColor: foregroundColor,
        side: side,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: const Icon(Icons.filter_list),
      label: Text(activeCount > 0 ? 'Rules ($activeCount)' : 'Rules'),
      onPressed: onPressed,
    );
  }
}

/// Edits a list of column/condition/value rules, matched all or any.
class RuleFilterPanel<T> extends StatelessWidget {
  const RuleFilterPanel({
    super.key,
    required this.fields,
    required this.filter,
    required this.onChanged,
  });

  final List<RuleField<T>> fields;
  final RuleFilter<T> filter;
  final ValueChanged<RuleFilter<T>> onChanged;

  RuleField<T> _fieldFor(T key) =>
      fields.firstWhere((f) => f.key == key, orElse: () => fields.first);

  void _addRule() {
    final field = fields.first;
    onChanged(
      filter.copyWith(
        rules: [
          ...filter.rules,
          FilterRule(
            field: field.key,
            operator: RuleOperator.forField(numeric: field.numeric).first,
          ),
        ],
      ),
    );
  }

  void _updateRule(FilterRule<T> rule) {
    onChanged(
      filter.copyWith(
        rules: [for (final r in filter.rules) r.id == rule.id ? rule : r],
      ),
    );
  }

  void _removeRule(FilterRule<T> rule) {
    onChanged(
      filter.copyWith(
        rules: filter.rules.where((r) => r.id != rule.id).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text('Match', style: textTheme.bodyMedium),
              _OutlinedDropdown<RuleMatch>(
                value: filter.match,
                items: {for (final m in RuleMatch.values) m: m.label},
                onChanged: (match) => onChanged(filter.copyWith(match: match)),
              ),
              Text('of the following rules', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          if (filter.rules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No rules yet. Add one to filter by a column.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final rule in filter.rules)
            _RuleRow<T>(
              key: ValueKey(rule.id),
              rule: rule,
              fields: fields,
              field: _fieldFor(rule.field),
              onChanged: _updateRule,
              onRemove: () => _removeRule(rule),
            ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add rule'),
                onPressed: _addRule,
              ),
              if (filter.rules.isNotEmpty)
                TextButton(
                  onPressed: () => onChanged(filter.copyWith(rules: const [])),
                  child: const Text('Clear all'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleRow<T> extends StatefulWidget {
  const _RuleRow({
    super.key,
    required this.rule,
    required this.fields,
    required this.field,
    required this.onChanged,
    required this.onRemove,
  });

  final FilterRule<T> rule;
  final List<RuleField<T>> fields;
  final RuleField<T> field;
  final ValueChanged<FilterRule<T>> onChanged;
  final VoidCallback onRemove;

  @override
  State<_RuleRow<T>> createState() => _RuleRowState<T>();
}

class _RuleRowState<T> extends State<_RuleRow<T>> {
  late final TextEditingController _valueController = TextEditingController(
    text: widget.rule.value,
  );

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _onFieldChanged(T key) {
    final field = widget.fields.firstWhere((f) => f.key == key);
    final operators = RuleOperator.forField(numeric: field.numeric);
    // Keep the condition when the new field supports it.
    final operator = operators.contains(widget.rule.operator)
        ? widget.rule.operator
        : operators.first;
    widget.onChanged(widget.rule.copyWith(field: key, operator: operator));
  }

  @override
  Widget build(BuildContext context) {
    final numeric = widget.field.numeric;
    final fieldDropdown = _OutlinedDropdown<T>(
      value: widget.field.key,
      items: {for (final f in widget.fields) f.key: f.label},
      onChanged: _onFieldChanged,
      expand: true,
    );
    final operatorDropdown = _OutlinedDropdown<RuleOperator>(
      value: widget.rule.operator,
      items: {
        for (final op in RuleOperator.forField(numeric: numeric))
          op: op.label(numeric: numeric),
      },
      onChanged: (op) => widget.onChanged(widget.rule.copyWith(operator: op)),
      expand: true,
    );
    final valueField = TextField(
      controller: _valueController,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        hintText: numeric ? 'Number' : 'Value',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onChanged: (value) =>
          widget.onChanged(widget.rule.copyWith(value: value)),
    );
    final removeButton = IconButton(
      tooltip: 'Remove rule',
      icon: const Icon(Icons.close),
      onPressed: widget.onRemove,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Phones stack the value under the column and condition.
          if (constraints.maxWidth < 520) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: fieldDropdown),
                    const SizedBox(width: 8),
                    Expanded(child: operatorDropdown),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: valueField),
                    removeButton,
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: fieldDropdown),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: operatorDropdown),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: valueField),
              removeButton,
            ],
          );
        },
      ),
    );
  }
}

class _OutlinedDropdown<V> extends StatelessWidget {
  const _OutlinedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.expand = false,
  });

  final V value;
  final Map<V, String> items;
  final ValueChanged<V> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<V>(
          value: value,
          isDense: true,
          isExpanded: expand,
          padding: const EdgeInsets.symmetric(vertical: 10),
          borderRadius: BorderRadius.circular(12),
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

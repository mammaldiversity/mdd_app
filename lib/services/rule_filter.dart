/// Rule-based filtering shared by the statistics tables and database search.
library;

enum RuleOperator {
  contains,
  doesNotContain,
  equals,
  notEquals,
  startsWith,
  endsWith,
  greaterThan,
  atLeast,
  lessThan,
  atMost;

  static const List<RuleOperator> textOperators = [
    contains,
    doesNotContain,
    equals,
    notEquals,
    startsWith,
    endsWith,
  ];

  static const List<RuleOperator> numberOperators = [
    equals,
    notEquals,
    greaterThan,
    atLeast,
    lessThan,
    atMost,
  ];

  static List<RuleOperator> forField({required bool numeric}) =>
      numeric ? numberOperators : textOperators;

  /// True when a row matches by having no value that matches the positive
  /// form, e.g. "does not contain".
  bool get isNegated => this == doesNotContain || this == notEquals;

  String label({required bool numeric}) {
    switch (this) {
      case contains:
        return 'contains';
      case doesNotContain:
        return 'does not contain';
      case equals:
        return numeric ? '=' : 'equals';
      case notEquals:
        return numeric ? '≠' : 'does not equal';
      case startsWith:
        return 'starts with';
      case endsWith:
        return 'ends with';
      case greaterThan:
        return '>';
      case atLeast:
        return '≥';
      case lessThan:
        return '<';
      case atMost:
        return '≤';
    }
  }
}

enum RuleMatch {
  all,
  any;

  String get label => this == all ? 'all' : 'any';
}

class FilterRule<T> {
  FilterRule({required this.field, required this.operator, this.value = ''})
    : id = _nextId++;

  FilterRule._withId(this.id, this.field, this.operator, this.value);

  static int _nextId = 0;

  /// Stable identity for widget keys, kept across [copyWith].
  final int id;
  final T field;
  final RuleOperator operator;
  final String value;

  /// Rules without a value are still being edited and are ignored.
  bool get isComplete => value.trim().isNotEmpty;

  FilterRule<T> copyWith({T? field, RuleOperator? operator, String? value}) =>
      FilterRule._withId(
        id,
        field ?? this.field,
        operator ?? this.operator,
        value ?? this.value,
      );
}

class RuleFilter<T> {
  const RuleFilter({this.rules = const [], this.match = RuleMatch.all});

  final List<FilterRule<T>> rules;
  final RuleMatch match;

  List<FilterRule<T>> get activeRules =>
      rules.where((rule) => rule.isComplete).toList();

  bool get isActive => rules.any((rule) => rule.isComplete);

  /// Combines [test] over the active rules. Always true when no rule is
  /// active.
  bool matches(bool Function(FilterRule<T> rule) test) {
    final active = activeRules;
    if (active.isEmpty) return true;
    return match == RuleMatch.all ? active.every(test) : active.any(test);
  }

  RuleFilter<T> copyWith({List<FilterRule<T>>? rules, RuleMatch? match}) =>
      RuleFilter(rules: rules ?? this.rules, match: match ?? this.match);
}

/// Matches a table cell. Numbers and percentage strings such as "12.5%" are
/// compared numerically when [value] is a number; everything else as
/// case-insensitive text.
bool matchesCell(Object? cell, RuleOperator operator, String value) {
  final cellNumber = _asNumber(cell);
  final ruleNumber = _asNumber(value);
  if (cellNumber != null && ruleNumber != null) {
    return matchesNumber(cellNumber, operator, ruleNumber);
  }
  return matchesText(cell?.toString() ?? '', operator, value);
}

bool matchesText(String cell, RuleOperator operator, String value) {
  final text = cell.toLowerCase();
  final query = value.trim().toLowerCase();
  switch (operator) {
    case RuleOperator.contains:
      return text.contains(query);
    case RuleOperator.doesNotContain:
      return !text.contains(query);
    case RuleOperator.equals:
      return text == query;
    case RuleOperator.notEquals:
      return text != query;
    case RuleOperator.startsWith:
      return text.startsWith(query);
    case RuleOperator.endsWith:
      return text.endsWith(query);
    case RuleOperator.greaterThan:
      return text.compareTo(query) > 0;
    case RuleOperator.atLeast:
      return text.compareTo(query) >= 0;
    case RuleOperator.lessThan:
      return text.compareTo(query) < 0;
    case RuleOperator.atMost:
      return text.compareTo(query) <= 0;
  }
}

bool matchesNumber(num cell, RuleOperator operator, num value) {
  switch (operator) {
    case RuleOperator.equals:
      return cell == value;
    case RuleOperator.notEquals:
      return cell != value;
    case RuleOperator.greaterThan:
      return cell > value;
    case RuleOperator.atLeast:
      return cell >= value;
    case RuleOperator.lessThan:
      return cell < value;
    case RuleOperator.atMost:
      return cell <= value;
    case RuleOperator.contains:
    case RuleOperator.doesNotContain:
    case RuleOperator.startsWith:
    case RuleOperator.endsWith:
      return matchesText(cell.toString(), operator, value.toString());
  }
}

/// SQL `LIKE` pattern for the positive form of a text [operator].
String likePattern(RuleOperator operator, String value) {
  final query = value.trim();
  switch (operator) {
    case RuleOperator.equals:
    case RuleOperator.notEquals:
      return query;
    case RuleOperator.startsWith:
      return '$query%';
    case RuleOperator.endsWith:
      return '%$query';
    default:
      return '%$query%';
  }
}

num? _asNumber(Object? value) {
  if (value is num) return value;
  if (value is! String) return null;
  final text = value.trim().replaceAll(',', '');
  return num.tryParse(
    text.endsWith('%') ? text.substring(0, text.length - 1).trim() : text,
  );
}

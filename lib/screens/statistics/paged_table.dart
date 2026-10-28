import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart' show RenderTable;
import 'package:flutter/services.dart';

/// Rows per page a paged table starts with.
const int defaultRowsPerPage = 25;

const List<int> _availableRowsPerPage = [10, 25, 50, 100];

/// A page body with [leading] content above a paged table whose card fills
/// the rest of the screen. Only the table's rows scroll; the content above,
/// the table's column headers and its page controls, at the bottom of the
/// card, stay put.
///
/// Changing page returns the rows to the top and focuses the table, so the
/// left and right arrow keys keep paging from there.
class PagedTableView extends StatefulWidget {
  const PagedTableView({
    super.key,
    this.leading = const [],
    required this.title,
    this.actions = const [],
    required this.columns,
    required this.source,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.showCheckboxColumn = false,
  });

  /// Content above the table, such as an info card and filters.
  final List<Widget> leading;

  /// The table's heading, e.g. "Records (120)".
  final String title;

  /// Buttons beside the heading, e.g. export.
  final List<Widget> actions;

  final List<DataColumn> columns;
  final DataTableSource source;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool showCheckboxColumn;

  @override
  State<PagedTableView> createState() => _PagedTableViewState();
}

class _PagedTableViewState extends State<PagedTableView> {
  final ScrollController _rowsScroll = ScrollController();
  final FocusNode _tableFocus = FocusNode(debugLabel: 'paged table');
  int _rowsPerPage = defaultRowsPerPage;
  int _firstRow = 0;

  @override
  void didUpdateWidget(PagedTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new filter or sort reorders the rows, so the current page no
    // longer means anything: start again from the first.
    if (widget.source.rowCount != oldWidget.source.rowCount ||
        widget.sortColumnIndex != oldWidget.sortColumnIndex ||
        widget.sortAscending != oldWidget.sortAscending) {
      _firstRow = 0;
    }
  }

  @override
  void dispose() {
    _rowsScroll.dispose();
    _tableFocus.dispose();
    super.dispose();
  }

  int get _rowCount => widget.source.rowCount;

  int get _lastPageFirstRow {
    if (_rowCount == 0) return 0;
    return ((_rowCount - 1) ~/ _rowsPerPage) * _rowsPerPage;
  }

  void _goTo(int firstRow) {
    final target = firstRow.clamp(0, _lastPageFirstRow);
    if (target == _firstRow) return;
    setState(() => _firstRow = target);
    _revealTable();
  }

  void _setRowsPerPage(int value) {
    setState(() {
      // Keep the first visible row on screen.
      _firstRow = (_firstRow ~/ value) * value;
      _rowsPerPage = value;
    });
    _revealTable();
  }

  void _revealTable() {
    if (_rowsScroll.hasClients) _rowsScroll.jumpTo(0);
    _tableFocus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.pageDown) {
      _goTo(_firstRow + _rowsPerPage);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.pageUp) {
      _goTo(_firstRow - _rowsPerPage);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstRow = _firstRow.clamp(0, _lastPageFirstRow);
    final endRow = (firstRow + _rowsPerPage).clamp(0, _rowCount);
    final rows = [
      for (var i = firstRow; i < endRow; i++) ?widget.source.getRow(i),
    ];

    final table = Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(130),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Focus(
        focusNode: _tableFocus,
        onKeyEvent: _onKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TableHeader(title: widget.title, actions: widget.actions),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: _StickyHeaderTable(
                columns: widget.columns,
                rows: rows,
                sortColumnIndex: widget.sortColumnIndex,
                sortAscending: widget.sortAscending,
                showCheckboxColumn: widget.showCheckboxColumn,
                rowsScroll: _rowsScroll,
              ),
            ),
            // Part of the card, below the scrolling rows, so the card's
            // rounded corners frame it and it never scrolls away.
            _PaginationBar(
              firstRow: firstRow,
              endRow: endRow,
              rowCount: _rowCount,
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: _setRowsPerPage,
              onFirst: () => _goTo(0),
              onPrevious: () => _goTo(firstRow - _rowsPerPage),
              onNext: () => _goTo(firstRow + _rowsPerPage),
              onLast: () => _goTo(_lastPageFirstRow),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Too short to fit the content above and a useful table (a phone
        // held sideways): let the page scroll as a whole, with the table
        // one screen tall so, once scrolled to, it shows whole.
        if (constraints.maxHeight < _minSplitHeight) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.leading,
                SizedBox(
                  height: (constraints.maxHeight - 32).clamp(
                    _minCompactTableHeight,
                    double.infinity,
                  ),
                  child: table,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...widget.leading,
              Expanded(child: table),
            ],
          ),
        );
      },
    );
  }
}

/// Below this height the page scrolls as a whole instead of only the rows.
const double _minSplitHeight = 520;
const double _minCompactTableHeight = 280;
const double _headingRowHeight = 56;

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.title, required this.actions});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// The page's rows under a column header that stays in place while they
/// scroll. Wider tables scroll sideways, header and rows together.
///
/// The header and the rows are separate tables, so their columns must be
/// given the same widths. An offstage copy of the whole table measures
/// them; being offstage, it stays out of hit tests, semantics and finders.
class _StickyHeaderTable extends StatefulWidget {
  const _StickyHeaderTable({
    required this.columns,
    required this.rows,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showCheckboxColumn,
    required this.rowsScroll,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool showCheckboxColumn;
  final ScrollController rowsScroll;

  @override
  State<_StickyHeaderTable> createState() => _StickyHeaderTableState();
}

class _StickyHeaderTableState extends State<_StickyHeaderTable> {
  final GlobalKey _measureKey = GlobalKey();
  final ScrollController _sideScroll = ScrollController();

  /// Column widths read from the offstage table, including any checkbox
  /// column.
  List<double>? _widths;

  @override
  void dispose() {
    _sideScroll.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    RenderTable? table;
    void find(RenderObject node) {
      if (table != null) return;
      if (node is RenderTable) {
        table = node;
      } else {
        node.visitChildren(find);
      }
    }

    final root = _measureKey.currentContext?.findRenderObject();
    if (root == null) return;
    find(root);
    final measured = table;
    if (measured == null || !measured.hasSize) return;
    final widths = [
      for (var x = 0; x < measured.columns; x++)
        measured.column(x).first.size.width,
    ];
    if (!listEquals(widths, _widths)) setState(() => _widths = widths);
  }

  /// [column] at a fixed width, optionally with its label swapped out.
  DataColumn _fixed(DataColumn column, double? width, {Widget? label}) {
    return DataColumn(
      label: label ?? column.label,
      // Never narrower than its own content: after a sort restyles a
      // header label, the widths lag the new label by a frame.
      columnWidth: width == null
          ? null
          : MaxColumnWidth(
              FixedColumnWidth(width),
              const IntrinsicColumnWidth(),
            ),
      tooltip: label == null ? column.tooltip : null,
      numeric: column.numeric,
      onSort: label == null ? column.onSort : null,
      mouseCursor: column.mouseCursor,
      headingRowAlignment: column.headingRowAlignment,
    );
  }

  DataTable _table({
    Key? key,
    required List<DataColumn> columns,
    required List<DataRow> rows,
    double headingRowHeight = _headingRowHeight,
  }) {
    return DataTable(
      key: key,
      columns: columns,
      rows: rows,
      sortColumnIndex: widget.sortColumnIndex,
      sortAscending: widget.sortAscending,
      showCheckboxColumn: widget.showCheckboxColumn,
      headingRowHeight: headingRowHeight,
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final colorScheme = Theme.of(context).colorScheme;
    final widths = _widths;
    // A checkbox column, when shown, comes first and isn't in [columns].
    final offset = widths == null ? 0 : widths.length - widget.columns.length;
    double? widthOf(int index) =>
        widths == null || offset < 0 ? null : widths[index + offset];

    return LayoutBuilder(
      builder: (context, constraints) {
        final measurer = Offstage(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: _table(
                key: _measureKey,
                columns: widget.columns,
                rows: widget.rows,
              ),
            ),
          ),
        );

        // Hold the visible table back until its column widths are known,
        // so the header never shows misaligned for a frame.
        if (widths == null) return measurer;

        return Stack(
          children: [
            measurer,
            Scrollbar(
              controller: _sideScroll,
              child: SingleChildScrollView(
                controller: _sideScroll,
                scrollDirection: Axis.horizontal,
                // Unbounded width lets either table run wider than the
                // measured widths for the frame they lag new content,
                // instead of squeezing its cells.
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _table(
                        columns: [
                          for (final (i, column) in widget.columns.indexed)
                            _fixed(column, widthOf(i)),
                        ],
                        rows: const [],
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: widget.rowsScroll,
                          child: SingleChildScrollView(
                            controller: widget.rowsScroll,
                            // The header above stands in for this table's
                            // own heading row, which is collapsed.
                            child: _table(
                              columns: [
                                for (final (i, column)
                                    in widget.columns.indexed)
                                  _fixed(
                                    column,
                                    widthOf(i),
                                    label: const SizedBox.shrink(),
                                  ),
                              ],
                              rows: widget.rows,
                              headingRowHeight: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.rows.isEmpty)
              Positioned.fill(
                top: _headingRowHeight,
                child: Center(
                  child: Text(
                    'No matching records',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.firstRow,
    required this.endRow,
    required this.rowCount,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
  });

  final int firstRow;
  final int endRow;
  final int rowCount;
  final int rowsPerPage;
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;

  static String _format(int value) => value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPrevious = firstRow > 0;
    final hasNext = endRow < rowCount;
    final range = rowCount == 0
        ? '0 of 0'
        : '${_format(firstRow + 1)}–${_format(endRow)} of ${_format(rowCount)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 480;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                if (!compact) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Rows per page',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: rowsPerPage,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  style: textTheme.bodyMedium,
                  items: [
                    for (final value in _availableRowsPerPage)
                      DropdownMenuItem(value: value, child: Text('$value')),
                  ],
                  onChanged: (value) {
                    if (value != null) onRowsPerPageChanged(value);
                  },
                ),
                const Spacer(),
                Text(range, style: textTheme.bodyMedium),
                const SizedBox(width: 8),
                if (!compact)
                  IconButton(
                    tooltip: 'First page',
                    icon: const Icon(Icons.first_page),
                    onPressed: hasPrevious ? onFirst : null,
                  ),
                IconButton(
                  tooltip: 'Previous page',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: hasPrevious ? onPrevious : null,
                ),
                IconButton(
                  tooltip: 'Next page',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: hasNext ? onNext : null,
                ),
                if (!compact)
                  IconButton(
                    tooltip: 'Last page',
                    icon: const Icon(Icons.last_page),
                    onPressed: hasNext ? onLast : null,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

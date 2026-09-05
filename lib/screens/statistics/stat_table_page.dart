import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/statistics/chart_export_dialog.dart';
import 'package:mdd/services/export.dart';
import 'package:mdd/services/system.dart';

class StatTableColumn {
  const StatTableColumn({
    required this.title,
    this.numeric = false,
    this.isItalic = false,
    this.tooltip = '',
  });

  final String title;
  final bool numeric;
  final bool isItalic;
  final String tooltip;
}

class StatTableRow {
  const StatTableRow({
    required this.values,
    required this.searchText,
  });

  final List<dynamic> values;
  final String searchText;
}

class StatTablePage extends ConsumerStatefulWidget {
  const StatTablePage({
    super.key,
    required this.title,
    required this.infoText,
    required this.exportDefaultFileName,
    required this.columns,
    required this.rows,
    this.defaultSortColumnIndex = 0,
    this.defaultSortAscending = true,
  });

  final String title;
  final String infoText;
  final String exportDefaultFileName;
  final List<StatTableColumn> columns;
  final List<StatTableRow> rows;
  final int defaultSortColumnIndex;
  final bool defaultSortAscending;

  @override
  ConsumerState<StatTablePage> createState() => _StatTablePageState();
}

class _StatTablePageState extends ConsumerState<StatTablePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late int _sortColumnIndex;
  late bool _sortAscending;
  int _rowsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _sortColumnIndex = widget.defaultSortColumnIndex;
    _sortAscending = widget.defaultSortAscending;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<StatTableRow> _filterAndSort(List<StatTableRow> items) {
    var list = items.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (row) => row.searchText.toLowerCase().contains(query),
          )
          .toList();
    }

    list.sort((a, b) {
      if (_sortColumnIndex >= widget.columns.length) return 0;
      final valA = a.values[_sortColumnIndex];
      final valB = b.values[_sortColumnIndex];

      int cmp = 0;
      if (valA is num && valB is num) {
        cmp = valA.compareTo(valB);
      } else if (valA is String &&
          valB is String &&
          valA.endsWith('%') &&
          valB.endsWith('%')) {
        final numA = double.tryParse(valA.replaceAll('%', '').trim()) ?? 0.0;
        final numB = double.tryParse(valB.replaceAll('%', '').trim()) ?? 0.0;
        cmp = numA.compareTo(numB);
      } else {
        cmp = valA.toString().compareTo(valB.toString());
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  Future<void> _exportData(List<StatTableRow> dataToExport) async {
    final ExportSettings? settings = await showDialog<ExportSettings>(
      context: context,
      builder: (context) => ChartExportDialog(
        defaultFileName: widget.exportDefaultFileName,
      ),
    );

    if (settings != null && mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      final headers = widget.columns.map((c) => c.title).toList();
      final rows = dataToExport.map((r) => r.values).toList();

      final exporter = TableDataExporter(
        fileName: settings.fileName,
        format: settings.format,
        headers: headers,
        rows: rows,
      );

      try {
        final result = await exporter.write(context);
        final platformType = getPlatformType();
        if (platformType == PlatformType.desktop && mounted && result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Done! File saved as $result'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Failed to export: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filterAndSort(widget.rows);
    final tableSource = _StatDataTableSource(
      columns: widget.columns,
      data: filteredList,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Table',
            onPressed: () => _exportData(filteredList),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoCard(text: widget.infoText),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search table...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withAlpha(180),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withAlpha(140),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withAlpha(140),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),
              const SizedBox(height: 12),
              const StatTableSortHint(),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withAlpha(130),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: PaginatedDataTable(
                  header: Text(
                    'Records (${filteredList.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: const [10, 15, 25, 50, 100],
                  onRowsPerPageChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _rowsPerPage = value;
                      });
                    }
                  },
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: List.generate(
                    widget.columns.length,
                    (index) => DataColumn(
                      label: StatTableHeaderLabel(
                        title: widget.columns[index].title,
                        columnIndex: index,
                        selectedColumnIndex: _sortColumnIndex,
                      ),
                      tooltip: widget.columns[index].tooltip.isNotEmpty
                          ? widget.columns[index].tooltip
                          : 'Sort by ${widget.columns[index].title}',
                      numeric: widget.columns[index].numeric,
                      onSort: _onSort,
                    ),
                  ),
                  source: tableSource,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatTableSortHint extends StatelessWidget {
  const StatTableSortHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.swap_vert,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          'Tap any column header to sort ascending or descending',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class StatTableHeaderLabel extends StatelessWidget {
  const StatTableHeaderLabel({
    super.key,
    required this.title,
    required this.columnIndex,
    required this.selectedColumnIndex,
  });

  final String title;
  final int columnIndex;
  final int selectedColumnIndex;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedColumnIndex == columnIndex;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final mutedColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    if (isSelected) {
      return Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.swap_vert,
          size: 14,
          color: mutedColor,
        ),
      ],
    );
  }
}

class _StatDataTableSource extends DataTableSource {
  _StatDataTableSource({
    required this.columns,
    required this.data,
  });

  final List<StatTableColumn> columns;
  final List<StatTableRow> data;

  static String _formatNumber(dynamic val) {
    if (val is int) {
      return val.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return val?.toString() ?? '';
  }

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= data.length) return null;
    final item = data[index];

    return DataRow.byIndex(
      index: index,
      cells: List.generate(columns.length, (colIdx) {
        final val = colIdx < item.values.length ? item.values[colIdx] : '';
        final col = columns[colIdx];
        final displayText = col.numeric ? _formatNumber(val) : val.toString();

        return DataCell(
          Text(
            displayText,
            style: TextStyle(
              fontStyle: col.isItalic ? FontStyle.italic : FontStyle.normal,
              fontWeight: colIdx == 0 && !col.numeric
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

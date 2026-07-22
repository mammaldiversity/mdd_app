import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/info_card.dart';
import 'package:mdd/screens/statistics/country_species_page.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';

class CountryTablePage extends ConsumerStatefulWidget {
  const CountryTablePage({super.key});

  @override
  ConsumerState<CountryTablePage> createState() => _CountryTablePageState();
}

class _CountryTablePageState extends ConsumerState<CountryTablePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _rowsPerPage = 15;

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

  List<CountryDiversityData> _filterAndSort(
    List<CountryDiversityData> countries,
  ) {
    var list = countries.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where((c) => c.countryName.toLowerCase().contains(query))
          .toList();
    }

    list.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.countryName.compareTo(b.countryName);
          break;
        case 1:
          cmp = a.totalOrders.compareTo(b.totalOrders);
          break;
        case 2:
          cmp = a.totalFamilies.compareTo(b.totalFamilies);
          break;
        case 3:
          cmp = a.totalGenera.compareTo(b.totalGenera);
          break;
        case 4:
          cmp = a.totalLivingSpecies.compareTo(b.totalLivingSpecies);
          break;
        case 5:
          cmp = a.totalExtinctSpecies.compareTo(b.totalExtinctSpecies);
          break;
        default:
          cmp = a.countryName.compareTo(b.countryName);
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  Widget _buildHeaderLabel(String title, int columnIndex) {
    final isSelected = _sortColumnIndex == columnIndex;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withValues(alpha: 0.4);

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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
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

  @override
  Widget build(BuildContext context) {
    final countryStatsAsync = ref.watch(countryDiversityStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mammal Diversity by Country'),
      ),
      body: SafeArea(
        child: countryStatsAsync.when(
          data: (allCountries) {
            final filteredList = _filterAndSort(allCountries);
            final tableSource = _CountryTableSource(
              context: context,
              data: filteredList,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const InfoCard(
                    text:
                        'Explore statistics on mammal diversity for each country listed in MDD, '
                        'including counts of orders, families, genera, extant species, and extinct species. '
                        'Click on a country to explore its mammal diversity.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PaginatedDataTable(
                      header: Text(
                        'Countries (${filteredList.length})',
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
                      columns: [
                        DataColumn(
                          label: _buildHeaderLabel('Country', 0),
                          tooltip: 'Sort by Country Name',
                          onSort: _onSort,
                        ),
                        DataColumn(
                          label: _buildHeaderLabel('Orders', 1),
                          tooltip: 'Sort by Total Orders',
                          numeric: true,
                          onSort: _onSort,
                        ),
                        DataColumn(
                          label: _buildHeaderLabel('Families', 2),
                          tooltip: 'Sort by Total Families',
                          numeric: true,
                          onSort: _onSort,
                        ),
                        DataColumn(
                          label: _buildHeaderLabel('Genera', 3),
                          tooltip: 'Sort by Total Genera',
                          numeric: true,
                          onSort: _onSort,
                        ),
                        DataColumn(
                          label: _buildHeaderLabel('Living Species', 4),
                          tooltip: 'Sort by Total Living Species',
                          numeric: true,
                          onSort: _onSort,
                        ),
                        DataColumn(
                          label: _buildHeaderLabel('Extinct Species', 5),
                          tooltip: 'Sort by Total Extinct Species',
                          numeric: true,
                          onSort: _onSort,
                        ),
                      ],
                      source: tableSource,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading country data: $error')),
        ),
      ),
    );
  }
}

class _CountryTableSource extends DataTableSource {
  final BuildContext context;
  final List<CountryDiversityData> data;

  _CountryTableSource({
    required this.context,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= data.length) return null;
    final item = data[index];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountrySpeciesPage(countryData: item),
                ),
              );
            },
            child: Text(
              item.countryName,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        DataCell(Text(item.totalOrders.toString())),
        DataCell(Text(item.totalFamilies.toString())),
        DataCell(Text(item.totalGenera.toString())),
        DataCell(Text(item.totalLivingSpecies.toString())),
        DataCell(Text(item.totalExtinctSpecies.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

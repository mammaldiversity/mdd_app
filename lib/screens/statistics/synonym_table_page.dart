import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/statistics/stat_table_page.dart';
import 'package:mdd/screens/taxon/synonyms.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/synonyms.dart';

const _title = 'Names and Synonyms';

const _columns = [
  StatTableColumn(title: 'Name', isItalic: true),
  StatTableColumn(title: 'Author'),
  StatTableColumn(title: 'Year'),
  StatTableColumn(
    title: 'Valid Species',
    isItalic: true,
    tooltip: 'Sort by the species MDD treats the name under',
  ),
  StatTableColumn(title: 'Validity'),
  StatTableColumn(title: 'Nomenclature Status'),
  StatTableColumn(title: 'Original Rank'),
  StatTableColumn(title: 'Type Country'),
  StatTableColumn(title: 'Order'),
  StatTableColumn(title: 'Family'),
];

/// The table rows, built once and kept so reopening the page is instant.
final _synonymRowsProvider = FutureProvider<List<StatTableRow>>((ref) async {
  final entries = await ref.watch(synonymTableProvider.future);
  final query = MddQuery(ref.watch(databaseProvider));
  return [for (final entry in entries) _synonymRow(entry, query)];
});

/// Every name and synonym in the database, searchable and filterable. A row
/// opens the name's details.
class SynonymTablePage extends ConsumerWidget {
  const SynonymTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(_synonymRowsProvider)
        .when(
          data: (rows) => StatTablePage(
            title: _title,
            infoText:
                'All names and synonyms recorded in the MDD, with the valid '
                'species each one belongs to. Tap a name to see its type '
                'locality, citation, and other details.',
            exportDefaultFileName: 'mdd_synonyms',
            defaultSortColumnIndex: 3,
            // The query already orders by valid species, then year.
            rowsInDefaultOrder: true,
            columns: _columns,
            rows: rows,
          ),
          loading: () => Scaffold(
            appBar: AppBar(title: const Text(_title)),
            body: const Center(child: SimpleLoadingMessages()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text(_title)),
            body: Center(child: Text('Error: $error')),
          ),
        );
  }
}

StatTableRow _synonymRow(SynonymTableEntry entry, MddQuery query) {
  final values = [
    entry.name,
    entry.author,
    entry.year,
    entry.validSpecies,
    entry.validity,
    entry.nomenclatureStatus,
    entry.originalRank,
    entry.typeCountry,
    entry.taxonOrder,
    entry.family,
  ];
  final synId = entry.synId;
  return StatTableRow(
    values: values,
    searchText: values.join(' '),
    onTap: (context) async {
      // The table holds only the shown columns; fetch the rest.
      final full = await query.retrieveSynonymById(synId);
      if (full != null && context.mounted) {
        showSynonymDetails(context, full);
      }
    },
  );
}

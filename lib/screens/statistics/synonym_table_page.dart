import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/statistics/stat_table_page.dart';
import 'package:mdd/screens/taxon/synonyms.dart';
import 'package:mdd/services/database/database.dart';
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

/// Every name and synonym in the database, searchable and filterable. A row
/// opens the name's details.
class SynonymTablePage extends ConsumerWidget {
  const SynonymTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = MddQuery(ref.read(databaseProvider));
    return ref
        .watch(synonymTableProvider)
        .when(
          data: (synonyms) => StatTablePage(
            title: _title,
            infoText:
                'All names and synonyms recorded in the MDD, with the valid '
                'species each one belongs to. Tap a name to see its type '
                'locality, citation, and other details.',
            exportDefaultFileName: 'mdd_synonyms',
            defaultSortColumnIndex: 3,
            columns: _columns,
            rows: [for (final synonym in synonyms) _synonymRow(synonym, query)],
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

StatTableRow _synonymRow(SynonymData synonym, MddQuery query) {
  final values = [
    SynonymName(data: synonym).getSynonym().name.trim(),
    _text(synonym.author),
    _text(synonym.year),
    '${_text(synonym.genus)} ${_text(synonym.specificEpithet)}'.trim(),
    _label(synonym.validity),
    _label(synonym.nomenclatureStatus),
    _label(synonym.originalRank),
    _text(synonym.typeCountry),
    _text(synonym.taxonOrder),
    _text(synonym.family),
  ];
  final synId = synonym.synId;
  return StatTableRow(
    values: values,
    searchText: values.join(' '),
    onTap: synId == null
        ? null
        : (context) async {
            // The table holds only the shown columns; fetch the rest.
            final full = await query.retrieveSynonymById(synId);
            if (full != null && context.mounted) {
              showSynonymDetails(context, full);
            }
          },
  );
}

String _text(String? value) {
  final text = value?.trim() ?? '';
  return text == 'NA' ? '' : text;
}

/// A coded value such as "nomen_dubium|preoccupied" as "nomen dubium,
/// preoccupied".
String _label(String? value) => _text(
  value,
).split('|').map((part) => part.trim().replaceAll('_', ' ')).join(', ');

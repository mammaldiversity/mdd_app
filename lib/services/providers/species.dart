import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'species.g.dart';

@Riverpod(keepAlive: true)
class SpeciesList extends _$SpeciesList {
  Future<List<MddSpeciesListResult>> _fetchSpeciesList() async {
    return await ref.watch(databaseProvider).retrieveSpeciesList();
  }

  @override
  FutureOr<List<MddSpeciesListResult>> build() async {
    return await _fetchSpeciesList();
  }
}

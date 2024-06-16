import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart' as mdd;
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

@riverpod
class TaxonData extends _$TaxonData {
  // Default to platypus
  int _mddID = 1000001;

  Future<TaxonomyData> _fetch() async {
    return await mdd.MddQuery(ref.read(databaseProvider))
        .retrieveTaxonData(_mddID);
  }

  @override
  FutureOr<TaxonomyData> build() async {
    return await _fetch();
  }

  void setMddID(int mddID) {
    _mddID = mddID;
  }
}

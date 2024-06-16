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

@Riverpod(keepAlive: true)
class CurrentMddID extends _$CurrentMddID {
  @override
  int build() {
    return 0;
  }

  void setMddID(int mddID) {
    state = mddID;
  }
}

@riverpod
class TaxonData extends _$TaxonData {
  Future<TaxonomyData> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await mdd.MddQuery(ref.read(databaseProvider))
        .retrieveTaxonData(mddID);
  }

  @override
  FutureOr<TaxonomyData> build() async {
    return await _fetch();
  }
}

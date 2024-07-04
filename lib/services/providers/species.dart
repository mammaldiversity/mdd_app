import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'species.g.dart';

@riverpod
class SearchDatabase extends _$SearchDatabase {
  @override
  FutureOr<List<MainTaxonomyData>> build() async {
    return [];
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      return await MddQuery(ref.read(databaseProvider)).searchSpecies(query);
    });
  }
}

@Riverpod(keepAlive: true)
Future<int> totalRecords(TotalRecordsRef ref) async {
  return await MddQuery(ref.read(databaseProvider)).totalRecords();
}

@Riverpod(keepAlive: true)
class SpeciesList extends _$SpeciesList {
  Future<List<MddGroupListResult>> _fetchSpeciesList() async {
    return MddQuery(ref.read(databaseProvider)).retrieveGroupList();
  }

  @override
  FutureOr<List<MddGroupListResult>> build() async {
    return await _fetchSpeciesList();
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return [];
      return await MddQuery(ref.read(databaseProvider)).searchTable(query);
    });
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
  Future<db.TaxonomyData> _fetch() async {
    final int mddID = ref.watch(currentMddIDProvider);
    return await MddQuery(ref.read(databaseProvider)).retrieveTaxonData(mddID);
  }

  @override
  FutureOr<db.TaxonomyData> build() async {
    return await _fetch();
  }
}

@riverpod
Future<List<MainTaxonomyData>> mainTaxonomyData(
    MainTaxonomyDataRef ref, List<int> mddIDList) async {
  return MddQuery(ref.read(databaseProvider)).retrieveSpeciesList(mddIDList);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';

final databaseProvider =
    NotifierProvider<DatabaseNotifier, AppDatabase>(() => DatabaseNotifier());

class DatabaseNotifier extends Notifier<AppDatabase> {
  @override
  AppDatabase build() {
    final db = AppDatabase();
    ref.onDispose(() {
      db.close();
    });
    return db;
  }

  void setDatabase(AppDatabase newDb) {
    state = newDb;
  }
}

final mddInfoProvider = FutureProvider<MddInfoData>((ref) {
  return MddQuery(ref.watch(databaseProvider)).retrieveMddInfo();
});


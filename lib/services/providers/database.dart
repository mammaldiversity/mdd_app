import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

final mddInfoProvider = FutureProvider<MddInfoData>((ref) {
  return MddQuery(ref.read(databaseProvider)).retrieveMddInfo();
});

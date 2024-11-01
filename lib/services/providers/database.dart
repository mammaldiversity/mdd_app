import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@Riverpod(keepAlive: true)
Future<MddInfoData> mddInfo(Ref ref) {
  return MddQuery(ref.read(databaseProvider)).retrieveMddInfo();
}

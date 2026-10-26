import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/debouncer.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/providers/species.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mdd_search_provider_test');
    db = AppDatabase.forFile(File('${dir.path}/test.db'));
    await db.createMigrator().createAll();
    await db.batch((b) {
      b.insertAll(db.taxonomy, [
        TaxonomyCompanion.insert(
          id: const Value(1),
          genus: const Value('Mus'),
          specificEpithet: const Value('musculus'),
        ),
        TaxonomyCompanion.insert(
          id: const Value(2),
          genus: const Value('Rattus'),
          specificEpithet: const Value('rattus'),
        ),
      ]);
    });
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithBuild((ref, notifier) => db)],
    );
    // Keep the auto-dispose-free provider alive and built.
    container.listen(searchDatabaseProvider, (_, _) {});
    await container.read(searchDatabaseProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });

  SearchDatabase notifier() => container.read(searchDatabaseProvider.notifier);
  List<int> ids() => container
      .read(searchDatabaseProvider)
      .requireValue
      .map((e) => e.id)
      .toList();

  Future<void> search(String query) =>
      notifier().search(query, filterBy: SearchFilter.genus);

  test('keeps previous results visible while a new search runs', () async {
    await search('Mus');
    expect(ids(), [1]);

    final pending = search('Rattus');
    final loading = container.read(searchDatabaseProvider);
    expect(loading.isLoading, isTrue);
    expect(
      loading.when(
        skipLoadingOnReload: true,
        data: (list) => list.map((e) => e.id).toList(),
        loading: () => 'spinner',
        error: (_, _) => 'error',
      ),
      [1],
    );
    await pending;
    expect(ids(), [2]);
  });

  test('only the latest search sets the results', () async {
    final first = search('Mus');
    final second = search('Rattus');
    await Future.wait([first, second]);
    expect(ids(), [2]);
  });

  test('clear drops a search still running', () async {
    final pending = search('Mus');
    notifier().clear();
    await pending;
    expect(ids(), isEmpty);
  });

  test('debouncer runs only the last action', () async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 20));
    final calls = <String>[];
    debouncer(() => calls.add('m'));
    debouncer(() => calls.add('mu'));
    debouncer(() => calls.add('mus'));
    expect(calls, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, ['mus']);
  });
}

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/table_filter_bar.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/rule_filter.dart';

void main() {
  group('matchesCell', () {
    test('compares numbers and percentages numerically', () {
      expect(matchesCell(300, RuleOperator.atLeast, '300'), isTrue);
      expect(matchesCell(299, RuleOperator.atLeast, '300'), isFalse);
      expect(matchesCell('12.5%', RuleOperator.greaterThan, '9'), isTrue);
      expect(matchesCell('1,234', RuleOperator.equals, '1234'), isTrue);
    });

    test('compares text case-insensitively', () {
      expect(matchesCell('Brazil', RuleOperator.contains, 'RAZ'), isTrue);
      expect(matchesCell('Brazil', RuleOperator.equals, 'brazil'), isTrue);
      expect(matchesCell('Brazil', RuleOperator.startsWith, 'br'), isTrue);
      expect(matchesCell('Brazil', RuleOperator.endsWith, 'zil'), isTrue);
      expect(matchesCell('Brazil', RuleOperator.doesNotContain, 'z'), isFalse);
      expect(matchesCell('Brazil', RuleOperator.notEquals, 'Peru'), isTrue);
    });
  });

  group('RuleFilter', () {
    final big = FilterRule(
      field: 1,
      operator: RuleOperator.atLeast,
      value: '300',
    );
    final named = FilterRule(
      field: 0,
      operator: RuleOperator.startsWith,
      value: 'M',
    );
    final values = ['Mexico', 566];

    bool run(RuleFilter<int> rules, List<dynamic> row) => tableRowMatches(
      values: row,
      searchText: row.join(' '),
      query: '',
      searchColumn: null,
      rules: rules,
    );

    test('ignores rules without a value', () {
      final rules = RuleFilter(
        rules: [FilterRule(field: 0, operator: RuleOperator.equals)],
      );
      expect(rules.isActive, isFalse);
      expect(run(rules, values), isTrue);
    });

    test('matches all or any', () {
      final all = RuleFilter(rules: [big, named]);
      expect(run(all, values), isTrue);
      expect(run(all, ['Peru', 566]), isFalse);
      expect(run(all.copyWith(match: RuleMatch.any), ['Peru', 566]), isTrue);
    });

    test('copyWith keeps the rule id', () {
      expect(big.copyWith(value: '10').id, big.id);
    });

    test('simple search can target one column', () {
      bool search(int? column) => tableRowMatches(
        values: ['Mexico', 566],
        searchText: 'Mexico 566',
        query: '566',
        searchColumn: column,
        rules: const RuleFilter(),
      );
      expect(search(null), isTrue);
      expect(search(1), isTrue);
      expect(search(0), isFalse);
    });
  });

  group('MDDSearch rules', () {
    late Directory dir;
    late AppDatabase db;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('mdd_rules_test');
      db = AppDatabase.forFile(File('${dir.path}/test.db'));
      await db.createMigrator().createAll();
      await db.batch((b) {
        b.insertAll(db.taxonomy, [
          TaxonomyCompanion.insert(
            id: const Value(1),
            taxonOrder: const Value('Rodentia'),
            genus: const Value('Mus'),
            specificEpithet: const Value('musculus'),
            sciName: const Value('Mus_musculus'),
            countryDistribution: const Value('Mexico|Peru'),
          ),
          TaxonomyCompanion.insert(
            id: const Value(2),
            taxonOrder: const Value('Rodentia'),
            genus: const Value('Rattus'),
            specificEpithet: const Value('rattus'),
            sciName: const Value('Rattus_rattus'),
            countryDistribution: const Value('Peru'),
          ),
          TaxonomyCompanion.insert(
            id: const Value(3),
            taxonOrder: const Value('Chiroptera'),
            genus: const Value('Myotis'),
            specificEpithet: const Value('lucifugus'),
            sciName: const Value('Myotis_lucifugus'),
            countryDistribution: const Value('Mexico'),
          ),
        ]);
      });
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    Future<List<int>> search(
      String query,
      List<FilterRule<SearchFilter>> rules, {
      RuleMatch match = RuleMatch.all,
    }) async {
      final results = await MDDSearch(db).searchSpecies(
        query,
        filterBy: SearchFilter.all,
        rules: RuleFilter(rules: rules, match: match),
      );
      return results.map((e) => e.id).toList()..sort();
    }

    test('rules alone select species', () async {
      final ids = await search('', [
        FilterRule(
          field: SearchFilter.order,
          operator: RuleOperator.equals,
          value: 'rodentia',
        ),
        FilterRule(
          field: SearchFilter.countryDistribution,
          operator: RuleOperator.doesNotContain,
          value: 'Mexico',
        ),
      ]);
      expect(ids, [2]);
    });

    test('match any unions rules', () async {
      final ids = await search('', [
        FilterRule(
          field: SearchFilter.genus,
          operator: RuleOperator.startsWith,
          value: 'Ra',
        ),
        FilterRule(
          field: SearchFilter.species,
          operator: RuleOperator.equals,
          value: 'Myotis lucifugus',
        ),
      ], match: RuleMatch.any);
      expect(ids, [2, 3]);
    });

    test('rules narrow the simple search', () async {
      final ids = await search('Mexico', [
        FilterRule(
          field: SearchFilter.order,
          operator: RuleOperator.notEquals,
          value: 'Chiroptera',
        ),
      ]);
      expect(ids, [1]);
    });
  });
}

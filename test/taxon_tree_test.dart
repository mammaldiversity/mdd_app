import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/taxon_tree.dart';

MddGroupListResult _row(int id, String order, String family, String genus) =>
    MddGroupListResult(id: id, taxonOrder: order, family: family, genus: genus);

TreeSpeciesData _sp(int id, String epithet, {bool extinct = false}) =>
    TreeSpeciesData(
      id: id,
      specificEpithet: epithet,
      mainCommonName: '',
      isExtinct: extinct,
    );

void main() {
  final rows = [
    _row(1, 'Carnivora', 'Felidae', 'Panthera'),
    _row(2, 'Carnivora', 'Felidae', 'Panthera'),
    _row(3, 'Carnivora', 'Felidae', 'Acinonyx'),
    _row(4, 'Carnivora', 'Canidae', 'Dusicyon'),
    _row(5, 'Carnivora', 'Canidae', 'Dusicyon'),
    _row(6, 'Monotremata', 'Tachyglossidae', 'Zaglossus'),
  ];
  final data = {
    1: _sp(1, 'tigris'),
    2: _sp(2, 'leo'),
    3: _sp(3, 'jubatus'),
    4: _sp(4, 'australis', extinct: true),
    5: _sp(5, 'zeta'),
    6: _sp(6, 'bruijnii'),
  };

  group('buildTaxonTree', () {
    final tree = buildTaxonTree(rows, data);

    test('keeps order database order and sorts families', () {
      expect(tree.map((n) => n.name), ['Carnivora', 'Monotremata']);
      expect(tree.first.children.map((n) => n.name), ['Canidae', 'Felidae']);
    });

    test('sorts genera and species alphabetically', () {
      final felidae = tree.first.children.last;
      expect(felidae.children.map((n) => n.name), ['Acinonyx', 'Panthera']);
      expect(felidae.children.last.children.map((n) => n.name), [
        'Panthera leo',
        'Panthera tigris',
      ]);
    });

    test('sorts species alphabetically regardless of extinct status', () {
      final dusicyon = tree.first.children.first.children.single;
      expect(dusicyon.children.map((n) => n.name), [
        'Dusicyon australis',
        'Dusicyon zeta',
      ]);
      expect(dusicyon.children.first.rankLabel, 'Extinct species');
    });

    test('counts species at every level', () {
      expect(tree.first.speciesCount, 5);
      expect(tree.first.children.last.speciesCount, 3);
      expect(tree.last.speciesCount, 1);
    });

    test('builds unique path keys', () {
      expect(
        tree.first.children.last.children.last.key,
        'Carnivora/Felidae/Panthera',
      );
      expect(collectParentKeys(tree), contains('Monotremata/Tachyglossidae'));
    });
  });

  group('flattenVisible', () {
    final tree = buildTaxonTree(rows, data);

    test('shows only roots when nothing is expanded', () {
      expect(flattenVisible(tree, {}).length, 2);
    });

    test('tracks connector state for expanded branches', () {
      final visible = flattenVisible(tree, {'Carnivora', 'Carnivora/Felidae'});
      expect(visible.map((r) => r.node.name), [
        'Carnivora',
        'Canidae',
        'Felidae',
        'Acinonyx',
        'Panthera',
        'Monotremata',
      ]);
      final acinonyx = visible[3];
      expect(acinonyx.depth, 2);
      expect(acinonyx.ancestorHasNext, [true, false]);
      expect(visible[4].isLast, isTrue);
      expect(visible.last.isLast, isTrue);
    });
  });
}

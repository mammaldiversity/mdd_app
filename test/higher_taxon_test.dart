import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/taxon_tree.dart';

TaxonomyData _sp(
  int id,
  String genus,
  String epithet, {
  String order = 'Rodentia',
  String suborder = 'Myomorpha',
  String family = 'Muridae',
  String subfamily = 'Murinae',
  String tribe = 'NA',
  String subgenus = 'NA',
  int extinct = 0,
  String? iucn,
  String? realm,
  String? countries,
  int? year,
}) => TaxonomyData(
  id: id,
  phylosort: id,
  subclass: 'Theria',
  infraclass: 'Placentalia',
  magnorder: 'Boreoeutheria',
  superorder: 'Euarchontoglires',
  taxonOrder: order,
  suborder: suborder,
  infraorder: 'NA',
  parvorder: '',
  superfamily: 'Muroidea',
  family: family,
  subfamily: subfamily,
  tribe: tribe,
  genus: genus,
  subgenus: subgenus,
  specificEpithet: epithet,
  sciName: '${genus}_$epithet',
  extinct: extinct,
  iucnStatus: iucn,
  biogeographicRealm: realm,
  countryDistribution: countries,
  authoritySpeciesYear: year,
);

void main() {
  final rows = [
    _sp(1, 'Rattus', 'rattus', tribe: 'Rattini', iucn: 'LC', year: 1758),
    _sp(2, 'Rattus', 'norvegicus', tribe: 'Rattini', iucn: 'LC (2016)'),
    _sp(3, 'Mus', 'musculus', tribe: 'Murini', subgenus: 'Mus', year: 1758),
    _sp(
      4,
      'Gerbillus',
      'gerbillus',
      subfamily: 'Gerbillinae',
      extinct: 1,
      iucn: 'EX',
      realm: 'Palearctic|Afrotropic?',
      countries: 'Egypt|Libya?|NA',
      year: 1801,
    ),
    // No subfamily or tribe: hangs directly under the family.
    _sp(5, 'Incertomys', 'sedis', subfamily: 'NA'),
  ];

  group('buildFullTaxonTree', () {
    final tree = buildFullTaxonTree(rows, (
      rank: TaxonRank.family,
      name: 'Muridae',
    ));

    test('includes minor ranks and skips NA ones', () {
      expect(tree.map((n) => (n.rank, n.name)), [
        (TaxonRank.subfamily, 'Gerbillinae'),
        (TaxonRank.subfamily, 'Murinae'),
        (TaxonRank.genus, 'Incertomys'),
      ]);
      final murinae = tree[1];
      expect(murinae.children.map((n) => n.name), ['Murini', 'Rattini']);
      final mus = murinae.children.first.children.single;
      expect(mus.name, 'Mus');
      expect(mus.children.single.rank, TaxonRank.subgenus);
      expect(mus.children.single.children.single.name, 'Mus musculus');
    });

    test('keys start at the root and species are sorted', () {
      final rattus = tree[1].children.last.children.single;
      expect(rattus.key, 'Muridae/Murinae/Rattini/Rattus');
      expect(rattus.children.map((n) => n.name), [
        'Rattus norvegicus',
        'Rattus rattus',
      ]);
      expect(tree.first.speciesCount, 1);
      expect(tree.first.children.single.children.single.isExtinct, isTrue);
    });

    test('roots at an order and keeps intermediate ranks', () {
      final orderTree = buildFullTaxonTree(rows, (
        rank: TaxonRank.order,
        name: 'Rodentia',
      ));
      expect(orderTree.single.rank, TaxonRank.suborder);
      expect(orderTree.single.children.single.rank, TaxonRank.superfamily);
    });

    test('roots at a genus with species leaves', () {
      final genusTree = buildFullTaxonTree(rows.sublist(0, 2), (
        rank: TaxonRank.genus,
        name: 'Rattus',
      ));
      expect(genusTree.every((n) => n.rank == TaxonRank.species), isTrue);
    });

    test('keeps orders in phylogenetic order', () {
      final orders = buildFullTaxonTree(
        [_sp(1, 'A', 'a', order: 'Zeta'), _sp(2, 'B', 'b', order: 'Alpha')],
        (rank: TaxonRank.superorder, name: 'Euarchontoglires'),
      );
      expect(orders.map((n) => n.name), ['Zeta', 'Alpha']);
    });
  });

  test('taxonLineage lists non-NA ranks above the root', () {
    expect(taxonLineage(rows.first, TaxonRank.family).map((e) => e.name), [
      'Theria',
      'Placentalia',
      'Boreoeutheria',
      'Euarchontoglires',
      'Rodentia',
      'Myomorpha',
      'Muroidea',
    ]);
  });

  test('HigherTaxonStats counts ranks, status, places, and years', () {
    final stats = HigherTaxonStats.fromRows(rows, TaxonRank.family);
    expect(stats.childCounts[TaxonRank.subfamily], 2);
    expect(stats.childCounts[TaxonRank.tribe], 2);
    expect(stats.childCounts[TaxonRank.genus], 4);
    expect(stats.childCounts.containsKey(TaxonRank.order), isFalse);
    expect(stats.speciesCount, 5);
    expect(stats.extinctCount, 1);
    expect(stats.livingCount, 4);
    expect(stats.iucnCounts.first, isA<MapEntry<String, int>>());
    expect(Map.fromEntries(stats.iucnCounts), {'LC': 2, 'EX': 1});
    expect(stats.realms.map((e) => e.key), ['Palearctic', 'Afrotropic']);
    expect(stats.countryCount, 2);
    expect(stats.firstDescribed, 1758);
    expect(stats.lastDescribed, 1801);
  });

  test('splitDelimitedValues drops uncertainty marks and NA', () {
    expect(StatisticsService.splitDelimitedValues(' Peru| Chile? |NA||'), [
      'Peru',
      'Chile',
    ]);
    expect(StatisticsService.normalizeIucnStatus('VU (2020)'), 'VU');
  });
}

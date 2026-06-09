// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdd_query.dart';

// ignore_for_file: type=lint
mixin _$MddQueryMixin on DatabaseAccessor<AppDatabase> {
  MddInfo get mddInfo => attachedDatabase.mddInfo;
  Taxonomy get taxonomy => attachedDatabase.taxonomy;
  Synonym get synonym => attachedDatabase.synonym;
  Selectable<MddGroupListResult> mddGroupList() {
    return customSelect('SELECT id, taxonOrder, family, genus FROM taxonomy',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => MddGroupListResult(
          id: row.read<int>('id'),
          taxonOrder: row.readNullable<String>('taxonOrder'),
          family: row.readNullable<String>('family'),
          genus: row.readNullable<String>('genus'),
        ));
  }

  Selectable<StatSpeciesPerOrderResult> statSpeciesPerOrder() {
    return customSelect(
        'SELECT taxonOrder AS name, COUNT(*) AS count FROM taxonomy GROUP BY taxonOrder ORDER BY count DESC',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatSpeciesPerOrderResult(
          name: row.readNullable<String>('name'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatSpeciesPerFamilyResult> statSpeciesPerFamily() {
    return customSelect(
        'SELECT family AS name, COUNT(*) AS count FROM taxonomy GROUP BY family ORDER BY count DESC LIMIT 15',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatSpeciesPerFamilyResult(
          name: row.readNullable<String>('name'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatSpeciesByIucnStatusResult> statSpeciesByIucnStatus() {
    return customSelect(
        'SELECT iucnStatus AS name, COUNT(*) AS count FROM taxonomy WHERE iucnStatus IS NOT NULL AND iucnStatus != \'\' GROUP BY iucnStatus ORDER BY count DESC',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatSpeciesByIucnStatusResult(
          name: row.readNullable<String>('name'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatSpeciesByDiscoveryDecadeResult>
      statSpeciesByDiscoveryDecade() {
    return customSelect(
        'SELECT(authoritySpeciesYear / 10)* 10 AS decade, COUNT(*) AS count FROM taxonomy WHERE authoritySpeciesYear IS NOT NULL AND authoritySpeciesYear > 0 GROUP BY decade ORDER BY decade ASC',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatSpeciesByDiscoveryDecadeResult(
          decade: row.readNullable<int>('decade'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatExtinctSpeciesResult> statExtinctSpecies() {
    return customSelect(
        'SELECT extinct AS isExtinct, COUNT(*) AS count FROM taxonomy GROUP BY extinct',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatExtinctSpeciesResult(
          isExtinct: row.readNullable<int>('isExtinct'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatDomesticSpeciesResult> statDomesticSpecies() {
    return customSelect(
        'SELECT domestic AS isDomestic, COUNT(*) AS count FROM taxonomy GROUP BY domestic',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatDomesticSpeciesResult(
          isDomestic: row.readNullable<int>('isDomestic'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<StatSpeciesByBiogeographicRealmResult>
      statSpeciesByBiogeographicRealm() {
    return customSelect(
        'SELECT biogeographicRealm AS name, COUNT(*) AS count FROM taxonomy WHERE biogeographicRealm IS NOT NULL AND biogeographicRealm != \'\' AND biogeographicRealm != \'NA\' GROUP BY biogeographicRealm ORDER BY count DESC',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => StatSpeciesByBiogeographicRealmResult(
          name: row.readNullable<String>('name'),
          count: row.read<int>('count'),
        ));
  }

  Selectable<String?> statCountryDistributions() {
    return customSelect(
        'SELECT countryDistribution FROM taxonomy WHERE countryDistribution IS NOT NULL AND countryDistribution != \'\'',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map(
        (QueryRow row) => row.readNullable<String>('countryDistribution'));
  }

  MddQueryManager get managers => MddQueryManager(this);
}

class MddQueryManager {
  final _$MddQueryMixin _db;
  MddQueryManager(this._db);
  $MddInfoTableManager get mddInfo =>
      $MddInfoTableManager(_db.attachedDatabase, _db.mddInfo);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db.attachedDatabase, _db.taxonomy);
  $SynonymTableManager get synonym =>
      $SynonymTableManager(_db.attachedDatabase, _db.synonym);
}

class MddGroupListResult {
  final int id;
  final String? taxonOrder;
  final String? family;
  final String? genus;
  MddGroupListResult({
    required this.id,
    this.taxonOrder,
    this.family,
    this.genus,
  });
}

class StatSpeciesPerOrderResult {
  final String? name;
  final int count;
  StatSpeciesPerOrderResult({
    this.name,
    required this.count,
  });
}

class StatSpeciesPerFamilyResult {
  final String? name;
  final int count;
  StatSpeciesPerFamilyResult({
    this.name,
    required this.count,
  });
}

class StatSpeciesByIucnStatusResult {
  final String? name;
  final int count;
  StatSpeciesByIucnStatusResult({
    this.name,
    required this.count,
  });
}

class StatSpeciesByDiscoveryDecadeResult {
  final int? decade;
  final int count;
  StatSpeciesByDiscoveryDecadeResult({
    this.decade,
    required this.count,
  });
}

class StatExtinctSpeciesResult {
  final int? isExtinct;
  final int count;
  StatExtinctSpeciesResult({
    this.isExtinct,
    required this.count,
  });
}

class StatDomesticSpeciesResult {
  final int? isDomestic;
  final int count;
  StatDomesticSpeciesResult({
    this.isDomestic,
    required this.count,
  });
}

class StatSpeciesByBiogeographicRealmResult {
  final String? name;
  final int count;
  StatSpeciesByBiogeographicRealmResult({
    this.name,
    required this.count,
  });
}

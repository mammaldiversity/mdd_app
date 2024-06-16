// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdd_query.dart';

// ignore_for_file: type=lint
mixin _$MddQueryMixin on DatabaseAccessor<AppDatabase> {
  MddInfo get mddInfo => attachedDatabase.mddInfo;
  Taxonomy get taxonomy => attachedDatabase.taxonomy;
  Selectable<MddSpeciesListResult> mddSpeciesList() {
    return customSelect(
        'SELECT id, taxonOrder, genus, specificEpithet, mainCommonName FROM taxonomy',
        variables: [],
        readsFrom: {
          taxonomy,
        }).map((QueryRow row) => MddSpeciesListResult(
          id: row.read<int>('id'),
          taxonOrder: row.readNullable<String>('taxonOrder'),
          genus: row.readNullable<String>('genus'),
          specificEpithet: row.readNullable<String>('specificEpithet'),
          mainCommonName: row.readNullable<String>('mainCommonName'),
        ));
  }
}

class MddSpeciesListResult {
  final int id;
  final String? taxonOrder;
  final String? genus;
  final String? specificEpithet;
  final String? mainCommonName;
  MddSpeciesListResult({
    required this.id,
    this.taxonOrder,
    this.genus,
    this.specificEpithet,
    this.mainCommonName,
  });
}

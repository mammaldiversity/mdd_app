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

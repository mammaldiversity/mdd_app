// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speciesListHash() => r'c358f28a6a2b9b7feda5644e79102a2f94f9240f';

/// See also [SpeciesList].
@ProviderFor(SpeciesList)
final speciesListProvider =
    AsyncNotifierProvider<SpeciesList, List<MddSpeciesListResult>>.internal(
  SpeciesList.new,
  name: r'speciesListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$speciesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesList = AsyncNotifier<List<MddSpeciesListResult>>;
String _$taxonDataHash() => r'a56df78ab524d69067688b351a5bc35f45a5e64a';

/// See also [TaxonData].
@ProviderFor(TaxonData)
final taxonDataProvider =
    AutoDisposeAsyncNotifierProvider<TaxonData, TaxonomyData>.internal(
  TaxonData.new,
  name: r'taxonDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taxonDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaxonData = AutoDisposeAsyncNotifier<TaxonomyData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

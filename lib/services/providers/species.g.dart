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
String _$currentMddIDHash() => r'554f46ead8e1918f344e191656d4a3da028dd3ee';

/// See also [CurrentMddID].
@ProviderFor(CurrentMddID)
final currentMddIDProvider = NotifierProvider<CurrentMddID, int>.internal(
  CurrentMddID.new,
  name: r'currentMddIDProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentMddIDHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentMddID = Notifier<int>;
String _$taxonDataHash() => r'74f82cd2dc0341d0468f30a84d732a0ddafdfadd';

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

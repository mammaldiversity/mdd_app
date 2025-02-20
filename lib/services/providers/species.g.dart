// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalRecordsHash() => r'd1c820391158d0b93ba74dbf950c66e826f9c025';

/// See also [totalRecords].
@ProviderFor(totalRecords)
final totalRecordsProvider = FutureProvider<int>.internal(
  totalRecords,
  name: r'totalRecordsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalRecordsRef = FutureProviderRef<int>;
String _$mainTaxonomyDataHash() => r'223c5de37af3c8ce12da57801acc941e0a3a6e84';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [mainTaxonomyData].
@ProviderFor(mainTaxonomyData)
const mainTaxonomyDataProvider = MainTaxonomyDataFamily();

/// See also [mainTaxonomyData].
class MainTaxonomyDataFamily
    extends Family<AsyncValue<List<MainTaxonomyData>>> {
  /// See also [mainTaxonomyData].
  const MainTaxonomyDataFamily();

  /// See also [mainTaxonomyData].
  MainTaxonomyDataProvider call(
    List<int> mddIDList,
  ) {
    return MainTaxonomyDataProvider(
      mddIDList,
    );
  }

  @override
  MainTaxonomyDataProvider getProviderOverride(
    covariant MainTaxonomyDataProvider provider,
  ) {
    return call(
      provider.mddIDList,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mainTaxonomyDataProvider';
}

/// See also [mainTaxonomyData].
class MainTaxonomyDataProvider
    extends AutoDisposeFutureProvider<List<MainTaxonomyData>> {
  /// See also [mainTaxonomyData].
  MainTaxonomyDataProvider(
    List<int> mddIDList,
  ) : this._internal(
          (ref) => mainTaxonomyData(
            ref as MainTaxonomyDataRef,
            mddIDList,
          ),
          from: mainTaxonomyDataProvider,
          name: r'mainTaxonomyDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mainTaxonomyDataHash,
          dependencies: MainTaxonomyDataFamily._dependencies,
          allTransitiveDependencies:
              MainTaxonomyDataFamily._allTransitiveDependencies,
          mddIDList: mddIDList,
        );

  MainTaxonomyDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mddIDList,
  }) : super.internal();

  final List<int> mddIDList;

  @override
  Override overrideWith(
    FutureOr<List<MainTaxonomyData>> Function(MainTaxonomyDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MainTaxonomyDataProvider._internal(
        (ref) => create(ref as MainTaxonomyDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mddIDList: mddIDList,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MainTaxonomyData>> createElement() {
    return _MainTaxonomyDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MainTaxonomyDataProvider && other.mddIDList == mddIDList;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mddIDList.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MainTaxonomyDataRef
    on AutoDisposeFutureProviderRef<List<MainTaxonomyData>> {
  /// The parameter `mddIDList` of this provider.
  List<int> get mddIDList;
}

class _MainTaxonomyDataProviderElement
    extends AutoDisposeFutureProviderElement<List<MainTaxonomyData>>
    with MainTaxonomyDataRef {
  _MainTaxonomyDataProviderElement(super.provider);

  @override
  List<int> get mddIDList => (origin as MainTaxonomyDataProvider).mddIDList;
}

String _$searchDatabaseHash() => r'48fe276b76fbfbde2626fd5051896653aac60d27';

/// See also [SearchDatabase].
@ProviderFor(SearchDatabase)
final searchDatabaseProvider = AutoDisposeAsyncNotifierProvider<SearchDatabase,
    List<MainTaxonomyData>>.internal(
  SearchDatabase.new,
  name: r'searchDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchDatabase = AutoDisposeAsyncNotifier<List<MainTaxonomyData>>;
String _$speciesListHash() => r'f8343024e9b6d86011ba3c4d8f719d8e2b18055a';

/// See also [SpeciesList].
@ProviderFor(SpeciesList)
final speciesListProvider =
    AsyncNotifierProvider<SpeciesList, List<MddGroupListResult>>.internal(
  SpeciesList.new,
  name: r'speciesListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$speciesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesList = AsyncNotifier<List<MddGroupListResult>>;
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
String _$taxonDataHash() => r'f62809f3732a3c4be143d8115cecee6ceb8a921b';

/// See also [TaxonData].
@ProviderFor(TaxonData)
final taxonDataProvider =
    AutoDisposeAsyncNotifierProvider<TaxonData, db.TaxonomyData>.internal(
  TaxonData.new,
  name: r'taxonDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taxonDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaxonData = AutoDisposeAsyncNotifier<db.TaxonomyData>;
String _$synonymDataHash() => r'32b1fa62388ba9ccc28f303aa08b6bc157c386e4';

/// See also [SynonymData].
@ProviderFor(SynonymData)
final synonymDataProvider = AutoDisposeAsyncNotifierProvider<SynonymData,
    List<db.SynonymData>>.internal(
  SynonymData.new,
  name: r'synonymDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$synonymDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SynonymData = AutoDisposeAsyncNotifier<List<db.SynonymData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

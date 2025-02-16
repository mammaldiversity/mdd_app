// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class MddInfo extends Table with TableInfo<MddInfo, MddInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MddInfo(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _releaseDateMeta =
      const VerificationMeta('releaseDate');
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
      'releaseDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [version, releaseDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mddInfo';
  @override
  VerificationContext validateIntegrity(Insertable<MddInfoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('releaseDate')) {
      context.handle(
          _releaseDateMeta,
          releaseDate.isAcceptableOrUnknown(
              data['releaseDate']!, _releaseDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MddInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MddInfoData(
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version']),
      releaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}releaseDate']),
    );
  }

  @override
  MddInfo createAlias(String alias) {
    return MddInfo(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MddInfoData extends DataClass implements Insertable<MddInfoData> {
  final String? version;
  final String? releaseDate;
  const MddInfoData({this.version, this.releaseDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['releaseDate'] = Variable<String>(releaseDate);
    }
    return map;
  }

  MddInfoCompanion toCompanion(bool nullToAbsent) {
    return MddInfoCompanion(
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
    );
  }

  factory MddInfoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MddInfoData(
      version: serializer.fromJson<String?>(json['version']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<String?>(version),
      'releaseDate': serializer.toJson<String?>(releaseDate),
    };
  }

  MddInfoData copyWith(
          {Value<String?> version = const Value.absent(),
          Value<String?> releaseDate = const Value.absent()}) =>
      MddInfoData(
        version: version.present ? version.value : this.version,
        releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
      );
  MddInfoData copyWithCompanion(MddInfoCompanion data) {
    return MddInfoData(
      version: data.version.present ? data.version.value : this.version,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MddInfoData(')
          ..write('version: $version, ')
          ..write('releaseDate: $releaseDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, releaseDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MddInfoData &&
          other.version == this.version &&
          other.releaseDate == this.releaseDate);
}

class MddInfoCompanion extends UpdateCompanion<MddInfoData> {
  final Value<String?> version;
  final Value<String?> releaseDate;
  final Value<int> rowid;
  const MddInfoCompanion({
    this.version = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MddInfoCompanion.insert({
    this.version = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<MddInfoData> custom({
    Expression<String>? version,
    Expression<String>? releaseDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (releaseDate != null) 'releaseDate': releaseDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MddInfoCompanion copyWith(
      {Value<String?>? version,
      Value<String?>? releaseDate,
      Value<int>? rowid}) {
    return MddInfoCompanion(
      version: version ?? this.version,
      releaseDate: releaseDate ?? this.releaseDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (releaseDate.present) {
      map['releaseDate'] = Variable<String>(releaseDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MddInfoCompanion(')
          ..write('version: $version, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Taxonomy extends Table with TableInfo<Taxonomy, TaxonomyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Taxonomy(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _phylosortMeta =
      const VerificationMeta('phylosort');
  late final GeneratedColumn<int> phylosort = GeneratedColumn<int>(
      'phylosort', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _subclassMeta =
      const VerificationMeta('subclass');
  late final GeneratedColumn<String> subclass = GeneratedColumn<String>(
      'subclass', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _infraclassMeta =
      const VerificationMeta('infraclass');
  late final GeneratedColumn<String> infraclass = GeneratedColumn<String>(
      'infraclass', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _magnorderMeta =
      const VerificationMeta('magnorder');
  late final GeneratedColumn<String> magnorder = GeneratedColumn<String>(
      'magnorder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _superorderMeta =
      const VerificationMeta('superorder');
  late final GeneratedColumn<String> superorder = GeneratedColumn<String>(
      'superorder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonOrderMeta =
      const VerificationMeta('taxonOrder');
  late final GeneratedColumn<String> taxonOrder = GeneratedColumn<String>(
      'taxonOrder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _suborderMeta =
      const VerificationMeta('suborder');
  late final GeneratedColumn<String> suborder = GeneratedColumn<String>(
      'suborder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _infraorderMeta =
      const VerificationMeta('infraorder');
  late final GeneratedColumn<String> infraorder = GeneratedColumn<String>(
      'infraorder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _parvorderMeta =
      const VerificationMeta('parvorder');
  late final GeneratedColumn<String> parvorder = GeneratedColumn<String>(
      'parvorder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _superfamilyMeta =
      const VerificationMeta('superfamily');
  late final GeneratedColumn<String> superfamily = GeneratedColumn<String>(
      'superfamily', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
      'family', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _subfamilyMeta =
      const VerificationMeta('subfamily');
  late final GeneratedColumn<String> subfamily = GeneratedColumn<String>(
      'subfamily', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tribeMeta = const VerificationMeta('tribe');
  late final GeneratedColumn<String> tribe = GeneratedColumn<String>(
      'tribe', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _genusMeta = const VerificationMeta('genus');
  late final GeneratedColumn<String> genus = GeneratedColumn<String>(
      'genus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _subgenusMeta =
      const VerificationMeta('subgenus');
  late final GeneratedColumn<String> subgenus = GeneratedColumn<String>(
      'subgenus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _specificEpithetMeta =
      const VerificationMeta('specificEpithet');
  late final GeneratedColumn<String> specificEpithet = GeneratedColumn<String>(
      'specificEpithet', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sciNameMeta =
      const VerificationMeta('sciName');
  late final GeneratedColumn<String> sciName = GeneratedColumn<String>(
      'sciName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authoritySpeciesAuthorMeta =
      const VerificationMeta('authoritySpeciesAuthor');
  late final GeneratedColumn<String> authoritySpeciesAuthor =
      GeneratedColumn<String>('authoritySpeciesAuthor', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _authoritySpeciesYearMeta =
      const VerificationMeta('authoritySpeciesYear');
  late final GeneratedColumn<int> authoritySpeciesYear = GeneratedColumn<int>(
      'authoritySpeciesYear', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityParenthesesMeta =
      const VerificationMeta('authorityParentheses');
  late final GeneratedColumn<int> authorityParentheses = GeneratedColumn<int>(
      'authorityParentheses', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mainCommonNameMeta =
      const VerificationMeta('mainCommonName');
  late final GeneratedColumn<String> mainCommonName = GeneratedColumn<String>(
      'mainCommonName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _otherCommonNamesMeta =
      const VerificationMeta('otherCommonNames');
  late final GeneratedColumn<String> otherCommonNames = GeneratedColumn<String>(
      'otherCommonNames', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _originalNameCombinationMeta =
      const VerificationMeta('originalNameCombination');
  late final GeneratedColumn<String> originalNameCombination =
      GeneratedColumn<String>('originalNameCombination', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _authoritySpeciesCitationMeta =
      const VerificationMeta('authoritySpeciesCitation');
  late final GeneratedColumn<String> authoritySpeciesCitation =
      GeneratedColumn<String>('authoritySpeciesCitation', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _authoritySpeciesLinkMeta =
      const VerificationMeta('authoritySpeciesLink');
  late final GeneratedColumn<String> authoritySpeciesLink =
      GeneratedColumn<String>('authoritySpeciesLink', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _typeVoucherMeta =
      const VerificationMeta('typeVoucher');
  late final GeneratedColumn<String> typeVoucher = GeneratedColumn<String>(
      'typeVoucher', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeKindMeta =
      const VerificationMeta('typeKind');
  late final GeneratedColumn<String> typeKind = GeneratedColumn<String>(
      'typeKind', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeVoucherURIsMeta =
      const VerificationMeta('typeVoucherURIs');
  late final GeneratedColumn<String> typeVoucherURIs = GeneratedColumn<String>(
      'typeVoucherURIs', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeLocalityMeta =
      const VerificationMeta('typeLocality');
  late final GeneratedColumn<String> typeLocality = GeneratedColumn<String>(
      'typeLocality', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeLocalityLatitudeMeta =
      const VerificationMeta('typeLocalityLatitude');
  late final GeneratedColumn<String> typeLocalityLatitude =
      GeneratedColumn<String>('typeLocalityLatitude', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _typeLocalityLongitudeMeta =
      const VerificationMeta('typeLocalityLongitude');
  late final GeneratedColumn<String> typeLocalityLongitude =
      GeneratedColumn<String>('typeLocalityLongitude', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _nominalNamesMeta =
      const VerificationMeta('nominalNames');
  late final GeneratedColumn<String> nominalNames = GeneratedColumn<String>(
      'nominalNames', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonomyNotesMeta =
      const VerificationMeta('taxonomyNotes');
  late final GeneratedColumn<String> taxonomyNotes = GeneratedColumn<String>(
      'taxonomyNotes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonomyNotesCitationMeta =
      const VerificationMeta('taxonomyNotesCitation');
  late final GeneratedColumn<String> taxonomyNotesCitation =
      GeneratedColumn<String>('taxonomyNotesCitation', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _distributionNotesMeta =
      const VerificationMeta('distributionNotes');
  late final GeneratedColumn<String> distributionNotes =
      GeneratedColumn<String>('distributionNotes', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _distributionNotesCitationMeta =
      const VerificationMeta('distributionNotesCitation');
  late final GeneratedColumn<String> distributionNotesCitation =
      GeneratedColumn<String>('distributionNotesCitation', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _subregionDistributionMeta =
      const VerificationMeta('subregionDistribution');
  late final GeneratedColumn<String> subregionDistribution =
      GeneratedColumn<String>('subregionDistribution', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _countryDistributionMeta =
      const VerificationMeta('countryDistribution');
  late final GeneratedColumn<String> countryDistribution =
      GeneratedColumn<String>('countryDistribution', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _continentDistributionMeta =
      const VerificationMeta('continentDistribution');
  late final GeneratedColumn<String> continentDistribution =
      GeneratedColumn<String>('continentDistribution', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _biogeographicRealmMeta =
      const VerificationMeta('biogeographicRealm');
  late final GeneratedColumn<String> biogeographicRealm =
      GeneratedColumn<String>('biogeographicRealm', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _iucnStatusMeta =
      const VerificationMeta('iucnStatus');
  late final GeneratedColumn<String> iucnStatus = GeneratedColumn<String>(
      'iucnStatus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _extinctMeta =
      const VerificationMeta('extinct');
  late final GeneratedColumn<String> extinct = GeneratedColumn<String>(
      'extinct', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _domesticMeta =
      const VerificationMeta('domestic');
  late final GeneratedColumn<String> domestic = GeneratedColumn<String>(
      'domestic', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _flaggedMeta =
      const VerificationMeta('flagged');
  late final GeneratedColumn<String> flagged = GeneratedColumn<String>(
      'flagged', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _cMWSciNameMeta =
      const VerificationMeta('cMWSciName');
  late final GeneratedColumn<String> cMWSciName = GeneratedColumn<String>(
      'CMW_sciName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _diffSinceCMWMeta =
      const VerificationMeta('diffSinceCMW');
  late final GeneratedColumn<String> diffSinceCMW = GeneratedColumn<String>(
      'diffSinceCMW', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mSW3MatchtypeMeta =
      const VerificationMeta('mSW3Matchtype');
  late final GeneratedColumn<String> mSW3Matchtype = GeneratedColumn<String>(
      'MSW3_matchtype', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mSW3SciNameMeta =
      const VerificationMeta('mSW3SciName');
  late final GeneratedColumn<String> mSW3SciName = GeneratedColumn<String>(
      'MSW3_sciName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _diffSinceMSW3Meta =
      const VerificationMeta('diffSinceMSW3');
  late final GeneratedColumn<String> diffSinceMSW3 = GeneratedColumn<String>(
      'diffSinceMSW3', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        phylosort,
        subclass,
        infraclass,
        magnorder,
        superorder,
        taxonOrder,
        suborder,
        infraorder,
        parvorder,
        superfamily,
        family,
        subfamily,
        tribe,
        genus,
        subgenus,
        specificEpithet,
        sciName,
        authoritySpeciesAuthor,
        authoritySpeciesYear,
        authorityParentheses,
        mainCommonName,
        otherCommonNames,
        originalNameCombination,
        authoritySpeciesCitation,
        authoritySpeciesLink,
        typeVoucher,
        typeKind,
        typeVoucherURIs,
        typeLocality,
        typeLocalityLatitude,
        typeLocalityLongitude,
        nominalNames,
        taxonomyNotes,
        taxonomyNotesCitation,
        distributionNotes,
        distributionNotesCitation,
        subregionDistribution,
        countryDistribution,
        continentDistribution,
        biogeographicRealm,
        iucnStatus,
        extinct,
        domestic,
        flagged,
        cMWSciName,
        diffSinceCMW,
        mSW3Matchtype,
        mSW3SciName,
        diffSinceMSW3
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxonomy';
  @override
  VerificationContext validateIntegrity(Insertable<TaxonomyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phylosort')) {
      context.handle(_phylosortMeta,
          phylosort.isAcceptableOrUnknown(data['phylosort']!, _phylosortMeta));
    }
    if (data.containsKey('subclass')) {
      context.handle(_subclassMeta,
          subclass.isAcceptableOrUnknown(data['subclass']!, _subclassMeta));
    }
    if (data.containsKey('infraclass')) {
      context.handle(
          _infraclassMeta,
          infraclass.isAcceptableOrUnknown(
              data['infraclass']!, _infraclassMeta));
    }
    if (data.containsKey('magnorder')) {
      context.handle(_magnorderMeta,
          magnorder.isAcceptableOrUnknown(data['magnorder']!, _magnorderMeta));
    }
    if (data.containsKey('superorder')) {
      context.handle(
          _superorderMeta,
          superorder.isAcceptableOrUnknown(
              data['superorder']!, _superorderMeta));
    }
    if (data.containsKey('taxonOrder')) {
      context.handle(
          _taxonOrderMeta,
          taxonOrder.isAcceptableOrUnknown(
              data['taxonOrder']!, _taxonOrderMeta));
    }
    if (data.containsKey('suborder')) {
      context.handle(_suborderMeta,
          suborder.isAcceptableOrUnknown(data['suborder']!, _suborderMeta));
    }
    if (data.containsKey('infraorder')) {
      context.handle(
          _infraorderMeta,
          infraorder.isAcceptableOrUnknown(
              data['infraorder']!, _infraorderMeta));
    }
    if (data.containsKey('parvorder')) {
      context.handle(_parvorderMeta,
          parvorder.isAcceptableOrUnknown(data['parvorder']!, _parvorderMeta));
    }
    if (data.containsKey('superfamily')) {
      context.handle(
          _superfamilyMeta,
          superfamily.isAcceptableOrUnknown(
              data['superfamily']!, _superfamilyMeta));
    }
    if (data.containsKey('family')) {
      context.handle(_familyMeta,
          family.isAcceptableOrUnknown(data['family']!, _familyMeta));
    }
    if (data.containsKey('subfamily')) {
      context.handle(_subfamilyMeta,
          subfamily.isAcceptableOrUnknown(data['subfamily']!, _subfamilyMeta));
    }
    if (data.containsKey('tribe')) {
      context.handle(
          _tribeMeta, tribe.isAcceptableOrUnknown(data['tribe']!, _tribeMeta));
    }
    if (data.containsKey('genus')) {
      context.handle(
          _genusMeta, genus.isAcceptableOrUnknown(data['genus']!, _genusMeta));
    }
    if (data.containsKey('subgenus')) {
      context.handle(_subgenusMeta,
          subgenus.isAcceptableOrUnknown(data['subgenus']!, _subgenusMeta));
    }
    if (data.containsKey('specificEpithet')) {
      context.handle(
          _specificEpithetMeta,
          specificEpithet.isAcceptableOrUnknown(
              data['specificEpithet']!, _specificEpithetMeta));
    }
    if (data.containsKey('sciName')) {
      context.handle(_sciNameMeta,
          sciName.isAcceptableOrUnknown(data['sciName']!, _sciNameMeta));
    }
    if (data.containsKey('authoritySpeciesAuthor')) {
      context.handle(
          _authoritySpeciesAuthorMeta,
          authoritySpeciesAuthor.isAcceptableOrUnknown(
              data['authoritySpeciesAuthor']!, _authoritySpeciesAuthorMeta));
    }
    if (data.containsKey('authoritySpeciesYear')) {
      context.handle(
          _authoritySpeciesYearMeta,
          authoritySpeciesYear.isAcceptableOrUnknown(
              data['authoritySpeciesYear']!, _authoritySpeciesYearMeta));
    }
    if (data.containsKey('authorityParentheses')) {
      context.handle(
          _authorityParenthesesMeta,
          authorityParentheses.isAcceptableOrUnknown(
              data['authorityParentheses']!, _authorityParenthesesMeta));
    }
    if (data.containsKey('mainCommonName')) {
      context.handle(
          _mainCommonNameMeta,
          mainCommonName.isAcceptableOrUnknown(
              data['mainCommonName']!, _mainCommonNameMeta));
    }
    if (data.containsKey('otherCommonNames')) {
      context.handle(
          _otherCommonNamesMeta,
          otherCommonNames.isAcceptableOrUnknown(
              data['otherCommonNames']!, _otherCommonNamesMeta));
    }
    if (data.containsKey('originalNameCombination')) {
      context.handle(
          _originalNameCombinationMeta,
          originalNameCombination.isAcceptableOrUnknown(
              data['originalNameCombination']!, _originalNameCombinationMeta));
    }
    if (data.containsKey('authoritySpeciesCitation')) {
      context.handle(
          _authoritySpeciesCitationMeta,
          authoritySpeciesCitation.isAcceptableOrUnknown(
              data['authoritySpeciesCitation']!,
              _authoritySpeciesCitationMeta));
    }
    if (data.containsKey('authoritySpeciesLink')) {
      context.handle(
          _authoritySpeciesLinkMeta,
          authoritySpeciesLink.isAcceptableOrUnknown(
              data['authoritySpeciesLink']!, _authoritySpeciesLinkMeta));
    }
    if (data.containsKey('typeVoucher')) {
      context.handle(
          _typeVoucherMeta,
          typeVoucher.isAcceptableOrUnknown(
              data['typeVoucher']!, _typeVoucherMeta));
    }
    if (data.containsKey('typeKind')) {
      context.handle(_typeKindMeta,
          typeKind.isAcceptableOrUnknown(data['typeKind']!, _typeKindMeta));
    }
    if (data.containsKey('typeVoucherURIs')) {
      context.handle(
          _typeVoucherURIsMeta,
          typeVoucherURIs.isAcceptableOrUnknown(
              data['typeVoucherURIs']!, _typeVoucherURIsMeta));
    }
    if (data.containsKey('typeLocality')) {
      context.handle(
          _typeLocalityMeta,
          typeLocality.isAcceptableOrUnknown(
              data['typeLocality']!, _typeLocalityMeta));
    }
    if (data.containsKey('typeLocalityLatitude')) {
      context.handle(
          _typeLocalityLatitudeMeta,
          typeLocalityLatitude.isAcceptableOrUnknown(
              data['typeLocalityLatitude']!, _typeLocalityLatitudeMeta));
    }
    if (data.containsKey('typeLocalityLongitude')) {
      context.handle(
          _typeLocalityLongitudeMeta,
          typeLocalityLongitude.isAcceptableOrUnknown(
              data['typeLocalityLongitude']!, _typeLocalityLongitudeMeta));
    }
    if (data.containsKey('nominalNames')) {
      context.handle(
          _nominalNamesMeta,
          nominalNames.isAcceptableOrUnknown(
              data['nominalNames']!, _nominalNamesMeta));
    }
    if (data.containsKey('taxonomyNotes')) {
      context.handle(
          _taxonomyNotesMeta,
          taxonomyNotes.isAcceptableOrUnknown(
              data['taxonomyNotes']!, _taxonomyNotesMeta));
    }
    if (data.containsKey('taxonomyNotesCitation')) {
      context.handle(
          _taxonomyNotesCitationMeta,
          taxonomyNotesCitation.isAcceptableOrUnknown(
              data['taxonomyNotesCitation']!, _taxonomyNotesCitationMeta));
    }
    if (data.containsKey('distributionNotes')) {
      context.handle(
          _distributionNotesMeta,
          distributionNotes.isAcceptableOrUnknown(
              data['distributionNotes']!, _distributionNotesMeta));
    }
    if (data.containsKey('distributionNotesCitation')) {
      context.handle(
          _distributionNotesCitationMeta,
          distributionNotesCitation.isAcceptableOrUnknown(
              data['distributionNotesCitation']!,
              _distributionNotesCitationMeta));
    }
    if (data.containsKey('subregionDistribution')) {
      context.handle(
          _subregionDistributionMeta,
          subregionDistribution.isAcceptableOrUnknown(
              data['subregionDistribution']!, _subregionDistributionMeta));
    }
    if (data.containsKey('countryDistribution')) {
      context.handle(
          _countryDistributionMeta,
          countryDistribution.isAcceptableOrUnknown(
              data['countryDistribution']!, _countryDistributionMeta));
    }
    if (data.containsKey('continentDistribution')) {
      context.handle(
          _continentDistributionMeta,
          continentDistribution.isAcceptableOrUnknown(
              data['continentDistribution']!, _continentDistributionMeta));
    }
    if (data.containsKey('biogeographicRealm')) {
      context.handle(
          _biogeographicRealmMeta,
          biogeographicRealm.isAcceptableOrUnknown(
              data['biogeographicRealm']!, _biogeographicRealmMeta));
    }
    if (data.containsKey('iucnStatus')) {
      context.handle(
          _iucnStatusMeta,
          iucnStatus.isAcceptableOrUnknown(
              data['iucnStatus']!, _iucnStatusMeta));
    }
    if (data.containsKey('extinct')) {
      context.handle(_extinctMeta,
          extinct.isAcceptableOrUnknown(data['extinct']!, _extinctMeta));
    }
    if (data.containsKey('domestic')) {
      context.handle(_domesticMeta,
          domestic.isAcceptableOrUnknown(data['domestic']!, _domesticMeta));
    }
    if (data.containsKey('flagged')) {
      context.handle(_flaggedMeta,
          flagged.isAcceptableOrUnknown(data['flagged']!, _flaggedMeta));
    }
    if (data.containsKey('CMW_sciName')) {
      context.handle(
          _cMWSciNameMeta,
          cMWSciName.isAcceptableOrUnknown(
              data['CMW_sciName']!, _cMWSciNameMeta));
    }
    if (data.containsKey('diffSinceCMW')) {
      context.handle(
          _diffSinceCMWMeta,
          diffSinceCMW.isAcceptableOrUnknown(
              data['diffSinceCMW']!, _diffSinceCMWMeta));
    }
    if (data.containsKey('MSW3_matchtype')) {
      context.handle(
          _mSW3MatchtypeMeta,
          mSW3Matchtype.isAcceptableOrUnknown(
              data['MSW3_matchtype']!, _mSW3MatchtypeMeta));
    }
    if (data.containsKey('MSW3_sciName')) {
      context.handle(
          _mSW3SciNameMeta,
          mSW3SciName.isAcceptableOrUnknown(
              data['MSW3_sciName']!, _mSW3SciNameMeta));
    }
    if (data.containsKey('diffSinceMSW3')) {
      context.handle(
          _diffSinceMSW3Meta,
          diffSinceMSW3.isAcceptableOrUnknown(
              data['diffSinceMSW3']!, _diffSinceMSW3Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxonomyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxonomyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      phylosort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phylosort']),
      subclass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subclass']),
      infraclass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}infraclass']),
      magnorder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}magnorder']),
      superorder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}superorder']),
      taxonOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonOrder']),
      suborder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suborder']),
      infraorder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}infraorder']),
      parvorder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parvorder']),
      superfamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}superfamily']),
      family: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family']),
      subfamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subfamily']),
      tribe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tribe']),
      genus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genus']),
      subgenus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subgenus']),
      specificEpithet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specificEpithet']),
      sciName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sciName']),
      authoritySpeciesAuthor: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authoritySpeciesAuthor']),
      authoritySpeciesYear: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}authoritySpeciesYear']),
      authorityParentheses: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}authorityParentheses']),
      mainCommonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mainCommonName']),
      otherCommonNames: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}otherCommonNames']),
      originalNameCombination: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}originalNameCombination']),
      authoritySpeciesCitation: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authoritySpeciesCitation']),
      authoritySpeciesLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authoritySpeciesLink']),
      typeVoucher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeVoucher']),
      typeKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeKind']),
      typeVoucherURIs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeVoucherURIs']),
      typeLocality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeLocality']),
      typeLocalityLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}typeLocalityLatitude']),
      typeLocalityLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}typeLocalityLongitude']),
      nominalNames: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nominalNames']),
      taxonomyNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonomyNotes']),
      taxonomyNotesCitation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}taxonomyNotesCitation']),
      distributionNotes: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}distributionNotes']),
      distributionNotesCitation: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distributionNotesCitation']),
      subregionDistribution: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subregionDistribution']),
      countryDistribution: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}countryDistribution']),
      continentDistribution: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}continentDistribution']),
      biogeographicRealm: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}biogeographicRealm']),
      iucnStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iucnStatus']),
      extinct: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extinct']),
      domestic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domestic']),
      flagged: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flagged']),
      cMWSciName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}CMW_sciName']),
      diffSinceCMW: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diffSinceCMW']),
      mSW3Matchtype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}MSW3_matchtype']),
      mSW3SciName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}MSW3_sciName']),
      diffSinceMSW3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diffSinceMSW3']),
    );
  }

  @override
  Taxonomy createAlias(String alias) {
    return Taxonomy(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TaxonomyData extends DataClass implements Insertable<TaxonomyData> {
  final int id;
  final int? phylosort;
  final String? subclass;
  final String? infraclass;
  final String? magnorder;
  final String? superorder;
  final String? taxonOrder;
  final String? suborder;
  final String? infraorder;
  final String? parvorder;
  final String? superfamily;
  final String? family;
  final String? subfamily;
  final String? tribe;
  final String? genus;
  final String? subgenus;
  final String? specificEpithet;
  final String? sciName;
  final String? authoritySpeciesAuthor;
  final int? authoritySpeciesYear;
  final int? authorityParentheses;
  final String? mainCommonName;
  final String? otherCommonNames;
  final String? originalNameCombination;
  final String? authoritySpeciesCitation;
  final String? authoritySpeciesLink;
  final String? typeVoucher;
  final String? typeKind;
  final String? typeVoucherURIs;
  final String? typeLocality;
  final String? typeLocalityLatitude;
  final String? typeLocalityLongitude;
  final String? nominalNames;
  final String? taxonomyNotes;
  final String? taxonomyNotesCitation;
  final String? distributionNotes;
  final String? distributionNotesCitation;
  final String? subregionDistribution;
  final String? countryDistribution;
  final String? continentDistribution;
  final String? biogeographicRealm;
  final String? iucnStatus;
  final String? extinct;
  final String? domestic;
  final String? flagged;
  final String? cMWSciName;
  final String? diffSinceCMW;
  final String? mSW3Matchtype;
  final String? mSW3SciName;
  final String? diffSinceMSW3;
  const TaxonomyData(
      {required this.id,
      this.phylosort,
      this.subclass,
      this.infraclass,
      this.magnorder,
      this.superorder,
      this.taxonOrder,
      this.suborder,
      this.infraorder,
      this.parvorder,
      this.superfamily,
      this.family,
      this.subfamily,
      this.tribe,
      this.genus,
      this.subgenus,
      this.specificEpithet,
      this.sciName,
      this.authoritySpeciesAuthor,
      this.authoritySpeciesYear,
      this.authorityParentheses,
      this.mainCommonName,
      this.otherCommonNames,
      this.originalNameCombination,
      this.authoritySpeciesCitation,
      this.authoritySpeciesLink,
      this.typeVoucher,
      this.typeKind,
      this.typeVoucherURIs,
      this.typeLocality,
      this.typeLocalityLatitude,
      this.typeLocalityLongitude,
      this.nominalNames,
      this.taxonomyNotes,
      this.taxonomyNotesCitation,
      this.distributionNotes,
      this.distributionNotesCitation,
      this.subregionDistribution,
      this.countryDistribution,
      this.continentDistribution,
      this.biogeographicRealm,
      this.iucnStatus,
      this.extinct,
      this.domestic,
      this.flagged,
      this.cMWSciName,
      this.diffSinceCMW,
      this.mSW3Matchtype,
      this.mSW3SciName,
      this.diffSinceMSW3});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || phylosort != null) {
      map['phylosort'] = Variable<int>(phylosort);
    }
    if (!nullToAbsent || subclass != null) {
      map['subclass'] = Variable<String>(subclass);
    }
    if (!nullToAbsent || infraclass != null) {
      map['infraclass'] = Variable<String>(infraclass);
    }
    if (!nullToAbsent || magnorder != null) {
      map['magnorder'] = Variable<String>(magnorder);
    }
    if (!nullToAbsent || superorder != null) {
      map['superorder'] = Variable<String>(superorder);
    }
    if (!nullToAbsent || taxonOrder != null) {
      map['taxonOrder'] = Variable<String>(taxonOrder);
    }
    if (!nullToAbsent || suborder != null) {
      map['suborder'] = Variable<String>(suborder);
    }
    if (!nullToAbsent || infraorder != null) {
      map['infraorder'] = Variable<String>(infraorder);
    }
    if (!nullToAbsent || parvorder != null) {
      map['parvorder'] = Variable<String>(parvorder);
    }
    if (!nullToAbsent || superfamily != null) {
      map['superfamily'] = Variable<String>(superfamily);
    }
    if (!nullToAbsent || family != null) {
      map['family'] = Variable<String>(family);
    }
    if (!nullToAbsent || subfamily != null) {
      map['subfamily'] = Variable<String>(subfamily);
    }
    if (!nullToAbsent || tribe != null) {
      map['tribe'] = Variable<String>(tribe);
    }
    if (!nullToAbsent || genus != null) {
      map['genus'] = Variable<String>(genus);
    }
    if (!nullToAbsent || subgenus != null) {
      map['subgenus'] = Variable<String>(subgenus);
    }
    if (!nullToAbsent || specificEpithet != null) {
      map['specificEpithet'] = Variable<String>(specificEpithet);
    }
    if (!nullToAbsent || sciName != null) {
      map['sciName'] = Variable<String>(sciName);
    }
    if (!nullToAbsent || authoritySpeciesAuthor != null) {
      map['authoritySpeciesAuthor'] = Variable<String>(authoritySpeciesAuthor);
    }
    if (!nullToAbsent || authoritySpeciesYear != null) {
      map['authoritySpeciesYear'] = Variable<int>(authoritySpeciesYear);
    }
    if (!nullToAbsent || authorityParentheses != null) {
      map['authorityParentheses'] = Variable<int>(authorityParentheses);
    }
    if (!nullToAbsent || mainCommonName != null) {
      map['mainCommonName'] = Variable<String>(mainCommonName);
    }
    if (!nullToAbsent || otherCommonNames != null) {
      map['otherCommonNames'] = Variable<String>(otherCommonNames);
    }
    if (!nullToAbsent || originalNameCombination != null) {
      map['originalNameCombination'] =
          Variable<String>(originalNameCombination);
    }
    if (!nullToAbsent || authoritySpeciesCitation != null) {
      map['authoritySpeciesCitation'] =
          Variable<String>(authoritySpeciesCitation);
    }
    if (!nullToAbsent || authoritySpeciesLink != null) {
      map['authoritySpeciesLink'] = Variable<String>(authoritySpeciesLink);
    }
    if (!nullToAbsent || typeVoucher != null) {
      map['typeVoucher'] = Variable<String>(typeVoucher);
    }
    if (!nullToAbsent || typeKind != null) {
      map['typeKind'] = Variable<String>(typeKind);
    }
    if (!nullToAbsent || typeVoucherURIs != null) {
      map['typeVoucherURIs'] = Variable<String>(typeVoucherURIs);
    }
    if (!nullToAbsent || typeLocality != null) {
      map['typeLocality'] = Variable<String>(typeLocality);
    }
    if (!nullToAbsent || typeLocalityLatitude != null) {
      map['typeLocalityLatitude'] = Variable<String>(typeLocalityLatitude);
    }
    if (!nullToAbsent || typeLocalityLongitude != null) {
      map['typeLocalityLongitude'] = Variable<String>(typeLocalityLongitude);
    }
    if (!nullToAbsent || nominalNames != null) {
      map['nominalNames'] = Variable<String>(nominalNames);
    }
    if (!nullToAbsent || taxonomyNotes != null) {
      map['taxonomyNotes'] = Variable<String>(taxonomyNotes);
    }
    if (!nullToAbsent || taxonomyNotesCitation != null) {
      map['taxonomyNotesCitation'] = Variable<String>(taxonomyNotesCitation);
    }
    if (!nullToAbsent || distributionNotes != null) {
      map['distributionNotes'] = Variable<String>(distributionNotes);
    }
    if (!nullToAbsent || distributionNotesCitation != null) {
      map['distributionNotesCitation'] =
          Variable<String>(distributionNotesCitation);
    }
    if (!nullToAbsent || subregionDistribution != null) {
      map['subregionDistribution'] = Variable<String>(subregionDistribution);
    }
    if (!nullToAbsent || countryDistribution != null) {
      map['countryDistribution'] = Variable<String>(countryDistribution);
    }
    if (!nullToAbsent || continentDistribution != null) {
      map['continentDistribution'] = Variable<String>(continentDistribution);
    }
    if (!nullToAbsent || biogeographicRealm != null) {
      map['biogeographicRealm'] = Variable<String>(biogeographicRealm);
    }
    if (!nullToAbsent || iucnStatus != null) {
      map['iucnStatus'] = Variable<String>(iucnStatus);
    }
    if (!nullToAbsent || extinct != null) {
      map['extinct'] = Variable<String>(extinct);
    }
    if (!nullToAbsent || domestic != null) {
      map['domestic'] = Variable<String>(domestic);
    }
    if (!nullToAbsent || flagged != null) {
      map['flagged'] = Variable<String>(flagged);
    }
    if (!nullToAbsent || cMWSciName != null) {
      map['CMW_sciName'] = Variable<String>(cMWSciName);
    }
    if (!nullToAbsent || diffSinceCMW != null) {
      map['diffSinceCMW'] = Variable<String>(diffSinceCMW);
    }
    if (!nullToAbsent || mSW3Matchtype != null) {
      map['MSW3_matchtype'] = Variable<String>(mSW3Matchtype);
    }
    if (!nullToAbsent || mSW3SciName != null) {
      map['MSW3_sciName'] = Variable<String>(mSW3SciName);
    }
    if (!nullToAbsent || diffSinceMSW3 != null) {
      map['diffSinceMSW3'] = Variable<String>(diffSinceMSW3);
    }
    return map;
  }

  TaxonomyCompanion toCompanion(bool nullToAbsent) {
    return TaxonomyCompanion(
      id: Value(id),
      phylosort: phylosort == null && nullToAbsent
          ? const Value.absent()
          : Value(phylosort),
      subclass: subclass == null && nullToAbsent
          ? const Value.absent()
          : Value(subclass),
      infraclass: infraclass == null && nullToAbsent
          ? const Value.absent()
          : Value(infraclass),
      magnorder: magnorder == null && nullToAbsent
          ? const Value.absent()
          : Value(magnorder),
      superorder: superorder == null && nullToAbsent
          ? const Value.absent()
          : Value(superorder),
      taxonOrder: taxonOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonOrder),
      suborder: suborder == null && nullToAbsent
          ? const Value.absent()
          : Value(suborder),
      infraorder: infraorder == null && nullToAbsent
          ? const Value.absent()
          : Value(infraorder),
      parvorder: parvorder == null && nullToAbsent
          ? const Value.absent()
          : Value(parvorder),
      superfamily: superfamily == null && nullToAbsent
          ? const Value.absent()
          : Value(superfamily),
      family:
          family == null && nullToAbsent ? const Value.absent() : Value(family),
      subfamily: subfamily == null && nullToAbsent
          ? const Value.absent()
          : Value(subfamily),
      tribe:
          tribe == null && nullToAbsent ? const Value.absent() : Value(tribe),
      genus:
          genus == null && nullToAbsent ? const Value.absent() : Value(genus),
      subgenus: subgenus == null && nullToAbsent
          ? const Value.absent()
          : Value(subgenus),
      specificEpithet: specificEpithet == null && nullToAbsent
          ? const Value.absent()
          : Value(specificEpithet),
      sciName: sciName == null && nullToAbsent
          ? const Value.absent()
          : Value(sciName),
      authoritySpeciesAuthor: authoritySpeciesAuthor == null && nullToAbsent
          ? const Value.absent()
          : Value(authoritySpeciesAuthor),
      authoritySpeciesYear: authoritySpeciesYear == null && nullToAbsent
          ? const Value.absent()
          : Value(authoritySpeciesYear),
      authorityParentheses: authorityParentheses == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityParentheses),
      mainCommonName: mainCommonName == null && nullToAbsent
          ? const Value.absent()
          : Value(mainCommonName),
      otherCommonNames: otherCommonNames == null && nullToAbsent
          ? const Value.absent()
          : Value(otherCommonNames),
      originalNameCombination: originalNameCombination == null && nullToAbsent
          ? const Value.absent()
          : Value(originalNameCombination),
      authoritySpeciesCitation: authoritySpeciesCitation == null && nullToAbsent
          ? const Value.absent()
          : Value(authoritySpeciesCitation),
      authoritySpeciesLink: authoritySpeciesLink == null && nullToAbsent
          ? const Value.absent()
          : Value(authoritySpeciesLink),
      typeVoucher: typeVoucher == null && nullToAbsent
          ? const Value.absent()
          : Value(typeVoucher),
      typeKind: typeKind == null && nullToAbsent
          ? const Value.absent()
          : Value(typeKind),
      typeVoucherURIs: typeVoucherURIs == null && nullToAbsent
          ? const Value.absent()
          : Value(typeVoucherURIs),
      typeLocality: typeLocality == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLocality),
      typeLocalityLatitude: typeLocalityLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLocalityLatitude),
      typeLocalityLongitude: typeLocalityLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLocalityLongitude),
      nominalNames: nominalNames == null && nullToAbsent
          ? const Value.absent()
          : Value(nominalNames),
      taxonomyNotes: taxonomyNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyNotes),
      taxonomyNotesCitation: taxonomyNotesCitation == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonomyNotesCitation),
      distributionNotes: distributionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(distributionNotes),
      distributionNotesCitation:
          distributionNotesCitation == null && nullToAbsent
              ? const Value.absent()
              : Value(distributionNotesCitation),
      subregionDistribution: subregionDistribution == null && nullToAbsent
          ? const Value.absent()
          : Value(subregionDistribution),
      countryDistribution: countryDistribution == null && nullToAbsent
          ? const Value.absent()
          : Value(countryDistribution),
      continentDistribution: continentDistribution == null && nullToAbsent
          ? const Value.absent()
          : Value(continentDistribution),
      biogeographicRealm: biogeographicRealm == null && nullToAbsent
          ? const Value.absent()
          : Value(biogeographicRealm),
      iucnStatus: iucnStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(iucnStatus),
      extinct: extinct == null && nullToAbsent
          ? const Value.absent()
          : Value(extinct),
      domestic: domestic == null && nullToAbsent
          ? const Value.absent()
          : Value(domestic),
      flagged: flagged == null && nullToAbsent
          ? const Value.absent()
          : Value(flagged),
      cMWSciName: cMWSciName == null && nullToAbsent
          ? const Value.absent()
          : Value(cMWSciName),
      diffSinceCMW: diffSinceCMW == null && nullToAbsent
          ? const Value.absent()
          : Value(diffSinceCMW),
      mSW3Matchtype: mSW3Matchtype == null && nullToAbsent
          ? const Value.absent()
          : Value(mSW3Matchtype),
      mSW3SciName: mSW3SciName == null && nullToAbsent
          ? const Value.absent()
          : Value(mSW3SciName),
      diffSinceMSW3: diffSinceMSW3 == null && nullToAbsent
          ? const Value.absent()
          : Value(diffSinceMSW3),
    );
  }

  factory TaxonomyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxonomyData(
      id: serializer.fromJson<int>(json['id']),
      phylosort: serializer.fromJson<int?>(json['phylosort']),
      subclass: serializer.fromJson<String?>(json['subclass']),
      infraclass: serializer.fromJson<String?>(json['infraclass']),
      magnorder: serializer.fromJson<String?>(json['magnorder']),
      superorder: serializer.fromJson<String?>(json['superorder']),
      taxonOrder: serializer.fromJson<String?>(json['taxonOrder']),
      suborder: serializer.fromJson<String?>(json['suborder']),
      infraorder: serializer.fromJson<String?>(json['infraorder']),
      parvorder: serializer.fromJson<String?>(json['parvorder']),
      superfamily: serializer.fromJson<String?>(json['superfamily']),
      family: serializer.fromJson<String?>(json['family']),
      subfamily: serializer.fromJson<String?>(json['subfamily']),
      tribe: serializer.fromJson<String?>(json['tribe']),
      genus: serializer.fromJson<String?>(json['genus']),
      subgenus: serializer.fromJson<String?>(json['subgenus']),
      specificEpithet: serializer.fromJson<String?>(json['specificEpithet']),
      sciName: serializer.fromJson<String?>(json['sciName']),
      authoritySpeciesAuthor:
          serializer.fromJson<String?>(json['authoritySpeciesAuthor']),
      authoritySpeciesYear:
          serializer.fromJson<int?>(json['authoritySpeciesYear']),
      authorityParentheses:
          serializer.fromJson<int?>(json['authorityParentheses']),
      mainCommonName: serializer.fromJson<String?>(json['mainCommonName']),
      otherCommonNames: serializer.fromJson<String?>(json['otherCommonNames']),
      originalNameCombination:
          serializer.fromJson<String?>(json['originalNameCombination']),
      authoritySpeciesCitation:
          serializer.fromJson<String?>(json['authoritySpeciesCitation']),
      authoritySpeciesLink:
          serializer.fromJson<String?>(json['authoritySpeciesLink']),
      typeVoucher: serializer.fromJson<String?>(json['typeVoucher']),
      typeKind: serializer.fromJson<String?>(json['typeKind']),
      typeVoucherURIs: serializer.fromJson<String?>(json['typeVoucherURIs']),
      typeLocality: serializer.fromJson<String?>(json['typeLocality']),
      typeLocalityLatitude:
          serializer.fromJson<String?>(json['typeLocalityLatitude']),
      typeLocalityLongitude:
          serializer.fromJson<String?>(json['typeLocalityLongitude']),
      nominalNames: serializer.fromJson<String?>(json['nominalNames']),
      taxonomyNotes: serializer.fromJson<String?>(json['taxonomyNotes']),
      taxonomyNotesCitation:
          serializer.fromJson<String?>(json['taxonomyNotesCitation']),
      distributionNotes:
          serializer.fromJson<String?>(json['distributionNotes']),
      distributionNotesCitation:
          serializer.fromJson<String?>(json['distributionNotesCitation']),
      subregionDistribution:
          serializer.fromJson<String?>(json['subregionDistribution']),
      countryDistribution:
          serializer.fromJson<String?>(json['countryDistribution']),
      continentDistribution:
          serializer.fromJson<String?>(json['continentDistribution']),
      biogeographicRealm:
          serializer.fromJson<String?>(json['biogeographicRealm']),
      iucnStatus: serializer.fromJson<String?>(json['iucnStatus']),
      extinct: serializer.fromJson<String?>(json['extinct']),
      domestic: serializer.fromJson<String?>(json['domestic']),
      flagged: serializer.fromJson<String?>(json['flagged']),
      cMWSciName: serializer.fromJson<String?>(json['CMW_sciName']),
      diffSinceCMW: serializer.fromJson<String?>(json['diffSinceCMW']),
      mSW3Matchtype: serializer.fromJson<String?>(json['MSW3_matchtype']),
      mSW3SciName: serializer.fromJson<String?>(json['MSW3_sciName']),
      diffSinceMSW3: serializer.fromJson<String?>(json['diffSinceMSW3']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phylosort': serializer.toJson<int?>(phylosort),
      'subclass': serializer.toJson<String?>(subclass),
      'infraclass': serializer.toJson<String?>(infraclass),
      'magnorder': serializer.toJson<String?>(magnorder),
      'superorder': serializer.toJson<String?>(superorder),
      'taxonOrder': serializer.toJson<String?>(taxonOrder),
      'suborder': serializer.toJson<String?>(suborder),
      'infraorder': serializer.toJson<String?>(infraorder),
      'parvorder': serializer.toJson<String?>(parvorder),
      'superfamily': serializer.toJson<String?>(superfamily),
      'family': serializer.toJson<String?>(family),
      'subfamily': serializer.toJson<String?>(subfamily),
      'tribe': serializer.toJson<String?>(tribe),
      'genus': serializer.toJson<String?>(genus),
      'subgenus': serializer.toJson<String?>(subgenus),
      'specificEpithet': serializer.toJson<String?>(specificEpithet),
      'sciName': serializer.toJson<String?>(sciName),
      'authoritySpeciesAuthor':
          serializer.toJson<String?>(authoritySpeciesAuthor),
      'authoritySpeciesYear': serializer.toJson<int?>(authoritySpeciesYear),
      'authorityParentheses': serializer.toJson<int?>(authorityParentheses),
      'mainCommonName': serializer.toJson<String?>(mainCommonName),
      'otherCommonNames': serializer.toJson<String?>(otherCommonNames),
      'originalNameCombination':
          serializer.toJson<String?>(originalNameCombination),
      'authoritySpeciesCitation':
          serializer.toJson<String?>(authoritySpeciesCitation),
      'authoritySpeciesLink': serializer.toJson<String?>(authoritySpeciesLink),
      'typeVoucher': serializer.toJson<String?>(typeVoucher),
      'typeKind': serializer.toJson<String?>(typeKind),
      'typeVoucherURIs': serializer.toJson<String?>(typeVoucherURIs),
      'typeLocality': serializer.toJson<String?>(typeLocality),
      'typeLocalityLatitude': serializer.toJson<String?>(typeLocalityLatitude),
      'typeLocalityLongitude':
          serializer.toJson<String?>(typeLocalityLongitude),
      'nominalNames': serializer.toJson<String?>(nominalNames),
      'taxonomyNotes': serializer.toJson<String?>(taxonomyNotes),
      'taxonomyNotesCitation':
          serializer.toJson<String?>(taxonomyNotesCitation),
      'distributionNotes': serializer.toJson<String?>(distributionNotes),
      'distributionNotesCitation':
          serializer.toJson<String?>(distributionNotesCitation),
      'subregionDistribution':
          serializer.toJson<String?>(subregionDistribution),
      'countryDistribution': serializer.toJson<String?>(countryDistribution),
      'continentDistribution':
          serializer.toJson<String?>(continentDistribution),
      'biogeographicRealm': serializer.toJson<String?>(biogeographicRealm),
      'iucnStatus': serializer.toJson<String?>(iucnStatus),
      'extinct': serializer.toJson<String?>(extinct),
      'domestic': serializer.toJson<String?>(domestic),
      'flagged': serializer.toJson<String?>(flagged),
      'CMW_sciName': serializer.toJson<String?>(cMWSciName),
      'diffSinceCMW': serializer.toJson<String?>(diffSinceCMW),
      'MSW3_matchtype': serializer.toJson<String?>(mSW3Matchtype),
      'MSW3_sciName': serializer.toJson<String?>(mSW3SciName),
      'diffSinceMSW3': serializer.toJson<String?>(diffSinceMSW3),
    };
  }

  TaxonomyData copyWith(
          {int? id,
          Value<int?> phylosort = const Value.absent(),
          Value<String?> subclass = const Value.absent(),
          Value<String?> infraclass = const Value.absent(),
          Value<String?> magnorder = const Value.absent(),
          Value<String?> superorder = const Value.absent(),
          Value<String?> taxonOrder = const Value.absent(),
          Value<String?> suborder = const Value.absent(),
          Value<String?> infraorder = const Value.absent(),
          Value<String?> parvorder = const Value.absent(),
          Value<String?> superfamily = const Value.absent(),
          Value<String?> family = const Value.absent(),
          Value<String?> subfamily = const Value.absent(),
          Value<String?> tribe = const Value.absent(),
          Value<String?> genus = const Value.absent(),
          Value<String?> subgenus = const Value.absent(),
          Value<String?> specificEpithet = const Value.absent(),
          Value<String?> sciName = const Value.absent(),
          Value<String?> authoritySpeciesAuthor = const Value.absent(),
          Value<int?> authoritySpeciesYear = const Value.absent(),
          Value<int?> authorityParentheses = const Value.absent(),
          Value<String?> mainCommonName = const Value.absent(),
          Value<String?> otherCommonNames = const Value.absent(),
          Value<String?> originalNameCombination = const Value.absent(),
          Value<String?> authoritySpeciesCitation = const Value.absent(),
          Value<String?> authoritySpeciesLink = const Value.absent(),
          Value<String?> typeVoucher = const Value.absent(),
          Value<String?> typeKind = const Value.absent(),
          Value<String?> typeVoucherURIs = const Value.absent(),
          Value<String?> typeLocality = const Value.absent(),
          Value<String?> typeLocalityLatitude = const Value.absent(),
          Value<String?> typeLocalityLongitude = const Value.absent(),
          Value<String?> nominalNames = const Value.absent(),
          Value<String?> taxonomyNotes = const Value.absent(),
          Value<String?> taxonomyNotesCitation = const Value.absent(),
          Value<String?> distributionNotes = const Value.absent(),
          Value<String?> distributionNotesCitation = const Value.absent(),
          Value<String?> subregionDistribution = const Value.absent(),
          Value<String?> countryDistribution = const Value.absent(),
          Value<String?> continentDistribution = const Value.absent(),
          Value<String?> biogeographicRealm = const Value.absent(),
          Value<String?> iucnStatus = const Value.absent(),
          Value<String?> extinct = const Value.absent(),
          Value<String?> domestic = const Value.absent(),
          Value<String?> flagged = const Value.absent(),
          Value<String?> cMWSciName = const Value.absent(),
          Value<String?> diffSinceCMW = const Value.absent(),
          Value<String?> mSW3Matchtype = const Value.absent(),
          Value<String?> mSW3SciName = const Value.absent(),
          Value<String?> diffSinceMSW3 = const Value.absent()}) =>
      TaxonomyData(
        id: id ?? this.id,
        phylosort: phylosort.present ? phylosort.value : this.phylosort,
        subclass: subclass.present ? subclass.value : this.subclass,
        infraclass: infraclass.present ? infraclass.value : this.infraclass,
        magnorder: magnorder.present ? magnorder.value : this.magnorder,
        superorder: superorder.present ? superorder.value : this.superorder,
        taxonOrder: taxonOrder.present ? taxonOrder.value : this.taxonOrder,
        suborder: suborder.present ? suborder.value : this.suborder,
        infraorder: infraorder.present ? infraorder.value : this.infraorder,
        parvorder: parvorder.present ? parvorder.value : this.parvorder,
        superfamily: superfamily.present ? superfamily.value : this.superfamily,
        family: family.present ? family.value : this.family,
        subfamily: subfamily.present ? subfamily.value : this.subfamily,
        tribe: tribe.present ? tribe.value : this.tribe,
        genus: genus.present ? genus.value : this.genus,
        subgenus: subgenus.present ? subgenus.value : this.subgenus,
        specificEpithet: specificEpithet.present
            ? specificEpithet.value
            : this.specificEpithet,
        sciName: sciName.present ? sciName.value : this.sciName,
        authoritySpeciesAuthor: authoritySpeciesAuthor.present
            ? authoritySpeciesAuthor.value
            : this.authoritySpeciesAuthor,
        authoritySpeciesYear: authoritySpeciesYear.present
            ? authoritySpeciesYear.value
            : this.authoritySpeciesYear,
        authorityParentheses: authorityParentheses.present
            ? authorityParentheses.value
            : this.authorityParentheses,
        mainCommonName:
            mainCommonName.present ? mainCommonName.value : this.mainCommonName,
        otherCommonNames: otherCommonNames.present
            ? otherCommonNames.value
            : this.otherCommonNames,
        originalNameCombination: originalNameCombination.present
            ? originalNameCombination.value
            : this.originalNameCombination,
        authoritySpeciesCitation: authoritySpeciesCitation.present
            ? authoritySpeciesCitation.value
            : this.authoritySpeciesCitation,
        authoritySpeciesLink: authoritySpeciesLink.present
            ? authoritySpeciesLink.value
            : this.authoritySpeciesLink,
        typeVoucher: typeVoucher.present ? typeVoucher.value : this.typeVoucher,
        typeKind: typeKind.present ? typeKind.value : this.typeKind,
        typeVoucherURIs: typeVoucherURIs.present
            ? typeVoucherURIs.value
            : this.typeVoucherURIs,
        typeLocality:
            typeLocality.present ? typeLocality.value : this.typeLocality,
        typeLocalityLatitude: typeLocalityLatitude.present
            ? typeLocalityLatitude.value
            : this.typeLocalityLatitude,
        typeLocalityLongitude: typeLocalityLongitude.present
            ? typeLocalityLongitude.value
            : this.typeLocalityLongitude,
        nominalNames:
            nominalNames.present ? nominalNames.value : this.nominalNames,
        taxonomyNotes:
            taxonomyNotes.present ? taxonomyNotes.value : this.taxonomyNotes,
        taxonomyNotesCitation: taxonomyNotesCitation.present
            ? taxonomyNotesCitation.value
            : this.taxonomyNotesCitation,
        distributionNotes: distributionNotes.present
            ? distributionNotes.value
            : this.distributionNotes,
        distributionNotesCitation: distributionNotesCitation.present
            ? distributionNotesCitation.value
            : this.distributionNotesCitation,
        subregionDistribution: subregionDistribution.present
            ? subregionDistribution.value
            : this.subregionDistribution,
        countryDistribution: countryDistribution.present
            ? countryDistribution.value
            : this.countryDistribution,
        continentDistribution: continentDistribution.present
            ? continentDistribution.value
            : this.continentDistribution,
        biogeographicRealm: biogeographicRealm.present
            ? biogeographicRealm.value
            : this.biogeographicRealm,
        iucnStatus: iucnStatus.present ? iucnStatus.value : this.iucnStatus,
        extinct: extinct.present ? extinct.value : this.extinct,
        domestic: domestic.present ? domestic.value : this.domestic,
        flagged: flagged.present ? flagged.value : this.flagged,
        cMWSciName: cMWSciName.present ? cMWSciName.value : this.cMWSciName,
        diffSinceCMW:
            diffSinceCMW.present ? diffSinceCMW.value : this.diffSinceCMW,
        mSW3Matchtype:
            mSW3Matchtype.present ? mSW3Matchtype.value : this.mSW3Matchtype,
        mSW3SciName: mSW3SciName.present ? mSW3SciName.value : this.mSW3SciName,
        diffSinceMSW3:
            diffSinceMSW3.present ? diffSinceMSW3.value : this.diffSinceMSW3,
      );
  TaxonomyData copyWithCompanion(TaxonomyCompanion data) {
    return TaxonomyData(
      id: data.id.present ? data.id.value : this.id,
      phylosort: data.phylosort.present ? data.phylosort.value : this.phylosort,
      subclass: data.subclass.present ? data.subclass.value : this.subclass,
      infraclass:
          data.infraclass.present ? data.infraclass.value : this.infraclass,
      magnorder: data.magnorder.present ? data.magnorder.value : this.magnorder,
      superorder:
          data.superorder.present ? data.superorder.value : this.superorder,
      taxonOrder:
          data.taxonOrder.present ? data.taxonOrder.value : this.taxonOrder,
      suborder: data.suborder.present ? data.suborder.value : this.suborder,
      infraorder:
          data.infraorder.present ? data.infraorder.value : this.infraorder,
      parvorder: data.parvorder.present ? data.parvorder.value : this.parvorder,
      superfamily:
          data.superfamily.present ? data.superfamily.value : this.superfamily,
      family: data.family.present ? data.family.value : this.family,
      subfamily: data.subfamily.present ? data.subfamily.value : this.subfamily,
      tribe: data.tribe.present ? data.tribe.value : this.tribe,
      genus: data.genus.present ? data.genus.value : this.genus,
      subgenus: data.subgenus.present ? data.subgenus.value : this.subgenus,
      specificEpithet: data.specificEpithet.present
          ? data.specificEpithet.value
          : this.specificEpithet,
      sciName: data.sciName.present ? data.sciName.value : this.sciName,
      authoritySpeciesAuthor: data.authoritySpeciesAuthor.present
          ? data.authoritySpeciesAuthor.value
          : this.authoritySpeciesAuthor,
      authoritySpeciesYear: data.authoritySpeciesYear.present
          ? data.authoritySpeciesYear.value
          : this.authoritySpeciesYear,
      authorityParentheses: data.authorityParentheses.present
          ? data.authorityParentheses.value
          : this.authorityParentheses,
      mainCommonName: data.mainCommonName.present
          ? data.mainCommonName.value
          : this.mainCommonName,
      otherCommonNames: data.otherCommonNames.present
          ? data.otherCommonNames.value
          : this.otherCommonNames,
      originalNameCombination: data.originalNameCombination.present
          ? data.originalNameCombination.value
          : this.originalNameCombination,
      authoritySpeciesCitation: data.authoritySpeciesCitation.present
          ? data.authoritySpeciesCitation.value
          : this.authoritySpeciesCitation,
      authoritySpeciesLink: data.authoritySpeciesLink.present
          ? data.authoritySpeciesLink.value
          : this.authoritySpeciesLink,
      typeVoucher:
          data.typeVoucher.present ? data.typeVoucher.value : this.typeVoucher,
      typeKind: data.typeKind.present ? data.typeKind.value : this.typeKind,
      typeVoucherURIs: data.typeVoucherURIs.present
          ? data.typeVoucherURIs.value
          : this.typeVoucherURIs,
      typeLocality: data.typeLocality.present
          ? data.typeLocality.value
          : this.typeLocality,
      typeLocalityLatitude: data.typeLocalityLatitude.present
          ? data.typeLocalityLatitude.value
          : this.typeLocalityLatitude,
      typeLocalityLongitude: data.typeLocalityLongitude.present
          ? data.typeLocalityLongitude.value
          : this.typeLocalityLongitude,
      nominalNames: data.nominalNames.present
          ? data.nominalNames.value
          : this.nominalNames,
      taxonomyNotes: data.taxonomyNotes.present
          ? data.taxonomyNotes.value
          : this.taxonomyNotes,
      taxonomyNotesCitation: data.taxonomyNotesCitation.present
          ? data.taxonomyNotesCitation.value
          : this.taxonomyNotesCitation,
      distributionNotes: data.distributionNotes.present
          ? data.distributionNotes.value
          : this.distributionNotes,
      distributionNotesCitation: data.distributionNotesCitation.present
          ? data.distributionNotesCitation.value
          : this.distributionNotesCitation,
      subregionDistribution: data.subregionDistribution.present
          ? data.subregionDistribution.value
          : this.subregionDistribution,
      countryDistribution: data.countryDistribution.present
          ? data.countryDistribution.value
          : this.countryDistribution,
      continentDistribution: data.continentDistribution.present
          ? data.continentDistribution.value
          : this.continentDistribution,
      biogeographicRealm: data.biogeographicRealm.present
          ? data.biogeographicRealm.value
          : this.biogeographicRealm,
      iucnStatus:
          data.iucnStatus.present ? data.iucnStatus.value : this.iucnStatus,
      extinct: data.extinct.present ? data.extinct.value : this.extinct,
      domestic: data.domestic.present ? data.domestic.value : this.domestic,
      flagged: data.flagged.present ? data.flagged.value : this.flagged,
      cMWSciName:
          data.cMWSciName.present ? data.cMWSciName.value : this.cMWSciName,
      diffSinceCMW: data.diffSinceCMW.present
          ? data.diffSinceCMW.value
          : this.diffSinceCMW,
      mSW3Matchtype: data.mSW3Matchtype.present
          ? data.mSW3Matchtype.value
          : this.mSW3Matchtype,
      mSW3SciName:
          data.mSW3SciName.present ? data.mSW3SciName.value : this.mSW3SciName,
      diffSinceMSW3: data.diffSinceMSW3.present
          ? data.diffSinceMSW3.value
          : this.diffSinceMSW3,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxonomyData(')
          ..write('id: $id, ')
          ..write('phylosort: $phylosort, ')
          ..write('subclass: $subclass, ')
          ..write('infraclass: $infraclass, ')
          ..write('magnorder: $magnorder, ')
          ..write('superorder: $superorder, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('suborder: $suborder, ')
          ..write('infraorder: $infraorder, ')
          ..write('parvorder: $parvorder, ')
          ..write('superfamily: $superfamily, ')
          ..write('family: $family, ')
          ..write('subfamily: $subfamily, ')
          ..write('tribe: $tribe, ')
          ..write('genus: $genus, ')
          ..write('subgenus: $subgenus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('sciName: $sciName, ')
          ..write('authoritySpeciesAuthor: $authoritySpeciesAuthor, ')
          ..write('authoritySpeciesYear: $authoritySpeciesYear, ')
          ..write('authorityParentheses: $authorityParentheses, ')
          ..write('mainCommonName: $mainCommonName, ')
          ..write('otherCommonNames: $otherCommonNames, ')
          ..write('originalNameCombination: $originalNameCombination, ')
          ..write('authoritySpeciesCitation: $authoritySpeciesCitation, ')
          ..write('authoritySpeciesLink: $authoritySpeciesLink, ')
          ..write('typeVoucher: $typeVoucher, ')
          ..write('typeKind: $typeKind, ')
          ..write('typeVoucherURIs: $typeVoucherURIs, ')
          ..write('typeLocality: $typeLocality, ')
          ..write('typeLocalityLatitude: $typeLocalityLatitude, ')
          ..write('typeLocalityLongitude: $typeLocalityLongitude, ')
          ..write('nominalNames: $nominalNames, ')
          ..write('taxonomyNotes: $taxonomyNotes, ')
          ..write('taxonomyNotesCitation: $taxonomyNotesCitation, ')
          ..write('distributionNotes: $distributionNotes, ')
          ..write('distributionNotesCitation: $distributionNotesCitation, ')
          ..write('subregionDistribution: $subregionDistribution, ')
          ..write('countryDistribution: $countryDistribution, ')
          ..write('continentDistribution: $continentDistribution, ')
          ..write('biogeographicRealm: $biogeographicRealm, ')
          ..write('iucnStatus: $iucnStatus, ')
          ..write('extinct: $extinct, ')
          ..write('domestic: $domestic, ')
          ..write('flagged: $flagged, ')
          ..write('cMWSciName: $cMWSciName, ')
          ..write('diffSinceCMW: $diffSinceCMW, ')
          ..write('mSW3Matchtype: $mSW3Matchtype, ')
          ..write('mSW3SciName: $mSW3SciName, ')
          ..write('diffSinceMSW3: $diffSinceMSW3')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        phylosort,
        subclass,
        infraclass,
        magnorder,
        superorder,
        taxonOrder,
        suborder,
        infraorder,
        parvorder,
        superfamily,
        family,
        subfamily,
        tribe,
        genus,
        subgenus,
        specificEpithet,
        sciName,
        authoritySpeciesAuthor,
        authoritySpeciesYear,
        authorityParentheses,
        mainCommonName,
        otherCommonNames,
        originalNameCombination,
        authoritySpeciesCitation,
        authoritySpeciesLink,
        typeVoucher,
        typeKind,
        typeVoucherURIs,
        typeLocality,
        typeLocalityLatitude,
        typeLocalityLongitude,
        nominalNames,
        taxonomyNotes,
        taxonomyNotesCitation,
        distributionNotes,
        distributionNotesCitation,
        subregionDistribution,
        countryDistribution,
        continentDistribution,
        biogeographicRealm,
        iucnStatus,
        extinct,
        domestic,
        flagged,
        cMWSciName,
        diffSinceCMW,
        mSW3Matchtype,
        mSW3SciName,
        diffSinceMSW3
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxonomyData &&
          other.id == this.id &&
          other.phylosort == this.phylosort &&
          other.subclass == this.subclass &&
          other.infraclass == this.infraclass &&
          other.magnorder == this.magnorder &&
          other.superorder == this.superorder &&
          other.taxonOrder == this.taxonOrder &&
          other.suborder == this.suborder &&
          other.infraorder == this.infraorder &&
          other.parvorder == this.parvorder &&
          other.superfamily == this.superfamily &&
          other.family == this.family &&
          other.subfamily == this.subfamily &&
          other.tribe == this.tribe &&
          other.genus == this.genus &&
          other.subgenus == this.subgenus &&
          other.specificEpithet == this.specificEpithet &&
          other.sciName == this.sciName &&
          other.authoritySpeciesAuthor == this.authoritySpeciesAuthor &&
          other.authoritySpeciesYear == this.authoritySpeciesYear &&
          other.authorityParentheses == this.authorityParentheses &&
          other.mainCommonName == this.mainCommonName &&
          other.otherCommonNames == this.otherCommonNames &&
          other.originalNameCombination == this.originalNameCombination &&
          other.authoritySpeciesCitation == this.authoritySpeciesCitation &&
          other.authoritySpeciesLink == this.authoritySpeciesLink &&
          other.typeVoucher == this.typeVoucher &&
          other.typeKind == this.typeKind &&
          other.typeVoucherURIs == this.typeVoucherURIs &&
          other.typeLocality == this.typeLocality &&
          other.typeLocalityLatitude == this.typeLocalityLatitude &&
          other.typeLocalityLongitude == this.typeLocalityLongitude &&
          other.nominalNames == this.nominalNames &&
          other.taxonomyNotes == this.taxonomyNotes &&
          other.taxonomyNotesCitation == this.taxonomyNotesCitation &&
          other.distributionNotes == this.distributionNotes &&
          other.distributionNotesCitation == this.distributionNotesCitation &&
          other.subregionDistribution == this.subregionDistribution &&
          other.countryDistribution == this.countryDistribution &&
          other.continentDistribution == this.continentDistribution &&
          other.biogeographicRealm == this.biogeographicRealm &&
          other.iucnStatus == this.iucnStatus &&
          other.extinct == this.extinct &&
          other.domestic == this.domestic &&
          other.flagged == this.flagged &&
          other.cMWSciName == this.cMWSciName &&
          other.diffSinceCMW == this.diffSinceCMW &&
          other.mSW3Matchtype == this.mSW3Matchtype &&
          other.mSW3SciName == this.mSW3SciName &&
          other.diffSinceMSW3 == this.diffSinceMSW3);
}

class TaxonomyCompanion extends UpdateCompanion<TaxonomyData> {
  final Value<int> id;
  final Value<int?> phylosort;
  final Value<String?> subclass;
  final Value<String?> infraclass;
  final Value<String?> magnorder;
  final Value<String?> superorder;
  final Value<String?> taxonOrder;
  final Value<String?> suborder;
  final Value<String?> infraorder;
  final Value<String?> parvorder;
  final Value<String?> superfamily;
  final Value<String?> family;
  final Value<String?> subfamily;
  final Value<String?> tribe;
  final Value<String?> genus;
  final Value<String?> subgenus;
  final Value<String?> specificEpithet;
  final Value<String?> sciName;
  final Value<String?> authoritySpeciesAuthor;
  final Value<int?> authoritySpeciesYear;
  final Value<int?> authorityParentheses;
  final Value<String?> mainCommonName;
  final Value<String?> otherCommonNames;
  final Value<String?> originalNameCombination;
  final Value<String?> authoritySpeciesCitation;
  final Value<String?> authoritySpeciesLink;
  final Value<String?> typeVoucher;
  final Value<String?> typeKind;
  final Value<String?> typeVoucherURIs;
  final Value<String?> typeLocality;
  final Value<String?> typeLocalityLatitude;
  final Value<String?> typeLocalityLongitude;
  final Value<String?> nominalNames;
  final Value<String?> taxonomyNotes;
  final Value<String?> taxonomyNotesCitation;
  final Value<String?> distributionNotes;
  final Value<String?> distributionNotesCitation;
  final Value<String?> subregionDistribution;
  final Value<String?> countryDistribution;
  final Value<String?> continentDistribution;
  final Value<String?> biogeographicRealm;
  final Value<String?> iucnStatus;
  final Value<String?> extinct;
  final Value<String?> domestic;
  final Value<String?> flagged;
  final Value<String?> cMWSciName;
  final Value<String?> diffSinceCMW;
  final Value<String?> mSW3Matchtype;
  final Value<String?> mSW3SciName;
  final Value<String?> diffSinceMSW3;
  const TaxonomyCompanion({
    this.id = const Value.absent(),
    this.phylosort = const Value.absent(),
    this.subclass = const Value.absent(),
    this.infraclass = const Value.absent(),
    this.magnorder = const Value.absent(),
    this.superorder = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.suborder = const Value.absent(),
    this.infraorder = const Value.absent(),
    this.parvorder = const Value.absent(),
    this.superfamily = const Value.absent(),
    this.family = const Value.absent(),
    this.subfamily = const Value.absent(),
    this.tribe = const Value.absent(),
    this.genus = const Value.absent(),
    this.subgenus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.sciName = const Value.absent(),
    this.authoritySpeciesAuthor = const Value.absent(),
    this.authoritySpeciesYear = const Value.absent(),
    this.authorityParentheses = const Value.absent(),
    this.mainCommonName = const Value.absent(),
    this.otherCommonNames = const Value.absent(),
    this.originalNameCombination = const Value.absent(),
    this.authoritySpeciesCitation = const Value.absent(),
    this.authoritySpeciesLink = const Value.absent(),
    this.typeVoucher = const Value.absent(),
    this.typeKind = const Value.absent(),
    this.typeVoucherURIs = const Value.absent(),
    this.typeLocality = const Value.absent(),
    this.typeLocalityLatitude = const Value.absent(),
    this.typeLocalityLongitude = const Value.absent(),
    this.nominalNames = const Value.absent(),
    this.taxonomyNotes = const Value.absent(),
    this.taxonomyNotesCitation = const Value.absent(),
    this.distributionNotes = const Value.absent(),
    this.distributionNotesCitation = const Value.absent(),
    this.subregionDistribution = const Value.absent(),
    this.countryDistribution = const Value.absent(),
    this.continentDistribution = const Value.absent(),
    this.biogeographicRealm = const Value.absent(),
    this.iucnStatus = const Value.absent(),
    this.extinct = const Value.absent(),
    this.domestic = const Value.absent(),
    this.flagged = const Value.absent(),
    this.cMWSciName = const Value.absent(),
    this.diffSinceCMW = const Value.absent(),
    this.mSW3Matchtype = const Value.absent(),
    this.mSW3SciName = const Value.absent(),
    this.diffSinceMSW3 = const Value.absent(),
  });
  TaxonomyCompanion.insert({
    this.id = const Value.absent(),
    this.phylosort = const Value.absent(),
    this.subclass = const Value.absent(),
    this.infraclass = const Value.absent(),
    this.magnorder = const Value.absent(),
    this.superorder = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.suborder = const Value.absent(),
    this.infraorder = const Value.absent(),
    this.parvorder = const Value.absent(),
    this.superfamily = const Value.absent(),
    this.family = const Value.absent(),
    this.subfamily = const Value.absent(),
    this.tribe = const Value.absent(),
    this.genus = const Value.absent(),
    this.subgenus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.sciName = const Value.absent(),
    this.authoritySpeciesAuthor = const Value.absent(),
    this.authoritySpeciesYear = const Value.absent(),
    this.authorityParentheses = const Value.absent(),
    this.mainCommonName = const Value.absent(),
    this.otherCommonNames = const Value.absent(),
    this.originalNameCombination = const Value.absent(),
    this.authoritySpeciesCitation = const Value.absent(),
    this.authoritySpeciesLink = const Value.absent(),
    this.typeVoucher = const Value.absent(),
    this.typeKind = const Value.absent(),
    this.typeVoucherURIs = const Value.absent(),
    this.typeLocality = const Value.absent(),
    this.typeLocalityLatitude = const Value.absent(),
    this.typeLocalityLongitude = const Value.absent(),
    this.nominalNames = const Value.absent(),
    this.taxonomyNotes = const Value.absent(),
    this.taxonomyNotesCitation = const Value.absent(),
    this.distributionNotes = const Value.absent(),
    this.distributionNotesCitation = const Value.absent(),
    this.subregionDistribution = const Value.absent(),
    this.countryDistribution = const Value.absent(),
    this.continentDistribution = const Value.absent(),
    this.biogeographicRealm = const Value.absent(),
    this.iucnStatus = const Value.absent(),
    this.extinct = const Value.absent(),
    this.domestic = const Value.absent(),
    this.flagged = const Value.absent(),
    this.cMWSciName = const Value.absent(),
    this.diffSinceCMW = const Value.absent(),
    this.mSW3Matchtype = const Value.absent(),
    this.mSW3SciName = const Value.absent(),
    this.diffSinceMSW3 = const Value.absent(),
  });
  static Insertable<TaxonomyData> custom({
    Expression<int>? id,
    Expression<int>? phylosort,
    Expression<String>? subclass,
    Expression<String>? infraclass,
    Expression<String>? magnorder,
    Expression<String>? superorder,
    Expression<String>? taxonOrder,
    Expression<String>? suborder,
    Expression<String>? infraorder,
    Expression<String>? parvorder,
    Expression<String>? superfamily,
    Expression<String>? family,
    Expression<String>? subfamily,
    Expression<String>? tribe,
    Expression<String>? genus,
    Expression<String>? subgenus,
    Expression<String>? specificEpithet,
    Expression<String>? sciName,
    Expression<String>? authoritySpeciesAuthor,
    Expression<int>? authoritySpeciesYear,
    Expression<int>? authorityParentheses,
    Expression<String>? mainCommonName,
    Expression<String>? otherCommonNames,
    Expression<String>? originalNameCombination,
    Expression<String>? authoritySpeciesCitation,
    Expression<String>? authoritySpeciesLink,
    Expression<String>? typeVoucher,
    Expression<String>? typeKind,
    Expression<String>? typeVoucherURIs,
    Expression<String>? typeLocality,
    Expression<String>? typeLocalityLatitude,
    Expression<String>? typeLocalityLongitude,
    Expression<String>? nominalNames,
    Expression<String>? taxonomyNotes,
    Expression<String>? taxonomyNotesCitation,
    Expression<String>? distributionNotes,
    Expression<String>? distributionNotesCitation,
    Expression<String>? subregionDistribution,
    Expression<String>? countryDistribution,
    Expression<String>? continentDistribution,
    Expression<String>? biogeographicRealm,
    Expression<String>? iucnStatus,
    Expression<String>? extinct,
    Expression<String>? domestic,
    Expression<String>? flagged,
    Expression<String>? cMWSciName,
    Expression<String>? diffSinceCMW,
    Expression<String>? mSW3Matchtype,
    Expression<String>? mSW3SciName,
    Expression<String>? diffSinceMSW3,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phylosort != null) 'phylosort': phylosort,
      if (subclass != null) 'subclass': subclass,
      if (infraclass != null) 'infraclass': infraclass,
      if (magnorder != null) 'magnorder': magnorder,
      if (superorder != null) 'superorder': superorder,
      if (taxonOrder != null) 'taxonOrder': taxonOrder,
      if (suborder != null) 'suborder': suborder,
      if (infraorder != null) 'infraorder': infraorder,
      if (parvorder != null) 'parvorder': parvorder,
      if (superfamily != null) 'superfamily': superfamily,
      if (family != null) 'family': family,
      if (subfamily != null) 'subfamily': subfamily,
      if (tribe != null) 'tribe': tribe,
      if (genus != null) 'genus': genus,
      if (subgenus != null) 'subgenus': subgenus,
      if (specificEpithet != null) 'specificEpithet': specificEpithet,
      if (sciName != null) 'sciName': sciName,
      if (authoritySpeciesAuthor != null)
        'authoritySpeciesAuthor': authoritySpeciesAuthor,
      if (authoritySpeciesYear != null)
        'authoritySpeciesYear': authoritySpeciesYear,
      if (authorityParentheses != null)
        'authorityParentheses': authorityParentheses,
      if (mainCommonName != null) 'mainCommonName': mainCommonName,
      if (otherCommonNames != null) 'otherCommonNames': otherCommonNames,
      if (originalNameCombination != null)
        'originalNameCombination': originalNameCombination,
      if (authoritySpeciesCitation != null)
        'authoritySpeciesCitation': authoritySpeciesCitation,
      if (authoritySpeciesLink != null)
        'authoritySpeciesLink': authoritySpeciesLink,
      if (typeVoucher != null) 'typeVoucher': typeVoucher,
      if (typeKind != null) 'typeKind': typeKind,
      if (typeVoucherURIs != null) 'typeVoucherURIs': typeVoucherURIs,
      if (typeLocality != null) 'typeLocality': typeLocality,
      if (typeLocalityLatitude != null)
        'typeLocalityLatitude': typeLocalityLatitude,
      if (typeLocalityLongitude != null)
        'typeLocalityLongitude': typeLocalityLongitude,
      if (nominalNames != null) 'nominalNames': nominalNames,
      if (taxonomyNotes != null) 'taxonomyNotes': taxonomyNotes,
      if (taxonomyNotesCitation != null)
        'taxonomyNotesCitation': taxonomyNotesCitation,
      if (distributionNotes != null) 'distributionNotes': distributionNotes,
      if (distributionNotesCitation != null)
        'distributionNotesCitation': distributionNotesCitation,
      if (subregionDistribution != null)
        'subregionDistribution': subregionDistribution,
      if (countryDistribution != null)
        'countryDistribution': countryDistribution,
      if (continentDistribution != null)
        'continentDistribution': continentDistribution,
      if (biogeographicRealm != null) 'biogeographicRealm': biogeographicRealm,
      if (iucnStatus != null) 'iucnStatus': iucnStatus,
      if (extinct != null) 'extinct': extinct,
      if (domestic != null) 'domestic': domestic,
      if (flagged != null) 'flagged': flagged,
      if (cMWSciName != null) 'CMW_sciName': cMWSciName,
      if (diffSinceCMW != null) 'diffSinceCMW': diffSinceCMW,
      if (mSW3Matchtype != null) 'MSW3_matchtype': mSW3Matchtype,
      if (mSW3SciName != null) 'MSW3_sciName': mSW3SciName,
      if (diffSinceMSW3 != null) 'diffSinceMSW3': diffSinceMSW3,
    });
  }

  TaxonomyCompanion copyWith(
      {Value<int>? id,
      Value<int?>? phylosort,
      Value<String?>? subclass,
      Value<String?>? infraclass,
      Value<String?>? magnorder,
      Value<String?>? superorder,
      Value<String?>? taxonOrder,
      Value<String?>? suborder,
      Value<String?>? infraorder,
      Value<String?>? parvorder,
      Value<String?>? superfamily,
      Value<String?>? family,
      Value<String?>? subfamily,
      Value<String?>? tribe,
      Value<String?>? genus,
      Value<String?>? subgenus,
      Value<String?>? specificEpithet,
      Value<String?>? sciName,
      Value<String?>? authoritySpeciesAuthor,
      Value<int?>? authoritySpeciesYear,
      Value<int?>? authorityParentheses,
      Value<String?>? mainCommonName,
      Value<String?>? otherCommonNames,
      Value<String?>? originalNameCombination,
      Value<String?>? authoritySpeciesCitation,
      Value<String?>? authoritySpeciesLink,
      Value<String?>? typeVoucher,
      Value<String?>? typeKind,
      Value<String?>? typeVoucherURIs,
      Value<String?>? typeLocality,
      Value<String?>? typeLocalityLatitude,
      Value<String?>? typeLocalityLongitude,
      Value<String?>? nominalNames,
      Value<String?>? taxonomyNotes,
      Value<String?>? taxonomyNotesCitation,
      Value<String?>? distributionNotes,
      Value<String?>? distributionNotesCitation,
      Value<String?>? subregionDistribution,
      Value<String?>? countryDistribution,
      Value<String?>? continentDistribution,
      Value<String?>? biogeographicRealm,
      Value<String?>? iucnStatus,
      Value<String?>? extinct,
      Value<String?>? domestic,
      Value<String?>? flagged,
      Value<String?>? cMWSciName,
      Value<String?>? diffSinceCMW,
      Value<String?>? mSW3Matchtype,
      Value<String?>? mSW3SciName,
      Value<String?>? diffSinceMSW3}) {
    return TaxonomyCompanion(
      id: id ?? this.id,
      phylosort: phylosort ?? this.phylosort,
      subclass: subclass ?? this.subclass,
      infraclass: infraclass ?? this.infraclass,
      magnorder: magnorder ?? this.magnorder,
      superorder: superorder ?? this.superorder,
      taxonOrder: taxonOrder ?? this.taxonOrder,
      suborder: suborder ?? this.suborder,
      infraorder: infraorder ?? this.infraorder,
      parvorder: parvorder ?? this.parvorder,
      superfamily: superfamily ?? this.superfamily,
      family: family ?? this.family,
      subfamily: subfamily ?? this.subfamily,
      tribe: tribe ?? this.tribe,
      genus: genus ?? this.genus,
      subgenus: subgenus ?? this.subgenus,
      specificEpithet: specificEpithet ?? this.specificEpithet,
      sciName: sciName ?? this.sciName,
      authoritySpeciesAuthor:
          authoritySpeciesAuthor ?? this.authoritySpeciesAuthor,
      authoritySpeciesYear: authoritySpeciesYear ?? this.authoritySpeciesYear,
      authorityParentheses: authorityParentheses ?? this.authorityParentheses,
      mainCommonName: mainCommonName ?? this.mainCommonName,
      otherCommonNames: otherCommonNames ?? this.otherCommonNames,
      originalNameCombination:
          originalNameCombination ?? this.originalNameCombination,
      authoritySpeciesCitation:
          authoritySpeciesCitation ?? this.authoritySpeciesCitation,
      authoritySpeciesLink: authoritySpeciesLink ?? this.authoritySpeciesLink,
      typeVoucher: typeVoucher ?? this.typeVoucher,
      typeKind: typeKind ?? this.typeKind,
      typeVoucherURIs: typeVoucherURIs ?? this.typeVoucherURIs,
      typeLocality: typeLocality ?? this.typeLocality,
      typeLocalityLatitude: typeLocalityLatitude ?? this.typeLocalityLatitude,
      typeLocalityLongitude:
          typeLocalityLongitude ?? this.typeLocalityLongitude,
      nominalNames: nominalNames ?? this.nominalNames,
      taxonomyNotes: taxonomyNotes ?? this.taxonomyNotes,
      taxonomyNotesCitation:
          taxonomyNotesCitation ?? this.taxonomyNotesCitation,
      distributionNotes: distributionNotes ?? this.distributionNotes,
      distributionNotesCitation:
          distributionNotesCitation ?? this.distributionNotesCitation,
      subregionDistribution:
          subregionDistribution ?? this.subregionDistribution,
      countryDistribution: countryDistribution ?? this.countryDistribution,
      continentDistribution:
          continentDistribution ?? this.continentDistribution,
      biogeographicRealm: biogeographicRealm ?? this.biogeographicRealm,
      iucnStatus: iucnStatus ?? this.iucnStatus,
      extinct: extinct ?? this.extinct,
      domestic: domestic ?? this.domestic,
      flagged: flagged ?? this.flagged,
      cMWSciName: cMWSciName ?? this.cMWSciName,
      diffSinceCMW: diffSinceCMW ?? this.diffSinceCMW,
      mSW3Matchtype: mSW3Matchtype ?? this.mSW3Matchtype,
      mSW3SciName: mSW3SciName ?? this.mSW3SciName,
      diffSinceMSW3: diffSinceMSW3 ?? this.diffSinceMSW3,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phylosort.present) {
      map['phylosort'] = Variable<int>(phylosort.value);
    }
    if (subclass.present) {
      map['subclass'] = Variable<String>(subclass.value);
    }
    if (infraclass.present) {
      map['infraclass'] = Variable<String>(infraclass.value);
    }
    if (magnorder.present) {
      map['magnorder'] = Variable<String>(magnorder.value);
    }
    if (superorder.present) {
      map['superorder'] = Variable<String>(superorder.value);
    }
    if (taxonOrder.present) {
      map['taxonOrder'] = Variable<String>(taxonOrder.value);
    }
    if (suborder.present) {
      map['suborder'] = Variable<String>(suborder.value);
    }
    if (infraorder.present) {
      map['infraorder'] = Variable<String>(infraorder.value);
    }
    if (parvorder.present) {
      map['parvorder'] = Variable<String>(parvorder.value);
    }
    if (superfamily.present) {
      map['superfamily'] = Variable<String>(superfamily.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (subfamily.present) {
      map['subfamily'] = Variable<String>(subfamily.value);
    }
    if (tribe.present) {
      map['tribe'] = Variable<String>(tribe.value);
    }
    if (genus.present) {
      map['genus'] = Variable<String>(genus.value);
    }
    if (subgenus.present) {
      map['subgenus'] = Variable<String>(subgenus.value);
    }
    if (specificEpithet.present) {
      map['specificEpithet'] = Variable<String>(specificEpithet.value);
    }
    if (sciName.present) {
      map['sciName'] = Variable<String>(sciName.value);
    }
    if (authoritySpeciesAuthor.present) {
      map['authoritySpeciesAuthor'] =
          Variable<String>(authoritySpeciesAuthor.value);
    }
    if (authoritySpeciesYear.present) {
      map['authoritySpeciesYear'] = Variable<int>(authoritySpeciesYear.value);
    }
    if (authorityParentheses.present) {
      map['authorityParentheses'] = Variable<int>(authorityParentheses.value);
    }
    if (mainCommonName.present) {
      map['mainCommonName'] = Variable<String>(mainCommonName.value);
    }
    if (otherCommonNames.present) {
      map['otherCommonNames'] = Variable<String>(otherCommonNames.value);
    }
    if (originalNameCombination.present) {
      map['originalNameCombination'] =
          Variable<String>(originalNameCombination.value);
    }
    if (authoritySpeciesCitation.present) {
      map['authoritySpeciesCitation'] =
          Variable<String>(authoritySpeciesCitation.value);
    }
    if (authoritySpeciesLink.present) {
      map['authoritySpeciesLink'] =
          Variable<String>(authoritySpeciesLink.value);
    }
    if (typeVoucher.present) {
      map['typeVoucher'] = Variable<String>(typeVoucher.value);
    }
    if (typeKind.present) {
      map['typeKind'] = Variable<String>(typeKind.value);
    }
    if (typeVoucherURIs.present) {
      map['typeVoucherURIs'] = Variable<String>(typeVoucherURIs.value);
    }
    if (typeLocality.present) {
      map['typeLocality'] = Variable<String>(typeLocality.value);
    }
    if (typeLocalityLatitude.present) {
      map['typeLocalityLatitude'] =
          Variable<String>(typeLocalityLatitude.value);
    }
    if (typeLocalityLongitude.present) {
      map['typeLocalityLongitude'] =
          Variable<String>(typeLocalityLongitude.value);
    }
    if (nominalNames.present) {
      map['nominalNames'] = Variable<String>(nominalNames.value);
    }
    if (taxonomyNotes.present) {
      map['taxonomyNotes'] = Variable<String>(taxonomyNotes.value);
    }
    if (taxonomyNotesCitation.present) {
      map['taxonomyNotesCitation'] =
          Variable<String>(taxonomyNotesCitation.value);
    }
    if (distributionNotes.present) {
      map['distributionNotes'] = Variable<String>(distributionNotes.value);
    }
    if (distributionNotesCitation.present) {
      map['distributionNotesCitation'] =
          Variable<String>(distributionNotesCitation.value);
    }
    if (subregionDistribution.present) {
      map['subregionDistribution'] =
          Variable<String>(subregionDistribution.value);
    }
    if (countryDistribution.present) {
      map['countryDistribution'] = Variable<String>(countryDistribution.value);
    }
    if (continentDistribution.present) {
      map['continentDistribution'] =
          Variable<String>(continentDistribution.value);
    }
    if (biogeographicRealm.present) {
      map['biogeographicRealm'] = Variable<String>(biogeographicRealm.value);
    }
    if (iucnStatus.present) {
      map['iucnStatus'] = Variable<String>(iucnStatus.value);
    }
    if (extinct.present) {
      map['extinct'] = Variable<String>(extinct.value);
    }
    if (domestic.present) {
      map['domestic'] = Variable<String>(domestic.value);
    }
    if (flagged.present) {
      map['flagged'] = Variable<String>(flagged.value);
    }
    if (cMWSciName.present) {
      map['CMW_sciName'] = Variable<String>(cMWSciName.value);
    }
    if (diffSinceCMW.present) {
      map['diffSinceCMW'] = Variable<String>(diffSinceCMW.value);
    }
    if (mSW3Matchtype.present) {
      map['MSW3_matchtype'] = Variable<String>(mSW3Matchtype.value);
    }
    if (mSW3SciName.present) {
      map['MSW3_sciName'] = Variable<String>(mSW3SciName.value);
    }
    if (diffSinceMSW3.present) {
      map['diffSinceMSW3'] = Variable<String>(diffSinceMSW3.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxonomyCompanion(')
          ..write('id: $id, ')
          ..write('phylosort: $phylosort, ')
          ..write('subclass: $subclass, ')
          ..write('infraclass: $infraclass, ')
          ..write('magnorder: $magnorder, ')
          ..write('superorder: $superorder, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('suborder: $suborder, ')
          ..write('infraorder: $infraorder, ')
          ..write('parvorder: $parvorder, ')
          ..write('superfamily: $superfamily, ')
          ..write('family: $family, ')
          ..write('subfamily: $subfamily, ')
          ..write('tribe: $tribe, ')
          ..write('genus: $genus, ')
          ..write('subgenus: $subgenus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('sciName: $sciName, ')
          ..write('authoritySpeciesAuthor: $authoritySpeciesAuthor, ')
          ..write('authoritySpeciesYear: $authoritySpeciesYear, ')
          ..write('authorityParentheses: $authorityParentheses, ')
          ..write('mainCommonName: $mainCommonName, ')
          ..write('otherCommonNames: $otherCommonNames, ')
          ..write('originalNameCombination: $originalNameCombination, ')
          ..write('authoritySpeciesCitation: $authoritySpeciesCitation, ')
          ..write('authoritySpeciesLink: $authoritySpeciesLink, ')
          ..write('typeVoucher: $typeVoucher, ')
          ..write('typeKind: $typeKind, ')
          ..write('typeVoucherURIs: $typeVoucherURIs, ')
          ..write('typeLocality: $typeLocality, ')
          ..write('typeLocalityLatitude: $typeLocalityLatitude, ')
          ..write('typeLocalityLongitude: $typeLocalityLongitude, ')
          ..write('nominalNames: $nominalNames, ')
          ..write('taxonomyNotes: $taxonomyNotes, ')
          ..write('taxonomyNotesCitation: $taxonomyNotesCitation, ')
          ..write('distributionNotes: $distributionNotes, ')
          ..write('distributionNotesCitation: $distributionNotesCitation, ')
          ..write('subregionDistribution: $subregionDistribution, ')
          ..write('countryDistribution: $countryDistribution, ')
          ..write('continentDistribution: $continentDistribution, ')
          ..write('biogeographicRealm: $biogeographicRealm, ')
          ..write('iucnStatus: $iucnStatus, ')
          ..write('extinct: $extinct, ')
          ..write('domestic: $domestic, ')
          ..write('flagged: $flagged, ')
          ..write('cMWSciName: $cMWSciName, ')
          ..write('diffSinceCMW: $diffSinceCMW, ')
          ..write('mSW3Matchtype: $mSW3Matchtype, ')
          ..write('mSW3SciName: $mSW3SciName, ')
          ..write('diffSinceMSW3: $diffSinceMSW3')
          ..write(')'))
        .toString();
  }
}

class Synonym extends Table with TableInfo<Synonym, SynonymData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Synonym(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _synIdMeta = const VerificationMeta('synId');
  late final GeneratedColumn<int> synId = GeneratedColumn<int>(
      'synId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _hespIdMeta = const VerificationMeta('hespId');
  late final GeneratedColumn<int> hespId = GeneratedColumn<int>(
      'hespId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _speciesIdMeta =
      const VerificationMeta('speciesId');
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
      'speciesId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _rootNameMeta =
      const VerificationMeta('rootName');
  late final GeneratedColumn<String> rootName = GeneratedColumn<String>(
      'rootName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
      'year', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityParenthesesMeta =
      const VerificationMeta('authorityParentheses');
  late final GeneratedColumn<int> authorityParentheses = GeneratedColumn<int>(
      'authorityParentheses', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _nomenclatureStatusMeta =
      const VerificationMeta('nomenclatureStatus');
  late final GeneratedColumn<String> nomenclatureStatus =
      GeneratedColumn<String>('nomenclatureStatus', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _validityMeta =
      const VerificationMeta('validity');
  late final GeneratedColumn<String> validity = GeneratedColumn<String>(
      'validity', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _originalCombinationMeta =
      const VerificationMeta('originalCombination');
  late final GeneratedColumn<String> originalCombination =
      GeneratedColumn<String>('originalCombination', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _originalRankMeta =
      const VerificationMeta('originalRank');
  late final GeneratedColumn<String> originalRank = GeneratedColumn<String>(
      'originalRank', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityCitationMeta =
      const VerificationMeta('authorityCitation');
  late final GeneratedColumn<String> authorityCitation =
      GeneratedColumn<String>('authorityCitation', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _uncheckedAuthorityCitationMeta =
      const VerificationMeta('uncheckedAuthorityCitation');
  late final GeneratedColumn<String> uncheckedAuthorityCitation =
      GeneratedColumn<String>('uncheckedAuthorityCitation', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _sourcedUnverifiedCitationsMeta =
      const VerificationMeta('sourcedUnverifiedCitations');
  late final GeneratedColumn<String> sourcedUnverifiedCitations =
      GeneratedColumn<String>('sourcedUnverifiedCitations', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _citationGroupMeta =
      const VerificationMeta('citationGroup');
  late final GeneratedColumn<String> citationGroup = GeneratedColumn<String>(
      'citationGroup', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _citationKindMeta =
      const VerificationMeta('citationKind');
  late final GeneratedColumn<String> citationKind = GeneratedColumn<String>(
      'citationKind', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityPageMeta =
      const VerificationMeta('authorityPage');
  late final GeneratedColumn<String> authorityPage = GeneratedColumn<String>(
      'authorityPage', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityLinkMeta =
      const VerificationMeta('authorityLink');
  late final GeneratedColumn<String> authorityLink = GeneratedColumn<String>(
      'authorityLink', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorityPageLinkMeta =
      const VerificationMeta('authorityPageLink');
  late final GeneratedColumn<String> authorityPageLink =
      GeneratedColumn<String>('authorityPageLink', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _uncheckedAuthorityPageLinkMeta =
      const VerificationMeta('uncheckedAuthorityPageLink');
  late final GeneratedColumn<String> uncheckedAuthorityPageLink =
      GeneratedColumn<String>('uncheckedAuthorityPageLink', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _oldTypeLocalityMeta =
      const VerificationMeta('oldTypeLocality');
  late final GeneratedColumn<String> oldTypeLocality = GeneratedColumn<String>(
      'oldTypeLocality', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _originalTypeLocalityMeta =
      const VerificationMeta('originalTypeLocality');
  late final GeneratedColumn<String> originalTypeLocality =
      GeneratedColumn<String>('originalTypeLocality', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _uncheckedTypeLocalityMeta =
      const VerificationMeta('uncheckedTypeLocality');
  late final GeneratedColumn<String> uncheckedTypeLocality =
      GeneratedColumn<String>('uncheckedTypeLocality', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _emendedTypeLocalityMeta =
      const VerificationMeta('emendedTypeLocality');
  late final GeneratedColumn<String> emendedTypeLocality =
      GeneratedColumn<String>('emendedTypeLocality', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _typeLatitudeMeta =
      const VerificationMeta('typeLatitude');
  late final GeneratedColumn<String> typeLatitude = GeneratedColumn<String>(
      'typeLatitude', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeLongitudeMeta =
      const VerificationMeta('typeLongitude');
  late final GeneratedColumn<String> typeLongitude = GeneratedColumn<String>(
      'typeLongitude', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeCountryMeta =
      const VerificationMeta('typeCountry');
  late final GeneratedColumn<String> typeCountry = GeneratedColumn<String>(
      'typeCountry', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeSubregionMeta =
      const VerificationMeta('typeSubregion');
  late final GeneratedColumn<String> typeSubregion = GeneratedColumn<String>(
      'typeSubregion', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeSubregion2Meta =
      const VerificationMeta('typeSubregion2');
  late final GeneratedColumn<String> typeSubregion2 = GeneratedColumn<String>(
      'typeSubregion2', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _holotypeMeta =
      const VerificationMeta('holotype');
  late final GeneratedColumn<String> holotype = GeneratedColumn<String>(
      'holotype', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeKindMeta =
      const VerificationMeta('typeKind');
  late final GeneratedColumn<String> typeKind = GeneratedColumn<String>(
      'typeKind', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeSpecimenLinkMeta =
      const VerificationMeta('typeSpecimenLink');
  late final GeneratedColumn<String> typeSpecimenLink = GeneratedColumn<String>(
      'typeSpecimenLink', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonOrderMeta =
      const VerificationMeta('taxonOrder');
  late final GeneratedColumn<String> taxonOrder = GeneratedColumn<String>(
      'taxonOrder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
      'family', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _genusMeta = const VerificationMeta('genus');
  late final GeneratedColumn<String> genus = GeneratedColumn<String>(
      'genus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _specificEpithetMeta =
      const VerificationMeta('specificEpithet');
  late final GeneratedColumn<String> specificEpithet = GeneratedColumn<String>(
      'specificEpithet', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _subspecificEpithetMeta =
      const VerificationMeta('subspecificEpithet');
  late final GeneratedColumn<String> subspecificEpithet =
      GeneratedColumn<String>('subspecificEpithet', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _variantOfMeta =
      const VerificationMeta('variantOf');
  late final GeneratedColumn<String> variantOf = GeneratedColumn<String>(
      'variantOf', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _seniorHomonymMeta =
      const VerificationMeta('seniorHomonym');
  late final GeneratedColumn<String> seniorHomonym = GeneratedColumn<String>(
      'seniorHomonym', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _variantNameCitationsMeta =
      const VerificationMeta('variantNameCitations');
  late final GeneratedColumn<String> variantNameCitations =
      GeneratedColumn<String>('variantNameCitations', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _nameUsagesMeta =
      const VerificationMeta('nameUsages');
  late final GeneratedColumn<String> nameUsages = GeneratedColumn<String>(
      'nameUsages', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _commentsMeta =
      const VerificationMeta('comments');
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
      'comments', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        synId,
        hespId,
        speciesId,
        species,
        rootName,
        author,
        year,
        authorityParentheses,
        nomenclatureStatus,
        validity,
        originalCombination,
        originalRank,
        authorityCitation,
        uncheckedAuthorityCitation,
        sourcedUnverifiedCitations,
        citationGroup,
        citationKind,
        authorityPage,
        authorityLink,
        authorityPageLink,
        uncheckedAuthorityPageLink,
        oldTypeLocality,
        originalTypeLocality,
        uncheckedTypeLocality,
        emendedTypeLocality,
        typeLatitude,
        typeLongitude,
        typeCountry,
        typeSubregion,
        typeSubregion2,
        holotype,
        typeKind,
        typeSpecimenLink,
        taxonOrder,
        family,
        genus,
        specificEpithet,
        subspecificEpithet,
        variantOf,
        seniorHomonym,
        variantNameCitations,
        nameUsages,
        comments
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'synonym';
  @override
  VerificationContext validateIntegrity(Insertable<SynonymData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('synId')) {
      context.handle(
          _synIdMeta, synId.isAcceptableOrUnknown(data['synId']!, _synIdMeta));
    }
    if (data.containsKey('hespId')) {
      context.handle(_hespIdMeta,
          hespId.isAcceptableOrUnknown(data['hespId']!, _hespIdMeta));
    }
    if (data.containsKey('speciesId')) {
      context.handle(_speciesIdMeta,
          speciesId.isAcceptableOrUnknown(data['speciesId']!, _speciesIdMeta));
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    }
    if (data.containsKey('rootName')) {
      context.handle(_rootNameMeta,
          rootName.isAcceptableOrUnknown(data['rootName']!, _rootNameMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('authorityParentheses')) {
      context.handle(
          _authorityParenthesesMeta,
          authorityParentheses.isAcceptableOrUnknown(
              data['authorityParentheses']!, _authorityParenthesesMeta));
    }
    if (data.containsKey('nomenclatureStatus')) {
      context.handle(
          _nomenclatureStatusMeta,
          nomenclatureStatus.isAcceptableOrUnknown(
              data['nomenclatureStatus']!, _nomenclatureStatusMeta));
    }
    if (data.containsKey('validity')) {
      context.handle(_validityMeta,
          validity.isAcceptableOrUnknown(data['validity']!, _validityMeta));
    }
    if (data.containsKey('originalCombination')) {
      context.handle(
          _originalCombinationMeta,
          originalCombination.isAcceptableOrUnknown(
              data['originalCombination']!, _originalCombinationMeta));
    }
    if (data.containsKey('originalRank')) {
      context.handle(
          _originalRankMeta,
          originalRank.isAcceptableOrUnknown(
              data['originalRank']!, _originalRankMeta));
    }
    if (data.containsKey('authorityCitation')) {
      context.handle(
          _authorityCitationMeta,
          authorityCitation.isAcceptableOrUnknown(
              data['authorityCitation']!, _authorityCitationMeta));
    }
    if (data.containsKey('uncheckedAuthorityCitation')) {
      context.handle(
          _uncheckedAuthorityCitationMeta,
          uncheckedAuthorityCitation.isAcceptableOrUnknown(
              data['uncheckedAuthorityCitation']!,
              _uncheckedAuthorityCitationMeta));
    }
    if (data.containsKey('sourcedUnverifiedCitations')) {
      context.handle(
          _sourcedUnverifiedCitationsMeta,
          sourcedUnverifiedCitations.isAcceptableOrUnknown(
              data['sourcedUnverifiedCitations']!,
              _sourcedUnverifiedCitationsMeta));
    }
    if (data.containsKey('citationGroup')) {
      context.handle(
          _citationGroupMeta,
          citationGroup.isAcceptableOrUnknown(
              data['citationGroup']!, _citationGroupMeta));
    }
    if (data.containsKey('citationKind')) {
      context.handle(
          _citationKindMeta,
          citationKind.isAcceptableOrUnknown(
              data['citationKind']!, _citationKindMeta));
    }
    if (data.containsKey('authorityPage')) {
      context.handle(
          _authorityPageMeta,
          authorityPage.isAcceptableOrUnknown(
              data['authorityPage']!, _authorityPageMeta));
    }
    if (data.containsKey('authorityLink')) {
      context.handle(
          _authorityLinkMeta,
          authorityLink.isAcceptableOrUnknown(
              data['authorityLink']!, _authorityLinkMeta));
    }
    if (data.containsKey('authorityPageLink')) {
      context.handle(
          _authorityPageLinkMeta,
          authorityPageLink.isAcceptableOrUnknown(
              data['authorityPageLink']!, _authorityPageLinkMeta));
    }
    if (data.containsKey('uncheckedAuthorityPageLink')) {
      context.handle(
          _uncheckedAuthorityPageLinkMeta,
          uncheckedAuthorityPageLink.isAcceptableOrUnknown(
              data['uncheckedAuthorityPageLink']!,
              _uncheckedAuthorityPageLinkMeta));
    }
    if (data.containsKey('oldTypeLocality')) {
      context.handle(
          _oldTypeLocalityMeta,
          oldTypeLocality.isAcceptableOrUnknown(
              data['oldTypeLocality']!, _oldTypeLocalityMeta));
    }
    if (data.containsKey('originalTypeLocality')) {
      context.handle(
          _originalTypeLocalityMeta,
          originalTypeLocality.isAcceptableOrUnknown(
              data['originalTypeLocality']!, _originalTypeLocalityMeta));
    }
    if (data.containsKey('uncheckedTypeLocality')) {
      context.handle(
          _uncheckedTypeLocalityMeta,
          uncheckedTypeLocality.isAcceptableOrUnknown(
              data['uncheckedTypeLocality']!, _uncheckedTypeLocalityMeta));
    }
    if (data.containsKey('emendedTypeLocality')) {
      context.handle(
          _emendedTypeLocalityMeta,
          emendedTypeLocality.isAcceptableOrUnknown(
              data['emendedTypeLocality']!, _emendedTypeLocalityMeta));
    }
    if (data.containsKey('typeLatitude')) {
      context.handle(
          _typeLatitudeMeta,
          typeLatitude.isAcceptableOrUnknown(
              data['typeLatitude']!, _typeLatitudeMeta));
    }
    if (data.containsKey('typeLongitude')) {
      context.handle(
          _typeLongitudeMeta,
          typeLongitude.isAcceptableOrUnknown(
              data['typeLongitude']!, _typeLongitudeMeta));
    }
    if (data.containsKey('typeCountry')) {
      context.handle(
          _typeCountryMeta,
          typeCountry.isAcceptableOrUnknown(
              data['typeCountry']!, _typeCountryMeta));
    }
    if (data.containsKey('typeSubregion')) {
      context.handle(
          _typeSubregionMeta,
          typeSubregion.isAcceptableOrUnknown(
              data['typeSubregion']!, _typeSubregionMeta));
    }
    if (data.containsKey('typeSubregion2')) {
      context.handle(
          _typeSubregion2Meta,
          typeSubregion2.isAcceptableOrUnknown(
              data['typeSubregion2']!, _typeSubregion2Meta));
    }
    if (data.containsKey('holotype')) {
      context.handle(_holotypeMeta,
          holotype.isAcceptableOrUnknown(data['holotype']!, _holotypeMeta));
    }
    if (data.containsKey('typeKind')) {
      context.handle(_typeKindMeta,
          typeKind.isAcceptableOrUnknown(data['typeKind']!, _typeKindMeta));
    }
    if (data.containsKey('typeSpecimenLink')) {
      context.handle(
          _typeSpecimenLinkMeta,
          typeSpecimenLink.isAcceptableOrUnknown(
              data['typeSpecimenLink']!, _typeSpecimenLinkMeta));
    }
    if (data.containsKey('taxonOrder')) {
      context.handle(
          _taxonOrderMeta,
          taxonOrder.isAcceptableOrUnknown(
              data['taxonOrder']!, _taxonOrderMeta));
    }
    if (data.containsKey('family')) {
      context.handle(_familyMeta,
          family.isAcceptableOrUnknown(data['family']!, _familyMeta));
    }
    if (data.containsKey('genus')) {
      context.handle(
          _genusMeta, genus.isAcceptableOrUnknown(data['genus']!, _genusMeta));
    }
    if (data.containsKey('specificEpithet')) {
      context.handle(
          _specificEpithetMeta,
          specificEpithet.isAcceptableOrUnknown(
              data['specificEpithet']!, _specificEpithetMeta));
    }
    if (data.containsKey('subspecificEpithet')) {
      context.handle(
          _subspecificEpithetMeta,
          subspecificEpithet.isAcceptableOrUnknown(
              data['subspecificEpithet']!, _subspecificEpithetMeta));
    }
    if (data.containsKey('variantOf')) {
      context.handle(_variantOfMeta,
          variantOf.isAcceptableOrUnknown(data['variantOf']!, _variantOfMeta));
    }
    if (data.containsKey('seniorHomonym')) {
      context.handle(
          _seniorHomonymMeta,
          seniorHomonym.isAcceptableOrUnknown(
              data['seniorHomonym']!, _seniorHomonymMeta));
    }
    if (data.containsKey('variantNameCitations')) {
      context.handle(
          _variantNameCitationsMeta,
          variantNameCitations.isAcceptableOrUnknown(
              data['variantNameCitations']!, _variantNameCitationsMeta));
    }
    if (data.containsKey('nameUsages')) {
      context.handle(
          _nameUsagesMeta,
          nameUsages.isAcceptableOrUnknown(
              data['nameUsages']!, _nameUsagesMeta));
    }
    if (data.containsKey('comments')) {
      context.handle(_commentsMeta,
          comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SynonymData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SynonymData(
      synId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synId']),
      hespId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hespId']),
      speciesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speciesId']),
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species']),
      rootName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rootName']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}year']),
      authorityParentheses: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}authorityParentheses']),
      nomenclatureStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nomenclatureStatus']),
      validity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}validity']),
      originalCombination: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}originalCombination']),
      originalRank: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}originalRank']),
      authorityCitation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorityCitation']),
      uncheckedAuthorityCitation: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}uncheckedAuthorityCitation']),
      sourcedUnverifiedCitations: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sourcedUnverifiedCitations']),
      citationGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}citationGroup']),
      citationKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}citationKind']),
      authorityPage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}authorityPage']),
      authorityLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}authorityLink']),
      authorityPageLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorityPageLink']),
      uncheckedAuthorityPageLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}uncheckedAuthorityPageLink']),
      oldTypeLocality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oldTypeLocality']),
      originalTypeLocality: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}originalTypeLocality']),
      uncheckedTypeLocality: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}uncheckedTypeLocality']),
      emendedTypeLocality: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}emendedTypeLocality']),
      typeLatitude: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeLatitude']),
      typeLongitude: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeLongitude']),
      typeCountry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeCountry']),
      typeSubregion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeSubregion']),
      typeSubregion2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeSubregion2']),
      holotype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}holotype']),
      typeKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}typeKind']),
      typeSpecimenLink: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}typeSpecimenLink']),
      taxonOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonOrder']),
      family: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family']),
      genus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genus']),
      specificEpithet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specificEpithet']),
      subspecificEpithet: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subspecificEpithet']),
      variantOf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variantOf']),
      seniorHomonym: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seniorHomonym']),
      variantNameCitations: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}variantNameCitations']),
      nameUsages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nameUsages']),
      comments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comments']),
    );
  }

  @override
  Synonym createAlias(String alias) {
    return Synonym(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SynonymData extends DataClass implements Insertable<SynonymData> {
  final int? synId;
  final int? hespId;
  final int? speciesId;
  final String? species;
  final String? rootName;
  final String? author;
  final String? year;
  final int? authorityParentheses;
  final String? nomenclatureStatus;
  final String? validity;
  final String? originalCombination;
  final String? originalRank;
  final String? authorityCitation;
  final String? uncheckedAuthorityCitation;
  final String? sourcedUnverifiedCitations;
  final String? citationGroup;
  final String? citationKind;
  final String? authorityPage;
  final String? authorityLink;
  final String? authorityPageLink;
  final String? uncheckedAuthorityPageLink;
  final String? oldTypeLocality;
  final String? originalTypeLocality;
  final String? uncheckedTypeLocality;
  final String? emendedTypeLocality;
  final String? typeLatitude;
  final String? typeLongitude;
  final String? typeCountry;
  final String? typeSubregion;
  final String? typeSubregion2;
  final String? holotype;
  final String? typeKind;
  final String? typeSpecimenLink;
  final String? taxonOrder;
  final String? family;
  final String? genus;
  final String? specificEpithet;
  final String? subspecificEpithet;
  final String? variantOf;
  final String? seniorHomonym;
  final String? variantNameCitations;
  final String? nameUsages;
  final String? comments;
  const SynonymData(
      {this.synId,
      this.hespId,
      this.speciesId,
      this.species,
      this.rootName,
      this.author,
      this.year,
      this.authorityParentheses,
      this.nomenclatureStatus,
      this.validity,
      this.originalCombination,
      this.originalRank,
      this.authorityCitation,
      this.uncheckedAuthorityCitation,
      this.sourcedUnverifiedCitations,
      this.citationGroup,
      this.citationKind,
      this.authorityPage,
      this.authorityLink,
      this.authorityPageLink,
      this.uncheckedAuthorityPageLink,
      this.oldTypeLocality,
      this.originalTypeLocality,
      this.uncheckedTypeLocality,
      this.emendedTypeLocality,
      this.typeLatitude,
      this.typeLongitude,
      this.typeCountry,
      this.typeSubregion,
      this.typeSubregion2,
      this.holotype,
      this.typeKind,
      this.typeSpecimenLink,
      this.taxonOrder,
      this.family,
      this.genus,
      this.specificEpithet,
      this.subspecificEpithet,
      this.variantOf,
      this.seniorHomonym,
      this.variantNameCitations,
      this.nameUsages,
      this.comments});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || synId != null) {
      map['synId'] = Variable<int>(synId);
    }
    if (!nullToAbsent || hespId != null) {
      map['hespId'] = Variable<int>(hespId);
    }
    if (!nullToAbsent || speciesId != null) {
      map['speciesId'] = Variable<int>(speciesId);
    }
    if (!nullToAbsent || species != null) {
      map['species'] = Variable<String>(species);
    }
    if (!nullToAbsent || rootName != null) {
      map['rootName'] = Variable<String>(rootName);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || authorityParentheses != null) {
      map['authorityParentheses'] = Variable<int>(authorityParentheses);
    }
    if (!nullToAbsent || nomenclatureStatus != null) {
      map['nomenclatureStatus'] = Variable<String>(nomenclatureStatus);
    }
    if (!nullToAbsent || validity != null) {
      map['validity'] = Variable<String>(validity);
    }
    if (!nullToAbsent || originalCombination != null) {
      map['originalCombination'] = Variable<String>(originalCombination);
    }
    if (!nullToAbsent || originalRank != null) {
      map['originalRank'] = Variable<String>(originalRank);
    }
    if (!nullToAbsent || authorityCitation != null) {
      map['authorityCitation'] = Variable<String>(authorityCitation);
    }
    if (!nullToAbsent || uncheckedAuthorityCitation != null) {
      map['uncheckedAuthorityCitation'] =
          Variable<String>(uncheckedAuthorityCitation);
    }
    if (!nullToAbsent || sourcedUnverifiedCitations != null) {
      map['sourcedUnverifiedCitations'] =
          Variable<String>(sourcedUnverifiedCitations);
    }
    if (!nullToAbsent || citationGroup != null) {
      map['citationGroup'] = Variable<String>(citationGroup);
    }
    if (!nullToAbsent || citationKind != null) {
      map['citationKind'] = Variable<String>(citationKind);
    }
    if (!nullToAbsent || authorityPage != null) {
      map['authorityPage'] = Variable<String>(authorityPage);
    }
    if (!nullToAbsent || authorityLink != null) {
      map['authorityLink'] = Variable<String>(authorityLink);
    }
    if (!nullToAbsent || authorityPageLink != null) {
      map['authorityPageLink'] = Variable<String>(authorityPageLink);
    }
    if (!nullToAbsent || uncheckedAuthorityPageLink != null) {
      map['uncheckedAuthorityPageLink'] =
          Variable<String>(uncheckedAuthorityPageLink);
    }
    if (!nullToAbsent || oldTypeLocality != null) {
      map['oldTypeLocality'] = Variable<String>(oldTypeLocality);
    }
    if (!nullToAbsent || originalTypeLocality != null) {
      map['originalTypeLocality'] = Variable<String>(originalTypeLocality);
    }
    if (!nullToAbsent || uncheckedTypeLocality != null) {
      map['uncheckedTypeLocality'] = Variable<String>(uncheckedTypeLocality);
    }
    if (!nullToAbsent || emendedTypeLocality != null) {
      map['emendedTypeLocality'] = Variable<String>(emendedTypeLocality);
    }
    if (!nullToAbsent || typeLatitude != null) {
      map['typeLatitude'] = Variable<String>(typeLatitude);
    }
    if (!nullToAbsent || typeLongitude != null) {
      map['typeLongitude'] = Variable<String>(typeLongitude);
    }
    if (!nullToAbsent || typeCountry != null) {
      map['typeCountry'] = Variable<String>(typeCountry);
    }
    if (!nullToAbsent || typeSubregion != null) {
      map['typeSubregion'] = Variable<String>(typeSubregion);
    }
    if (!nullToAbsent || typeSubregion2 != null) {
      map['typeSubregion2'] = Variable<String>(typeSubregion2);
    }
    if (!nullToAbsent || holotype != null) {
      map['holotype'] = Variable<String>(holotype);
    }
    if (!nullToAbsent || typeKind != null) {
      map['typeKind'] = Variable<String>(typeKind);
    }
    if (!nullToAbsent || typeSpecimenLink != null) {
      map['typeSpecimenLink'] = Variable<String>(typeSpecimenLink);
    }
    if (!nullToAbsent || taxonOrder != null) {
      map['taxonOrder'] = Variable<String>(taxonOrder);
    }
    if (!nullToAbsent || family != null) {
      map['family'] = Variable<String>(family);
    }
    if (!nullToAbsent || genus != null) {
      map['genus'] = Variable<String>(genus);
    }
    if (!nullToAbsent || specificEpithet != null) {
      map['specificEpithet'] = Variable<String>(specificEpithet);
    }
    if (!nullToAbsent || subspecificEpithet != null) {
      map['subspecificEpithet'] = Variable<String>(subspecificEpithet);
    }
    if (!nullToAbsent || variantOf != null) {
      map['variantOf'] = Variable<String>(variantOf);
    }
    if (!nullToAbsent || seniorHomonym != null) {
      map['seniorHomonym'] = Variable<String>(seniorHomonym);
    }
    if (!nullToAbsent || variantNameCitations != null) {
      map['variantNameCitations'] = Variable<String>(variantNameCitations);
    }
    if (!nullToAbsent || nameUsages != null) {
      map['nameUsages'] = Variable<String>(nameUsages);
    }
    if (!nullToAbsent || comments != null) {
      map['comments'] = Variable<String>(comments);
    }
    return map;
  }

  SynonymCompanion toCompanion(bool nullToAbsent) {
    return SynonymCompanion(
      synId:
          synId == null && nullToAbsent ? const Value.absent() : Value(synId),
      hespId:
          hespId == null && nullToAbsent ? const Value.absent() : Value(hespId),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      species: species == null && nullToAbsent
          ? const Value.absent()
          : Value(species),
      rootName: rootName == null && nullToAbsent
          ? const Value.absent()
          : Value(rootName),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      authorityParentheses: authorityParentheses == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityParentheses),
      nomenclatureStatus: nomenclatureStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(nomenclatureStatus),
      validity: validity == null && nullToAbsent
          ? const Value.absent()
          : Value(validity),
      originalCombination: originalCombination == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCombination),
      originalRank: originalRank == null && nullToAbsent
          ? const Value.absent()
          : Value(originalRank),
      authorityCitation: authorityCitation == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityCitation),
      uncheckedAuthorityCitation:
          uncheckedAuthorityCitation == null && nullToAbsent
              ? const Value.absent()
              : Value(uncheckedAuthorityCitation),
      sourcedUnverifiedCitations:
          sourcedUnverifiedCitations == null && nullToAbsent
              ? const Value.absent()
              : Value(sourcedUnverifiedCitations),
      citationGroup: citationGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(citationGroup),
      citationKind: citationKind == null && nullToAbsent
          ? const Value.absent()
          : Value(citationKind),
      authorityPage: authorityPage == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityPage),
      authorityLink: authorityLink == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityLink),
      authorityPageLink: authorityPageLink == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityPageLink),
      uncheckedAuthorityPageLink:
          uncheckedAuthorityPageLink == null && nullToAbsent
              ? const Value.absent()
              : Value(uncheckedAuthorityPageLink),
      oldTypeLocality: oldTypeLocality == null && nullToAbsent
          ? const Value.absent()
          : Value(oldTypeLocality),
      originalTypeLocality: originalTypeLocality == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTypeLocality),
      uncheckedTypeLocality: uncheckedTypeLocality == null && nullToAbsent
          ? const Value.absent()
          : Value(uncheckedTypeLocality),
      emendedTypeLocality: emendedTypeLocality == null && nullToAbsent
          ? const Value.absent()
          : Value(emendedTypeLocality),
      typeLatitude: typeLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLatitude),
      typeLongitude: typeLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLongitude),
      typeCountry: typeCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(typeCountry),
      typeSubregion: typeSubregion == null && nullToAbsent
          ? const Value.absent()
          : Value(typeSubregion),
      typeSubregion2: typeSubregion2 == null && nullToAbsent
          ? const Value.absent()
          : Value(typeSubregion2),
      holotype: holotype == null && nullToAbsent
          ? const Value.absent()
          : Value(holotype),
      typeKind: typeKind == null && nullToAbsent
          ? const Value.absent()
          : Value(typeKind),
      typeSpecimenLink: typeSpecimenLink == null && nullToAbsent
          ? const Value.absent()
          : Value(typeSpecimenLink),
      taxonOrder: taxonOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonOrder),
      family:
          family == null && nullToAbsent ? const Value.absent() : Value(family),
      genus:
          genus == null && nullToAbsent ? const Value.absent() : Value(genus),
      specificEpithet: specificEpithet == null && nullToAbsent
          ? const Value.absent()
          : Value(specificEpithet),
      subspecificEpithet: subspecificEpithet == null && nullToAbsent
          ? const Value.absent()
          : Value(subspecificEpithet),
      variantOf: variantOf == null && nullToAbsent
          ? const Value.absent()
          : Value(variantOf),
      seniorHomonym: seniorHomonym == null && nullToAbsent
          ? const Value.absent()
          : Value(seniorHomonym),
      variantNameCitations: variantNameCitations == null && nullToAbsent
          ? const Value.absent()
          : Value(variantNameCitations),
      nameUsages: nameUsages == null && nullToAbsent
          ? const Value.absent()
          : Value(nameUsages),
      comments: comments == null && nullToAbsent
          ? const Value.absent()
          : Value(comments),
    );
  }

  factory SynonymData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SynonymData(
      synId: serializer.fromJson<int?>(json['synId']),
      hespId: serializer.fromJson<int?>(json['hespId']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      species: serializer.fromJson<String?>(json['species']),
      rootName: serializer.fromJson<String?>(json['rootName']),
      author: serializer.fromJson<String?>(json['author']),
      year: serializer.fromJson<String?>(json['year']),
      authorityParentheses:
          serializer.fromJson<int?>(json['authorityParentheses']),
      nomenclatureStatus:
          serializer.fromJson<String?>(json['nomenclatureStatus']),
      validity: serializer.fromJson<String?>(json['validity']),
      originalCombination:
          serializer.fromJson<String?>(json['originalCombination']),
      originalRank: serializer.fromJson<String?>(json['originalRank']),
      authorityCitation:
          serializer.fromJson<String?>(json['authorityCitation']),
      uncheckedAuthorityCitation:
          serializer.fromJson<String?>(json['uncheckedAuthorityCitation']),
      sourcedUnverifiedCitations:
          serializer.fromJson<String?>(json['sourcedUnverifiedCitations']),
      citationGroup: serializer.fromJson<String?>(json['citationGroup']),
      citationKind: serializer.fromJson<String?>(json['citationKind']),
      authorityPage: serializer.fromJson<String?>(json['authorityPage']),
      authorityLink: serializer.fromJson<String?>(json['authorityLink']),
      authorityPageLink:
          serializer.fromJson<String?>(json['authorityPageLink']),
      uncheckedAuthorityPageLink:
          serializer.fromJson<String?>(json['uncheckedAuthorityPageLink']),
      oldTypeLocality: serializer.fromJson<String?>(json['oldTypeLocality']),
      originalTypeLocality:
          serializer.fromJson<String?>(json['originalTypeLocality']),
      uncheckedTypeLocality:
          serializer.fromJson<String?>(json['uncheckedTypeLocality']),
      emendedTypeLocality:
          serializer.fromJson<String?>(json['emendedTypeLocality']),
      typeLatitude: serializer.fromJson<String?>(json['typeLatitude']),
      typeLongitude: serializer.fromJson<String?>(json['typeLongitude']),
      typeCountry: serializer.fromJson<String?>(json['typeCountry']),
      typeSubregion: serializer.fromJson<String?>(json['typeSubregion']),
      typeSubregion2: serializer.fromJson<String?>(json['typeSubregion2']),
      holotype: serializer.fromJson<String?>(json['holotype']),
      typeKind: serializer.fromJson<String?>(json['typeKind']),
      typeSpecimenLink: serializer.fromJson<String?>(json['typeSpecimenLink']),
      taxonOrder: serializer.fromJson<String?>(json['taxonOrder']),
      family: serializer.fromJson<String?>(json['family']),
      genus: serializer.fromJson<String?>(json['genus']),
      specificEpithet: serializer.fromJson<String?>(json['specificEpithet']),
      subspecificEpithet:
          serializer.fromJson<String?>(json['subspecificEpithet']),
      variantOf: serializer.fromJson<String?>(json['variantOf']),
      seniorHomonym: serializer.fromJson<String?>(json['seniorHomonym']),
      variantNameCitations:
          serializer.fromJson<String?>(json['variantNameCitations']),
      nameUsages: serializer.fromJson<String?>(json['nameUsages']),
      comments: serializer.fromJson<String?>(json['comments']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'synId': serializer.toJson<int?>(synId),
      'hespId': serializer.toJson<int?>(hespId),
      'speciesId': serializer.toJson<int?>(speciesId),
      'species': serializer.toJson<String?>(species),
      'rootName': serializer.toJson<String?>(rootName),
      'author': serializer.toJson<String?>(author),
      'year': serializer.toJson<String?>(year),
      'authorityParentheses': serializer.toJson<int?>(authorityParentheses),
      'nomenclatureStatus': serializer.toJson<String?>(nomenclatureStatus),
      'validity': serializer.toJson<String?>(validity),
      'originalCombination': serializer.toJson<String?>(originalCombination),
      'originalRank': serializer.toJson<String?>(originalRank),
      'authorityCitation': serializer.toJson<String?>(authorityCitation),
      'uncheckedAuthorityCitation':
          serializer.toJson<String?>(uncheckedAuthorityCitation),
      'sourcedUnverifiedCitations':
          serializer.toJson<String?>(sourcedUnverifiedCitations),
      'citationGroup': serializer.toJson<String?>(citationGroup),
      'citationKind': serializer.toJson<String?>(citationKind),
      'authorityPage': serializer.toJson<String?>(authorityPage),
      'authorityLink': serializer.toJson<String?>(authorityLink),
      'authorityPageLink': serializer.toJson<String?>(authorityPageLink),
      'uncheckedAuthorityPageLink':
          serializer.toJson<String?>(uncheckedAuthorityPageLink),
      'oldTypeLocality': serializer.toJson<String?>(oldTypeLocality),
      'originalTypeLocality': serializer.toJson<String?>(originalTypeLocality),
      'uncheckedTypeLocality':
          serializer.toJson<String?>(uncheckedTypeLocality),
      'emendedTypeLocality': serializer.toJson<String?>(emendedTypeLocality),
      'typeLatitude': serializer.toJson<String?>(typeLatitude),
      'typeLongitude': serializer.toJson<String?>(typeLongitude),
      'typeCountry': serializer.toJson<String?>(typeCountry),
      'typeSubregion': serializer.toJson<String?>(typeSubregion),
      'typeSubregion2': serializer.toJson<String?>(typeSubregion2),
      'holotype': serializer.toJson<String?>(holotype),
      'typeKind': serializer.toJson<String?>(typeKind),
      'typeSpecimenLink': serializer.toJson<String?>(typeSpecimenLink),
      'taxonOrder': serializer.toJson<String?>(taxonOrder),
      'family': serializer.toJson<String?>(family),
      'genus': serializer.toJson<String?>(genus),
      'specificEpithet': serializer.toJson<String?>(specificEpithet),
      'subspecificEpithet': serializer.toJson<String?>(subspecificEpithet),
      'variantOf': serializer.toJson<String?>(variantOf),
      'seniorHomonym': serializer.toJson<String?>(seniorHomonym),
      'variantNameCitations': serializer.toJson<String?>(variantNameCitations),
      'nameUsages': serializer.toJson<String?>(nameUsages),
      'comments': serializer.toJson<String?>(comments),
    };
  }

  SynonymData copyWith(
          {Value<int?> synId = const Value.absent(),
          Value<int?> hespId = const Value.absent(),
          Value<int?> speciesId = const Value.absent(),
          Value<String?> species = const Value.absent(),
          Value<String?> rootName = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> year = const Value.absent(),
          Value<int?> authorityParentheses = const Value.absent(),
          Value<String?> nomenclatureStatus = const Value.absent(),
          Value<String?> validity = const Value.absent(),
          Value<String?> originalCombination = const Value.absent(),
          Value<String?> originalRank = const Value.absent(),
          Value<String?> authorityCitation = const Value.absent(),
          Value<String?> uncheckedAuthorityCitation = const Value.absent(),
          Value<String?> sourcedUnverifiedCitations = const Value.absent(),
          Value<String?> citationGroup = const Value.absent(),
          Value<String?> citationKind = const Value.absent(),
          Value<String?> authorityPage = const Value.absent(),
          Value<String?> authorityLink = const Value.absent(),
          Value<String?> authorityPageLink = const Value.absent(),
          Value<String?> uncheckedAuthorityPageLink = const Value.absent(),
          Value<String?> oldTypeLocality = const Value.absent(),
          Value<String?> originalTypeLocality = const Value.absent(),
          Value<String?> uncheckedTypeLocality = const Value.absent(),
          Value<String?> emendedTypeLocality = const Value.absent(),
          Value<String?> typeLatitude = const Value.absent(),
          Value<String?> typeLongitude = const Value.absent(),
          Value<String?> typeCountry = const Value.absent(),
          Value<String?> typeSubregion = const Value.absent(),
          Value<String?> typeSubregion2 = const Value.absent(),
          Value<String?> holotype = const Value.absent(),
          Value<String?> typeKind = const Value.absent(),
          Value<String?> typeSpecimenLink = const Value.absent(),
          Value<String?> taxonOrder = const Value.absent(),
          Value<String?> family = const Value.absent(),
          Value<String?> genus = const Value.absent(),
          Value<String?> specificEpithet = const Value.absent(),
          Value<String?> subspecificEpithet = const Value.absent(),
          Value<String?> variantOf = const Value.absent(),
          Value<String?> seniorHomonym = const Value.absent(),
          Value<String?> variantNameCitations = const Value.absent(),
          Value<String?> nameUsages = const Value.absent(),
          Value<String?> comments = const Value.absent()}) =>
      SynonymData(
        synId: synId.present ? synId.value : this.synId,
        hespId: hespId.present ? hespId.value : this.hespId,
        speciesId: speciesId.present ? speciesId.value : this.speciesId,
        species: species.present ? species.value : this.species,
        rootName: rootName.present ? rootName.value : this.rootName,
        author: author.present ? author.value : this.author,
        year: year.present ? year.value : this.year,
        authorityParentheses: authorityParentheses.present
            ? authorityParentheses.value
            : this.authorityParentheses,
        nomenclatureStatus: nomenclatureStatus.present
            ? nomenclatureStatus.value
            : this.nomenclatureStatus,
        validity: validity.present ? validity.value : this.validity,
        originalCombination: originalCombination.present
            ? originalCombination.value
            : this.originalCombination,
        originalRank:
            originalRank.present ? originalRank.value : this.originalRank,
        authorityCitation: authorityCitation.present
            ? authorityCitation.value
            : this.authorityCitation,
        uncheckedAuthorityCitation: uncheckedAuthorityCitation.present
            ? uncheckedAuthorityCitation.value
            : this.uncheckedAuthorityCitation,
        sourcedUnverifiedCitations: sourcedUnverifiedCitations.present
            ? sourcedUnverifiedCitations.value
            : this.sourcedUnverifiedCitations,
        citationGroup:
            citationGroup.present ? citationGroup.value : this.citationGroup,
        citationKind:
            citationKind.present ? citationKind.value : this.citationKind,
        authorityPage:
            authorityPage.present ? authorityPage.value : this.authorityPage,
        authorityLink:
            authorityLink.present ? authorityLink.value : this.authorityLink,
        authorityPageLink: authorityPageLink.present
            ? authorityPageLink.value
            : this.authorityPageLink,
        uncheckedAuthorityPageLink: uncheckedAuthorityPageLink.present
            ? uncheckedAuthorityPageLink.value
            : this.uncheckedAuthorityPageLink,
        oldTypeLocality: oldTypeLocality.present
            ? oldTypeLocality.value
            : this.oldTypeLocality,
        originalTypeLocality: originalTypeLocality.present
            ? originalTypeLocality.value
            : this.originalTypeLocality,
        uncheckedTypeLocality: uncheckedTypeLocality.present
            ? uncheckedTypeLocality.value
            : this.uncheckedTypeLocality,
        emendedTypeLocality: emendedTypeLocality.present
            ? emendedTypeLocality.value
            : this.emendedTypeLocality,
        typeLatitude:
            typeLatitude.present ? typeLatitude.value : this.typeLatitude,
        typeLongitude:
            typeLongitude.present ? typeLongitude.value : this.typeLongitude,
        typeCountry: typeCountry.present ? typeCountry.value : this.typeCountry,
        typeSubregion:
            typeSubregion.present ? typeSubregion.value : this.typeSubregion,
        typeSubregion2:
            typeSubregion2.present ? typeSubregion2.value : this.typeSubregion2,
        holotype: holotype.present ? holotype.value : this.holotype,
        typeKind: typeKind.present ? typeKind.value : this.typeKind,
        typeSpecimenLink: typeSpecimenLink.present
            ? typeSpecimenLink.value
            : this.typeSpecimenLink,
        taxonOrder: taxonOrder.present ? taxonOrder.value : this.taxonOrder,
        family: family.present ? family.value : this.family,
        genus: genus.present ? genus.value : this.genus,
        specificEpithet: specificEpithet.present
            ? specificEpithet.value
            : this.specificEpithet,
        subspecificEpithet: subspecificEpithet.present
            ? subspecificEpithet.value
            : this.subspecificEpithet,
        variantOf: variantOf.present ? variantOf.value : this.variantOf,
        seniorHomonym:
            seniorHomonym.present ? seniorHomonym.value : this.seniorHomonym,
        variantNameCitations: variantNameCitations.present
            ? variantNameCitations.value
            : this.variantNameCitations,
        nameUsages: nameUsages.present ? nameUsages.value : this.nameUsages,
        comments: comments.present ? comments.value : this.comments,
      );
  SynonymData copyWithCompanion(SynonymCompanion data) {
    return SynonymData(
      synId: data.synId.present ? data.synId.value : this.synId,
      hespId: data.hespId.present ? data.hespId.value : this.hespId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      species: data.species.present ? data.species.value : this.species,
      rootName: data.rootName.present ? data.rootName.value : this.rootName,
      author: data.author.present ? data.author.value : this.author,
      year: data.year.present ? data.year.value : this.year,
      authorityParentheses: data.authorityParentheses.present
          ? data.authorityParentheses.value
          : this.authorityParentheses,
      nomenclatureStatus: data.nomenclatureStatus.present
          ? data.nomenclatureStatus.value
          : this.nomenclatureStatus,
      validity: data.validity.present ? data.validity.value : this.validity,
      originalCombination: data.originalCombination.present
          ? data.originalCombination.value
          : this.originalCombination,
      originalRank: data.originalRank.present
          ? data.originalRank.value
          : this.originalRank,
      authorityCitation: data.authorityCitation.present
          ? data.authorityCitation.value
          : this.authorityCitation,
      uncheckedAuthorityCitation: data.uncheckedAuthorityCitation.present
          ? data.uncheckedAuthorityCitation.value
          : this.uncheckedAuthorityCitation,
      sourcedUnverifiedCitations: data.sourcedUnverifiedCitations.present
          ? data.sourcedUnverifiedCitations.value
          : this.sourcedUnverifiedCitations,
      citationGroup: data.citationGroup.present
          ? data.citationGroup.value
          : this.citationGroup,
      citationKind: data.citationKind.present
          ? data.citationKind.value
          : this.citationKind,
      authorityPage: data.authorityPage.present
          ? data.authorityPage.value
          : this.authorityPage,
      authorityLink: data.authorityLink.present
          ? data.authorityLink.value
          : this.authorityLink,
      authorityPageLink: data.authorityPageLink.present
          ? data.authorityPageLink.value
          : this.authorityPageLink,
      uncheckedAuthorityPageLink: data.uncheckedAuthorityPageLink.present
          ? data.uncheckedAuthorityPageLink.value
          : this.uncheckedAuthorityPageLink,
      oldTypeLocality: data.oldTypeLocality.present
          ? data.oldTypeLocality.value
          : this.oldTypeLocality,
      originalTypeLocality: data.originalTypeLocality.present
          ? data.originalTypeLocality.value
          : this.originalTypeLocality,
      uncheckedTypeLocality: data.uncheckedTypeLocality.present
          ? data.uncheckedTypeLocality.value
          : this.uncheckedTypeLocality,
      emendedTypeLocality: data.emendedTypeLocality.present
          ? data.emendedTypeLocality.value
          : this.emendedTypeLocality,
      typeLatitude: data.typeLatitude.present
          ? data.typeLatitude.value
          : this.typeLatitude,
      typeLongitude: data.typeLongitude.present
          ? data.typeLongitude.value
          : this.typeLongitude,
      typeCountry:
          data.typeCountry.present ? data.typeCountry.value : this.typeCountry,
      typeSubregion: data.typeSubregion.present
          ? data.typeSubregion.value
          : this.typeSubregion,
      typeSubregion2: data.typeSubregion2.present
          ? data.typeSubregion2.value
          : this.typeSubregion2,
      holotype: data.holotype.present ? data.holotype.value : this.holotype,
      typeKind: data.typeKind.present ? data.typeKind.value : this.typeKind,
      typeSpecimenLink: data.typeSpecimenLink.present
          ? data.typeSpecimenLink.value
          : this.typeSpecimenLink,
      taxonOrder:
          data.taxonOrder.present ? data.taxonOrder.value : this.taxonOrder,
      family: data.family.present ? data.family.value : this.family,
      genus: data.genus.present ? data.genus.value : this.genus,
      specificEpithet: data.specificEpithet.present
          ? data.specificEpithet.value
          : this.specificEpithet,
      subspecificEpithet: data.subspecificEpithet.present
          ? data.subspecificEpithet.value
          : this.subspecificEpithet,
      variantOf: data.variantOf.present ? data.variantOf.value : this.variantOf,
      seniorHomonym: data.seniorHomonym.present
          ? data.seniorHomonym.value
          : this.seniorHomonym,
      variantNameCitations: data.variantNameCitations.present
          ? data.variantNameCitations.value
          : this.variantNameCitations,
      nameUsages:
          data.nameUsages.present ? data.nameUsages.value : this.nameUsages,
      comments: data.comments.present ? data.comments.value : this.comments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SynonymData(')
          ..write('synId: $synId, ')
          ..write('hespId: $hespId, ')
          ..write('speciesId: $speciesId, ')
          ..write('species: $species, ')
          ..write('rootName: $rootName, ')
          ..write('author: $author, ')
          ..write('year: $year, ')
          ..write('authorityParentheses: $authorityParentheses, ')
          ..write('nomenclatureStatus: $nomenclatureStatus, ')
          ..write('validity: $validity, ')
          ..write('originalCombination: $originalCombination, ')
          ..write('originalRank: $originalRank, ')
          ..write('authorityCitation: $authorityCitation, ')
          ..write('uncheckedAuthorityCitation: $uncheckedAuthorityCitation, ')
          ..write('sourcedUnverifiedCitations: $sourcedUnverifiedCitations, ')
          ..write('citationGroup: $citationGroup, ')
          ..write('citationKind: $citationKind, ')
          ..write('authorityPage: $authorityPage, ')
          ..write('authorityLink: $authorityLink, ')
          ..write('authorityPageLink: $authorityPageLink, ')
          ..write('uncheckedAuthorityPageLink: $uncheckedAuthorityPageLink, ')
          ..write('oldTypeLocality: $oldTypeLocality, ')
          ..write('originalTypeLocality: $originalTypeLocality, ')
          ..write('uncheckedTypeLocality: $uncheckedTypeLocality, ')
          ..write('emendedTypeLocality: $emendedTypeLocality, ')
          ..write('typeLatitude: $typeLatitude, ')
          ..write('typeLongitude: $typeLongitude, ')
          ..write('typeCountry: $typeCountry, ')
          ..write('typeSubregion: $typeSubregion, ')
          ..write('typeSubregion2: $typeSubregion2, ')
          ..write('holotype: $holotype, ')
          ..write('typeKind: $typeKind, ')
          ..write('typeSpecimenLink: $typeSpecimenLink, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('family: $family, ')
          ..write('genus: $genus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('subspecificEpithet: $subspecificEpithet, ')
          ..write('variantOf: $variantOf, ')
          ..write('seniorHomonym: $seniorHomonym, ')
          ..write('variantNameCitations: $variantNameCitations, ')
          ..write('nameUsages: $nameUsages, ')
          ..write('comments: $comments')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        synId,
        hespId,
        speciesId,
        species,
        rootName,
        author,
        year,
        authorityParentheses,
        nomenclatureStatus,
        validity,
        originalCombination,
        originalRank,
        authorityCitation,
        uncheckedAuthorityCitation,
        sourcedUnverifiedCitations,
        citationGroup,
        citationKind,
        authorityPage,
        authorityLink,
        authorityPageLink,
        uncheckedAuthorityPageLink,
        oldTypeLocality,
        originalTypeLocality,
        uncheckedTypeLocality,
        emendedTypeLocality,
        typeLatitude,
        typeLongitude,
        typeCountry,
        typeSubregion,
        typeSubregion2,
        holotype,
        typeKind,
        typeSpecimenLink,
        taxonOrder,
        family,
        genus,
        specificEpithet,
        subspecificEpithet,
        variantOf,
        seniorHomonym,
        variantNameCitations,
        nameUsages,
        comments
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SynonymData &&
          other.synId == this.synId &&
          other.hespId == this.hespId &&
          other.speciesId == this.speciesId &&
          other.species == this.species &&
          other.rootName == this.rootName &&
          other.author == this.author &&
          other.year == this.year &&
          other.authorityParentheses == this.authorityParentheses &&
          other.nomenclatureStatus == this.nomenclatureStatus &&
          other.validity == this.validity &&
          other.originalCombination == this.originalCombination &&
          other.originalRank == this.originalRank &&
          other.authorityCitation == this.authorityCitation &&
          other.uncheckedAuthorityCitation == this.uncheckedAuthorityCitation &&
          other.sourcedUnverifiedCitations == this.sourcedUnverifiedCitations &&
          other.citationGroup == this.citationGroup &&
          other.citationKind == this.citationKind &&
          other.authorityPage == this.authorityPage &&
          other.authorityLink == this.authorityLink &&
          other.authorityPageLink == this.authorityPageLink &&
          other.uncheckedAuthorityPageLink == this.uncheckedAuthorityPageLink &&
          other.oldTypeLocality == this.oldTypeLocality &&
          other.originalTypeLocality == this.originalTypeLocality &&
          other.uncheckedTypeLocality == this.uncheckedTypeLocality &&
          other.emendedTypeLocality == this.emendedTypeLocality &&
          other.typeLatitude == this.typeLatitude &&
          other.typeLongitude == this.typeLongitude &&
          other.typeCountry == this.typeCountry &&
          other.typeSubregion == this.typeSubregion &&
          other.typeSubregion2 == this.typeSubregion2 &&
          other.holotype == this.holotype &&
          other.typeKind == this.typeKind &&
          other.typeSpecimenLink == this.typeSpecimenLink &&
          other.taxonOrder == this.taxonOrder &&
          other.family == this.family &&
          other.genus == this.genus &&
          other.specificEpithet == this.specificEpithet &&
          other.subspecificEpithet == this.subspecificEpithet &&
          other.variantOf == this.variantOf &&
          other.seniorHomonym == this.seniorHomonym &&
          other.variantNameCitations == this.variantNameCitations &&
          other.nameUsages == this.nameUsages &&
          other.comments == this.comments);
}

class SynonymCompanion extends UpdateCompanion<SynonymData> {
  final Value<int?> synId;
  final Value<int?> hespId;
  final Value<int?> speciesId;
  final Value<String?> species;
  final Value<String?> rootName;
  final Value<String?> author;
  final Value<String?> year;
  final Value<int?> authorityParentheses;
  final Value<String?> nomenclatureStatus;
  final Value<String?> validity;
  final Value<String?> originalCombination;
  final Value<String?> originalRank;
  final Value<String?> authorityCitation;
  final Value<String?> uncheckedAuthorityCitation;
  final Value<String?> sourcedUnverifiedCitations;
  final Value<String?> citationGroup;
  final Value<String?> citationKind;
  final Value<String?> authorityPage;
  final Value<String?> authorityLink;
  final Value<String?> authorityPageLink;
  final Value<String?> uncheckedAuthorityPageLink;
  final Value<String?> oldTypeLocality;
  final Value<String?> originalTypeLocality;
  final Value<String?> uncheckedTypeLocality;
  final Value<String?> emendedTypeLocality;
  final Value<String?> typeLatitude;
  final Value<String?> typeLongitude;
  final Value<String?> typeCountry;
  final Value<String?> typeSubregion;
  final Value<String?> typeSubregion2;
  final Value<String?> holotype;
  final Value<String?> typeKind;
  final Value<String?> typeSpecimenLink;
  final Value<String?> taxonOrder;
  final Value<String?> family;
  final Value<String?> genus;
  final Value<String?> specificEpithet;
  final Value<String?> subspecificEpithet;
  final Value<String?> variantOf;
  final Value<String?> seniorHomonym;
  final Value<String?> variantNameCitations;
  final Value<String?> nameUsages;
  final Value<String?> comments;
  final Value<int> rowid;
  const SynonymCompanion({
    this.synId = const Value.absent(),
    this.hespId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.species = const Value.absent(),
    this.rootName = const Value.absent(),
    this.author = const Value.absent(),
    this.year = const Value.absent(),
    this.authorityParentheses = const Value.absent(),
    this.nomenclatureStatus = const Value.absent(),
    this.validity = const Value.absent(),
    this.originalCombination = const Value.absent(),
    this.originalRank = const Value.absent(),
    this.authorityCitation = const Value.absent(),
    this.uncheckedAuthorityCitation = const Value.absent(),
    this.sourcedUnverifiedCitations = const Value.absent(),
    this.citationGroup = const Value.absent(),
    this.citationKind = const Value.absent(),
    this.authorityPage = const Value.absent(),
    this.authorityLink = const Value.absent(),
    this.authorityPageLink = const Value.absent(),
    this.uncheckedAuthorityPageLink = const Value.absent(),
    this.oldTypeLocality = const Value.absent(),
    this.originalTypeLocality = const Value.absent(),
    this.uncheckedTypeLocality = const Value.absent(),
    this.emendedTypeLocality = const Value.absent(),
    this.typeLatitude = const Value.absent(),
    this.typeLongitude = const Value.absent(),
    this.typeCountry = const Value.absent(),
    this.typeSubregion = const Value.absent(),
    this.typeSubregion2 = const Value.absent(),
    this.holotype = const Value.absent(),
    this.typeKind = const Value.absent(),
    this.typeSpecimenLink = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.family = const Value.absent(),
    this.genus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.subspecificEpithet = const Value.absent(),
    this.variantOf = const Value.absent(),
    this.seniorHomonym = const Value.absent(),
    this.variantNameCitations = const Value.absent(),
    this.nameUsages = const Value.absent(),
    this.comments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SynonymCompanion.insert({
    this.synId = const Value.absent(),
    this.hespId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.species = const Value.absent(),
    this.rootName = const Value.absent(),
    this.author = const Value.absent(),
    this.year = const Value.absent(),
    this.authorityParentheses = const Value.absent(),
    this.nomenclatureStatus = const Value.absent(),
    this.validity = const Value.absent(),
    this.originalCombination = const Value.absent(),
    this.originalRank = const Value.absent(),
    this.authorityCitation = const Value.absent(),
    this.uncheckedAuthorityCitation = const Value.absent(),
    this.sourcedUnverifiedCitations = const Value.absent(),
    this.citationGroup = const Value.absent(),
    this.citationKind = const Value.absent(),
    this.authorityPage = const Value.absent(),
    this.authorityLink = const Value.absent(),
    this.authorityPageLink = const Value.absent(),
    this.uncheckedAuthorityPageLink = const Value.absent(),
    this.oldTypeLocality = const Value.absent(),
    this.originalTypeLocality = const Value.absent(),
    this.uncheckedTypeLocality = const Value.absent(),
    this.emendedTypeLocality = const Value.absent(),
    this.typeLatitude = const Value.absent(),
    this.typeLongitude = const Value.absent(),
    this.typeCountry = const Value.absent(),
    this.typeSubregion = const Value.absent(),
    this.typeSubregion2 = const Value.absent(),
    this.holotype = const Value.absent(),
    this.typeKind = const Value.absent(),
    this.typeSpecimenLink = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.family = const Value.absent(),
    this.genus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.subspecificEpithet = const Value.absent(),
    this.variantOf = const Value.absent(),
    this.seniorHomonym = const Value.absent(),
    this.variantNameCitations = const Value.absent(),
    this.nameUsages = const Value.absent(),
    this.comments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<SynonymData> custom({
    Expression<int>? synId,
    Expression<int>? hespId,
    Expression<int>? speciesId,
    Expression<String>? species,
    Expression<String>? rootName,
    Expression<String>? author,
    Expression<String>? year,
    Expression<int>? authorityParentheses,
    Expression<String>? nomenclatureStatus,
    Expression<String>? validity,
    Expression<String>? originalCombination,
    Expression<String>? originalRank,
    Expression<String>? authorityCitation,
    Expression<String>? uncheckedAuthorityCitation,
    Expression<String>? sourcedUnverifiedCitations,
    Expression<String>? citationGroup,
    Expression<String>? citationKind,
    Expression<String>? authorityPage,
    Expression<String>? authorityLink,
    Expression<String>? authorityPageLink,
    Expression<String>? uncheckedAuthorityPageLink,
    Expression<String>? oldTypeLocality,
    Expression<String>? originalTypeLocality,
    Expression<String>? uncheckedTypeLocality,
    Expression<String>? emendedTypeLocality,
    Expression<String>? typeLatitude,
    Expression<String>? typeLongitude,
    Expression<String>? typeCountry,
    Expression<String>? typeSubregion,
    Expression<String>? typeSubregion2,
    Expression<String>? holotype,
    Expression<String>? typeKind,
    Expression<String>? typeSpecimenLink,
    Expression<String>? taxonOrder,
    Expression<String>? family,
    Expression<String>? genus,
    Expression<String>? specificEpithet,
    Expression<String>? subspecificEpithet,
    Expression<String>? variantOf,
    Expression<String>? seniorHomonym,
    Expression<String>? variantNameCitations,
    Expression<String>? nameUsages,
    Expression<String>? comments,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (synId != null) 'synId': synId,
      if (hespId != null) 'hespId': hespId,
      if (speciesId != null) 'speciesId': speciesId,
      if (species != null) 'species': species,
      if (rootName != null) 'rootName': rootName,
      if (author != null) 'author': author,
      if (year != null) 'year': year,
      if (authorityParentheses != null)
        'authorityParentheses': authorityParentheses,
      if (nomenclatureStatus != null) 'nomenclatureStatus': nomenclatureStatus,
      if (validity != null) 'validity': validity,
      if (originalCombination != null)
        'originalCombination': originalCombination,
      if (originalRank != null) 'originalRank': originalRank,
      if (authorityCitation != null) 'authorityCitation': authorityCitation,
      if (uncheckedAuthorityCitation != null)
        'uncheckedAuthorityCitation': uncheckedAuthorityCitation,
      if (sourcedUnverifiedCitations != null)
        'sourcedUnverifiedCitations': sourcedUnverifiedCitations,
      if (citationGroup != null) 'citationGroup': citationGroup,
      if (citationKind != null) 'citationKind': citationKind,
      if (authorityPage != null) 'authorityPage': authorityPage,
      if (authorityLink != null) 'authorityLink': authorityLink,
      if (authorityPageLink != null) 'authorityPageLink': authorityPageLink,
      if (uncheckedAuthorityPageLink != null)
        'uncheckedAuthorityPageLink': uncheckedAuthorityPageLink,
      if (oldTypeLocality != null) 'oldTypeLocality': oldTypeLocality,
      if (originalTypeLocality != null)
        'originalTypeLocality': originalTypeLocality,
      if (uncheckedTypeLocality != null)
        'uncheckedTypeLocality': uncheckedTypeLocality,
      if (emendedTypeLocality != null)
        'emendedTypeLocality': emendedTypeLocality,
      if (typeLatitude != null) 'typeLatitude': typeLatitude,
      if (typeLongitude != null) 'typeLongitude': typeLongitude,
      if (typeCountry != null) 'typeCountry': typeCountry,
      if (typeSubregion != null) 'typeSubregion': typeSubregion,
      if (typeSubregion2 != null) 'typeSubregion2': typeSubregion2,
      if (holotype != null) 'holotype': holotype,
      if (typeKind != null) 'typeKind': typeKind,
      if (typeSpecimenLink != null) 'typeSpecimenLink': typeSpecimenLink,
      if (taxonOrder != null) 'taxonOrder': taxonOrder,
      if (family != null) 'family': family,
      if (genus != null) 'genus': genus,
      if (specificEpithet != null) 'specificEpithet': specificEpithet,
      if (subspecificEpithet != null) 'subspecificEpithet': subspecificEpithet,
      if (variantOf != null) 'variantOf': variantOf,
      if (seniorHomonym != null) 'seniorHomonym': seniorHomonym,
      if (variantNameCitations != null)
        'variantNameCitations': variantNameCitations,
      if (nameUsages != null) 'nameUsages': nameUsages,
      if (comments != null) 'comments': comments,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SynonymCompanion copyWith(
      {Value<int?>? synId,
      Value<int?>? hespId,
      Value<int?>? speciesId,
      Value<String?>? species,
      Value<String?>? rootName,
      Value<String?>? author,
      Value<String?>? year,
      Value<int?>? authorityParentheses,
      Value<String?>? nomenclatureStatus,
      Value<String?>? validity,
      Value<String?>? originalCombination,
      Value<String?>? originalRank,
      Value<String?>? authorityCitation,
      Value<String?>? uncheckedAuthorityCitation,
      Value<String?>? sourcedUnverifiedCitations,
      Value<String?>? citationGroup,
      Value<String?>? citationKind,
      Value<String?>? authorityPage,
      Value<String?>? authorityLink,
      Value<String?>? authorityPageLink,
      Value<String?>? uncheckedAuthorityPageLink,
      Value<String?>? oldTypeLocality,
      Value<String?>? originalTypeLocality,
      Value<String?>? uncheckedTypeLocality,
      Value<String?>? emendedTypeLocality,
      Value<String?>? typeLatitude,
      Value<String?>? typeLongitude,
      Value<String?>? typeCountry,
      Value<String?>? typeSubregion,
      Value<String?>? typeSubregion2,
      Value<String?>? holotype,
      Value<String?>? typeKind,
      Value<String?>? typeSpecimenLink,
      Value<String?>? taxonOrder,
      Value<String?>? family,
      Value<String?>? genus,
      Value<String?>? specificEpithet,
      Value<String?>? subspecificEpithet,
      Value<String?>? variantOf,
      Value<String?>? seniorHomonym,
      Value<String?>? variantNameCitations,
      Value<String?>? nameUsages,
      Value<String?>? comments,
      Value<int>? rowid}) {
    return SynonymCompanion(
      synId: synId ?? this.synId,
      hespId: hespId ?? this.hespId,
      speciesId: speciesId ?? this.speciesId,
      species: species ?? this.species,
      rootName: rootName ?? this.rootName,
      author: author ?? this.author,
      year: year ?? this.year,
      authorityParentheses: authorityParentheses ?? this.authorityParentheses,
      nomenclatureStatus: nomenclatureStatus ?? this.nomenclatureStatus,
      validity: validity ?? this.validity,
      originalCombination: originalCombination ?? this.originalCombination,
      originalRank: originalRank ?? this.originalRank,
      authorityCitation: authorityCitation ?? this.authorityCitation,
      uncheckedAuthorityCitation:
          uncheckedAuthorityCitation ?? this.uncheckedAuthorityCitation,
      sourcedUnverifiedCitations:
          sourcedUnverifiedCitations ?? this.sourcedUnverifiedCitations,
      citationGroup: citationGroup ?? this.citationGroup,
      citationKind: citationKind ?? this.citationKind,
      authorityPage: authorityPage ?? this.authorityPage,
      authorityLink: authorityLink ?? this.authorityLink,
      authorityPageLink: authorityPageLink ?? this.authorityPageLink,
      uncheckedAuthorityPageLink:
          uncheckedAuthorityPageLink ?? this.uncheckedAuthorityPageLink,
      oldTypeLocality: oldTypeLocality ?? this.oldTypeLocality,
      originalTypeLocality: originalTypeLocality ?? this.originalTypeLocality,
      uncheckedTypeLocality:
          uncheckedTypeLocality ?? this.uncheckedTypeLocality,
      emendedTypeLocality: emendedTypeLocality ?? this.emendedTypeLocality,
      typeLatitude: typeLatitude ?? this.typeLatitude,
      typeLongitude: typeLongitude ?? this.typeLongitude,
      typeCountry: typeCountry ?? this.typeCountry,
      typeSubregion: typeSubregion ?? this.typeSubregion,
      typeSubregion2: typeSubregion2 ?? this.typeSubregion2,
      holotype: holotype ?? this.holotype,
      typeKind: typeKind ?? this.typeKind,
      typeSpecimenLink: typeSpecimenLink ?? this.typeSpecimenLink,
      taxonOrder: taxonOrder ?? this.taxonOrder,
      family: family ?? this.family,
      genus: genus ?? this.genus,
      specificEpithet: specificEpithet ?? this.specificEpithet,
      subspecificEpithet: subspecificEpithet ?? this.subspecificEpithet,
      variantOf: variantOf ?? this.variantOf,
      seniorHomonym: seniorHomonym ?? this.seniorHomonym,
      variantNameCitations: variantNameCitations ?? this.variantNameCitations,
      nameUsages: nameUsages ?? this.nameUsages,
      comments: comments ?? this.comments,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (synId.present) {
      map['synId'] = Variable<int>(synId.value);
    }
    if (hespId.present) {
      map['hespId'] = Variable<int>(hespId.value);
    }
    if (speciesId.present) {
      map['speciesId'] = Variable<int>(speciesId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (rootName.present) {
      map['rootName'] = Variable<String>(rootName.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (authorityParentheses.present) {
      map['authorityParentheses'] = Variable<int>(authorityParentheses.value);
    }
    if (nomenclatureStatus.present) {
      map['nomenclatureStatus'] = Variable<String>(nomenclatureStatus.value);
    }
    if (validity.present) {
      map['validity'] = Variable<String>(validity.value);
    }
    if (originalCombination.present) {
      map['originalCombination'] = Variable<String>(originalCombination.value);
    }
    if (originalRank.present) {
      map['originalRank'] = Variable<String>(originalRank.value);
    }
    if (authorityCitation.present) {
      map['authorityCitation'] = Variable<String>(authorityCitation.value);
    }
    if (uncheckedAuthorityCitation.present) {
      map['uncheckedAuthorityCitation'] =
          Variable<String>(uncheckedAuthorityCitation.value);
    }
    if (sourcedUnverifiedCitations.present) {
      map['sourcedUnverifiedCitations'] =
          Variable<String>(sourcedUnverifiedCitations.value);
    }
    if (citationGroup.present) {
      map['citationGroup'] = Variable<String>(citationGroup.value);
    }
    if (citationKind.present) {
      map['citationKind'] = Variable<String>(citationKind.value);
    }
    if (authorityPage.present) {
      map['authorityPage'] = Variable<String>(authorityPage.value);
    }
    if (authorityLink.present) {
      map['authorityLink'] = Variable<String>(authorityLink.value);
    }
    if (authorityPageLink.present) {
      map['authorityPageLink'] = Variable<String>(authorityPageLink.value);
    }
    if (uncheckedAuthorityPageLink.present) {
      map['uncheckedAuthorityPageLink'] =
          Variable<String>(uncheckedAuthorityPageLink.value);
    }
    if (oldTypeLocality.present) {
      map['oldTypeLocality'] = Variable<String>(oldTypeLocality.value);
    }
    if (originalTypeLocality.present) {
      map['originalTypeLocality'] =
          Variable<String>(originalTypeLocality.value);
    }
    if (uncheckedTypeLocality.present) {
      map['uncheckedTypeLocality'] =
          Variable<String>(uncheckedTypeLocality.value);
    }
    if (emendedTypeLocality.present) {
      map['emendedTypeLocality'] = Variable<String>(emendedTypeLocality.value);
    }
    if (typeLatitude.present) {
      map['typeLatitude'] = Variable<String>(typeLatitude.value);
    }
    if (typeLongitude.present) {
      map['typeLongitude'] = Variable<String>(typeLongitude.value);
    }
    if (typeCountry.present) {
      map['typeCountry'] = Variable<String>(typeCountry.value);
    }
    if (typeSubregion.present) {
      map['typeSubregion'] = Variable<String>(typeSubregion.value);
    }
    if (typeSubregion2.present) {
      map['typeSubregion2'] = Variable<String>(typeSubregion2.value);
    }
    if (holotype.present) {
      map['holotype'] = Variable<String>(holotype.value);
    }
    if (typeKind.present) {
      map['typeKind'] = Variable<String>(typeKind.value);
    }
    if (typeSpecimenLink.present) {
      map['typeSpecimenLink'] = Variable<String>(typeSpecimenLink.value);
    }
    if (taxonOrder.present) {
      map['taxonOrder'] = Variable<String>(taxonOrder.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (genus.present) {
      map['genus'] = Variable<String>(genus.value);
    }
    if (specificEpithet.present) {
      map['specificEpithet'] = Variable<String>(specificEpithet.value);
    }
    if (subspecificEpithet.present) {
      map['subspecificEpithet'] = Variable<String>(subspecificEpithet.value);
    }
    if (variantOf.present) {
      map['variantOf'] = Variable<String>(variantOf.value);
    }
    if (seniorHomonym.present) {
      map['seniorHomonym'] = Variable<String>(seniorHomonym.value);
    }
    if (variantNameCitations.present) {
      map['variantNameCitations'] =
          Variable<String>(variantNameCitations.value);
    }
    if (nameUsages.present) {
      map['nameUsages'] = Variable<String>(nameUsages.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SynonymCompanion(')
          ..write('synId: $synId, ')
          ..write('hespId: $hespId, ')
          ..write('speciesId: $speciesId, ')
          ..write('species: $species, ')
          ..write('rootName: $rootName, ')
          ..write('author: $author, ')
          ..write('year: $year, ')
          ..write('authorityParentheses: $authorityParentheses, ')
          ..write('nomenclatureStatus: $nomenclatureStatus, ')
          ..write('validity: $validity, ')
          ..write('originalCombination: $originalCombination, ')
          ..write('originalRank: $originalRank, ')
          ..write('authorityCitation: $authorityCitation, ')
          ..write('uncheckedAuthorityCitation: $uncheckedAuthorityCitation, ')
          ..write('sourcedUnverifiedCitations: $sourcedUnverifiedCitations, ')
          ..write('citationGroup: $citationGroup, ')
          ..write('citationKind: $citationKind, ')
          ..write('authorityPage: $authorityPage, ')
          ..write('authorityLink: $authorityLink, ')
          ..write('authorityPageLink: $authorityPageLink, ')
          ..write('uncheckedAuthorityPageLink: $uncheckedAuthorityPageLink, ')
          ..write('oldTypeLocality: $oldTypeLocality, ')
          ..write('originalTypeLocality: $originalTypeLocality, ')
          ..write('uncheckedTypeLocality: $uncheckedTypeLocality, ')
          ..write('emendedTypeLocality: $emendedTypeLocality, ')
          ..write('typeLatitude: $typeLatitude, ')
          ..write('typeLongitude: $typeLongitude, ')
          ..write('typeCountry: $typeCountry, ')
          ..write('typeSubregion: $typeSubregion, ')
          ..write('typeSubregion2: $typeSubregion2, ')
          ..write('holotype: $holotype, ')
          ..write('typeKind: $typeKind, ')
          ..write('typeSpecimenLink: $typeSpecimenLink, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('family: $family, ')
          ..write('genus: $genus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('subspecificEpithet: $subspecificEpithet, ')
          ..write('variantOf: $variantOf, ')
          ..write('seniorHomonym: $seniorHomonym, ')
          ..write('variantNameCitations: $variantNameCitations, ')
          ..write('nameUsages: $nameUsages, ')
          ..write('comments: $comments, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final MddInfo mddInfo = MddInfo(this);
  late final Taxonomy taxonomy = Taxonomy(this);
  late final Synonym synonym = Synonym(this);
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

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [mddInfo, taxonomy, synonym];
}

typedef $MddInfoCreateCompanionBuilder = MddInfoCompanion Function({
  Value<String?> version,
  Value<String?> releaseDate,
  Value<int> rowid,
});
typedef $MddInfoUpdateCompanionBuilder = MddInfoCompanion Function({
  Value<String?> version,
  Value<String?> releaseDate,
  Value<int> rowid,
});

class $MddInfoFilterComposer extends Composer<_$AppDatabase, MddInfo> {
  $MddInfoFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnFilters(column));
}

class $MddInfoOrderingComposer extends Composer<_$AppDatabase, MddInfo> {
  $MddInfoOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnOrderings(column));
}

class $MddInfoAnnotationComposer extends Composer<_$AppDatabase, MddInfo> {
  $MddInfoAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => column);
}

class $MddInfoTableManager extends RootTableManager<
    _$AppDatabase,
    MddInfo,
    MddInfoData,
    $MddInfoFilterComposer,
    $MddInfoOrderingComposer,
    $MddInfoAnnotationComposer,
    $MddInfoCreateCompanionBuilder,
    $MddInfoUpdateCompanionBuilder,
    (MddInfoData, BaseReferences<_$AppDatabase, MddInfo, MddInfoData>),
    MddInfoData,
    PrefetchHooks Function()> {
  $MddInfoTableManager(_$AppDatabase db, MddInfo table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MddInfoFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MddInfoOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MddInfoAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> version = const Value.absent(),
            Value<String?> releaseDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MddInfoCompanion(
            version: version,
            releaseDate: releaseDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> version = const Value.absent(),
            Value<String?> releaseDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MddInfoCompanion.insert(
            version: version,
            releaseDate: releaseDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $MddInfoProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    MddInfo,
    MddInfoData,
    $MddInfoFilterComposer,
    $MddInfoOrderingComposer,
    $MddInfoAnnotationComposer,
    $MddInfoCreateCompanionBuilder,
    $MddInfoUpdateCompanionBuilder,
    (MddInfoData, BaseReferences<_$AppDatabase, MddInfo, MddInfoData>),
    MddInfoData,
    PrefetchHooks Function()>;
typedef $TaxonomyCreateCompanionBuilder = TaxonomyCompanion Function({
  Value<int> id,
  Value<int?> phylosort,
  Value<String?> subclass,
  Value<String?> infraclass,
  Value<String?> magnorder,
  Value<String?> superorder,
  Value<String?> taxonOrder,
  Value<String?> suborder,
  Value<String?> infraorder,
  Value<String?> parvorder,
  Value<String?> superfamily,
  Value<String?> family,
  Value<String?> subfamily,
  Value<String?> tribe,
  Value<String?> genus,
  Value<String?> subgenus,
  Value<String?> specificEpithet,
  Value<String?> sciName,
  Value<String?> authoritySpeciesAuthor,
  Value<int?> authoritySpeciesYear,
  Value<int?> authorityParentheses,
  Value<String?> mainCommonName,
  Value<String?> otherCommonNames,
  Value<String?> originalNameCombination,
  Value<String?> authoritySpeciesCitation,
  Value<String?> authoritySpeciesLink,
  Value<String?> typeVoucher,
  Value<String?> typeKind,
  Value<String?> typeVoucherURIs,
  Value<String?> typeLocality,
  Value<String?> typeLocalityLatitude,
  Value<String?> typeLocalityLongitude,
  Value<String?> nominalNames,
  Value<String?> taxonomyNotes,
  Value<String?> taxonomyNotesCitation,
  Value<String?> distributionNotes,
  Value<String?> distributionNotesCitation,
  Value<String?> subregionDistribution,
  Value<String?> countryDistribution,
  Value<String?> continentDistribution,
  Value<String?> biogeographicRealm,
  Value<String?> iucnStatus,
  Value<String?> extinct,
  Value<String?> domestic,
  Value<String?> flagged,
  Value<String?> cMWSciName,
  Value<String?> diffSinceCMW,
  Value<String?> mSW3Matchtype,
  Value<String?> mSW3SciName,
  Value<String?> diffSinceMSW3,
});
typedef $TaxonomyUpdateCompanionBuilder = TaxonomyCompanion Function({
  Value<int> id,
  Value<int?> phylosort,
  Value<String?> subclass,
  Value<String?> infraclass,
  Value<String?> magnorder,
  Value<String?> superorder,
  Value<String?> taxonOrder,
  Value<String?> suborder,
  Value<String?> infraorder,
  Value<String?> parvorder,
  Value<String?> superfamily,
  Value<String?> family,
  Value<String?> subfamily,
  Value<String?> tribe,
  Value<String?> genus,
  Value<String?> subgenus,
  Value<String?> specificEpithet,
  Value<String?> sciName,
  Value<String?> authoritySpeciesAuthor,
  Value<int?> authoritySpeciesYear,
  Value<int?> authorityParentheses,
  Value<String?> mainCommonName,
  Value<String?> otherCommonNames,
  Value<String?> originalNameCombination,
  Value<String?> authoritySpeciesCitation,
  Value<String?> authoritySpeciesLink,
  Value<String?> typeVoucher,
  Value<String?> typeKind,
  Value<String?> typeVoucherURIs,
  Value<String?> typeLocality,
  Value<String?> typeLocalityLatitude,
  Value<String?> typeLocalityLongitude,
  Value<String?> nominalNames,
  Value<String?> taxonomyNotes,
  Value<String?> taxonomyNotesCitation,
  Value<String?> distributionNotes,
  Value<String?> distributionNotesCitation,
  Value<String?> subregionDistribution,
  Value<String?> countryDistribution,
  Value<String?> continentDistribution,
  Value<String?> biogeographicRealm,
  Value<String?> iucnStatus,
  Value<String?> extinct,
  Value<String?> domestic,
  Value<String?> flagged,
  Value<String?> cMWSciName,
  Value<String?> diffSinceCMW,
  Value<String?> mSW3Matchtype,
  Value<String?> mSW3SciName,
  Value<String?> diffSinceMSW3,
});

class $TaxonomyFilterComposer extends Composer<_$AppDatabase, Taxonomy> {
  $TaxonomyFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get phylosort => $composableBuilder(
      column: $table.phylosort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subclass => $composableBuilder(
      column: $table.subclass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get infraclass => $composableBuilder(
      column: $table.infraclass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get magnorder => $composableBuilder(
      column: $table.magnorder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get superorder => $composableBuilder(
      column: $table.superorder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suborder => $composableBuilder(
      column: $table.suborder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get infraorder => $composableBuilder(
      column: $table.infraorder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parvorder => $composableBuilder(
      column: $table.parvorder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get superfamily => $composableBuilder(
      column: $table.superfamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subfamily => $composableBuilder(
      column: $table.subfamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tribe => $composableBuilder(
      column: $table.tribe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subgenus => $composableBuilder(
      column: $table.subgenus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sciName => $composableBuilder(
      column: $table.sciName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authoritySpeciesAuthor => $composableBuilder(
      column: $table.authoritySpeciesAuthor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get authoritySpeciesYear => $composableBuilder(
      column: $table.authoritySpeciesYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mainCommonName => $composableBuilder(
      column: $table.mainCommonName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherCommonNames => $composableBuilder(
      column: $table.otherCommonNames,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalNameCombination => $composableBuilder(
      column: $table.originalNameCombination,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authoritySpeciesCitation => $composableBuilder(
      column: $table.authoritySpeciesCitation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authoritySpeciesLink => $composableBuilder(
      column: $table.authoritySpeciesLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeVoucher => $composableBuilder(
      column: $table.typeVoucher, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeKind => $composableBuilder(
      column: $table.typeKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeVoucherURIs => $composableBuilder(
      column: $table.typeVoucherURIs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeLocality => $composableBuilder(
      column: $table.typeLocality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeLocalityLatitude => $composableBuilder(
      column: $table.typeLocalityLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeLocalityLongitude => $composableBuilder(
      column: $table.typeLocalityLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nominalNames => $composableBuilder(
      column: $table.nominalNames, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonomyNotes => $composableBuilder(
      column: $table.taxonomyNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonomyNotesCitation => $composableBuilder(
      column: $table.taxonomyNotesCitation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get distributionNotes => $composableBuilder(
      column: $table.distributionNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get distributionNotesCitation => $composableBuilder(
      column: $table.distributionNotesCitation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subregionDistribution => $composableBuilder(
      column: $table.subregionDistribution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryDistribution => $composableBuilder(
      column: $table.countryDistribution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get continentDistribution => $composableBuilder(
      column: $table.continentDistribution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get biogeographicRealm => $composableBuilder(
      column: $table.biogeographicRealm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iucnStatus => $composableBuilder(
      column: $table.iucnStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extinct => $composableBuilder(
      column: $table.extinct, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domestic => $composableBuilder(
      column: $table.domestic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flagged => $composableBuilder(
      column: $table.flagged, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cMWSciName => $composableBuilder(
      column: $table.cMWSciName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diffSinceCMW => $composableBuilder(
      column: $table.diffSinceCMW, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mSW3Matchtype => $composableBuilder(
      column: $table.mSW3Matchtype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mSW3SciName => $composableBuilder(
      column: $table.mSW3SciName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diffSinceMSW3 => $composableBuilder(
      column: $table.diffSinceMSW3, builder: (column) => ColumnFilters(column));
}

class $TaxonomyOrderingComposer extends Composer<_$AppDatabase, Taxonomy> {
  $TaxonomyOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get phylosort => $composableBuilder(
      column: $table.phylosort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subclass => $composableBuilder(
      column: $table.subclass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get infraclass => $composableBuilder(
      column: $table.infraclass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get magnorder => $composableBuilder(
      column: $table.magnorder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get superorder => $composableBuilder(
      column: $table.superorder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suborder => $composableBuilder(
      column: $table.suborder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get infraorder => $composableBuilder(
      column: $table.infraorder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parvorder => $composableBuilder(
      column: $table.parvorder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get superfamily => $composableBuilder(
      column: $table.superfamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subfamily => $composableBuilder(
      column: $table.subfamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tribe => $composableBuilder(
      column: $table.tribe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subgenus => $composableBuilder(
      column: $table.subgenus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sciName => $composableBuilder(
      column: $table.sciName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authoritySpeciesAuthor => $composableBuilder(
      column: $table.authoritySpeciesAuthor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get authoritySpeciesYear => $composableBuilder(
      column: $table.authoritySpeciesYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mainCommonName => $composableBuilder(
      column: $table.mainCommonName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherCommonNames => $composableBuilder(
      column: $table.otherCommonNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalNameCombination => $composableBuilder(
      column: $table.originalNameCombination,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authoritySpeciesCitation => $composableBuilder(
      column: $table.authoritySpeciesCitation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authoritySpeciesLink => $composableBuilder(
      column: $table.authoritySpeciesLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeVoucher => $composableBuilder(
      column: $table.typeVoucher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeKind => $composableBuilder(
      column: $table.typeKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeVoucherURIs => $composableBuilder(
      column: $table.typeVoucherURIs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeLocality => $composableBuilder(
      column: $table.typeLocality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeLocalityLatitude => $composableBuilder(
      column: $table.typeLocalityLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeLocalityLongitude => $composableBuilder(
      column: $table.typeLocalityLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nominalNames => $composableBuilder(
      column: $table.nominalNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonomyNotes => $composableBuilder(
      column: $table.taxonomyNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonomyNotesCitation => $composableBuilder(
      column: $table.taxonomyNotesCitation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get distributionNotes => $composableBuilder(
      column: $table.distributionNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get distributionNotesCitation => $composableBuilder(
      column: $table.distributionNotesCitation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subregionDistribution => $composableBuilder(
      column: $table.subregionDistribution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryDistribution => $composableBuilder(
      column: $table.countryDistribution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get continentDistribution => $composableBuilder(
      column: $table.continentDistribution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get biogeographicRealm => $composableBuilder(
      column: $table.biogeographicRealm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iucnStatus => $composableBuilder(
      column: $table.iucnStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extinct => $composableBuilder(
      column: $table.extinct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domestic => $composableBuilder(
      column: $table.domestic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flagged => $composableBuilder(
      column: $table.flagged, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cMWSciName => $composableBuilder(
      column: $table.cMWSciName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diffSinceCMW => $composableBuilder(
      column: $table.diffSinceCMW,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mSW3Matchtype => $composableBuilder(
      column: $table.mSW3Matchtype,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mSW3SciName => $composableBuilder(
      column: $table.mSW3SciName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diffSinceMSW3 => $composableBuilder(
      column: $table.diffSinceMSW3,
      builder: (column) => ColumnOrderings(column));
}

class $TaxonomyAnnotationComposer extends Composer<_$AppDatabase, Taxonomy> {
  $TaxonomyAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get phylosort =>
      $composableBuilder(column: $table.phylosort, builder: (column) => column);

  GeneratedColumn<String> get subclass =>
      $composableBuilder(column: $table.subclass, builder: (column) => column);

  GeneratedColumn<String> get infraclass => $composableBuilder(
      column: $table.infraclass, builder: (column) => column);

  GeneratedColumn<String> get magnorder =>
      $composableBuilder(column: $table.magnorder, builder: (column) => column);

  GeneratedColumn<String> get superorder => $composableBuilder(
      column: $table.superorder, builder: (column) => column);

  GeneratedColumn<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => column);

  GeneratedColumn<String> get suborder =>
      $composableBuilder(column: $table.suborder, builder: (column) => column);

  GeneratedColumn<String> get infraorder => $composableBuilder(
      column: $table.infraorder, builder: (column) => column);

  GeneratedColumn<String> get parvorder =>
      $composableBuilder(column: $table.parvorder, builder: (column) => column);

  GeneratedColumn<String> get superfamily => $composableBuilder(
      column: $table.superfamily, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get subfamily =>
      $composableBuilder(column: $table.subfamily, builder: (column) => column);

  GeneratedColumn<String> get tribe =>
      $composableBuilder(column: $table.tribe, builder: (column) => column);

  GeneratedColumn<String> get genus =>
      $composableBuilder(column: $table.genus, builder: (column) => column);

  GeneratedColumn<String> get subgenus =>
      $composableBuilder(column: $table.subgenus, builder: (column) => column);

  GeneratedColumn<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet, builder: (column) => column);

  GeneratedColumn<String> get sciName =>
      $composableBuilder(column: $table.sciName, builder: (column) => column);

  GeneratedColumn<String> get authoritySpeciesAuthor => $composableBuilder(
      column: $table.authoritySpeciesAuthor, builder: (column) => column);

  GeneratedColumn<int> get authoritySpeciesYear => $composableBuilder(
      column: $table.authoritySpeciesYear, builder: (column) => column);

  GeneratedColumn<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses, builder: (column) => column);

  GeneratedColumn<String> get mainCommonName => $composableBuilder(
      column: $table.mainCommonName, builder: (column) => column);

  GeneratedColumn<String> get otherCommonNames => $composableBuilder(
      column: $table.otherCommonNames, builder: (column) => column);

  GeneratedColumn<String> get originalNameCombination => $composableBuilder(
      column: $table.originalNameCombination, builder: (column) => column);

  GeneratedColumn<String> get authoritySpeciesCitation => $composableBuilder(
      column: $table.authoritySpeciesCitation, builder: (column) => column);

  GeneratedColumn<String> get authoritySpeciesLink => $composableBuilder(
      column: $table.authoritySpeciesLink, builder: (column) => column);

  GeneratedColumn<String> get typeVoucher => $composableBuilder(
      column: $table.typeVoucher, builder: (column) => column);

  GeneratedColumn<String> get typeKind =>
      $composableBuilder(column: $table.typeKind, builder: (column) => column);

  GeneratedColumn<String> get typeVoucherURIs => $composableBuilder(
      column: $table.typeVoucherURIs, builder: (column) => column);

  GeneratedColumn<String> get typeLocality => $composableBuilder(
      column: $table.typeLocality, builder: (column) => column);

  GeneratedColumn<String> get typeLocalityLatitude => $composableBuilder(
      column: $table.typeLocalityLatitude, builder: (column) => column);

  GeneratedColumn<String> get typeLocalityLongitude => $composableBuilder(
      column: $table.typeLocalityLongitude, builder: (column) => column);

  GeneratedColumn<String> get nominalNames => $composableBuilder(
      column: $table.nominalNames, builder: (column) => column);

  GeneratedColumn<String> get taxonomyNotes => $composableBuilder(
      column: $table.taxonomyNotes, builder: (column) => column);

  GeneratedColumn<String> get taxonomyNotesCitation => $composableBuilder(
      column: $table.taxonomyNotesCitation, builder: (column) => column);

  GeneratedColumn<String> get distributionNotes => $composableBuilder(
      column: $table.distributionNotes, builder: (column) => column);

  GeneratedColumn<String> get distributionNotesCitation => $composableBuilder(
      column: $table.distributionNotesCitation, builder: (column) => column);

  GeneratedColumn<String> get subregionDistribution => $composableBuilder(
      column: $table.subregionDistribution, builder: (column) => column);

  GeneratedColumn<String> get countryDistribution => $composableBuilder(
      column: $table.countryDistribution, builder: (column) => column);

  GeneratedColumn<String> get continentDistribution => $composableBuilder(
      column: $table.continentDistribution, builder: (column) => column);

  GeneratedColumn<String> get biogeographicRealm => $composableBuilder(
      column: $table.biogeographicRealm, builder: (column) => column);

  GeneratedColumn<String> get iucnStatus => $composableBuilder(
      column: $table.iucnStatus, builder: (column) => column);

  GeneratedColumn<String> get extinct =>
      $composableBuilder(column: $table.extinct, builder: (column) => column);

  GeneratedColumn<String> get domestic =>
      $composableBuilder(column: $table.domestic, builder: (column) => column);

  GeneratedColumn<String> get flagged =>
      $composableBuilder(column: $table.flagged, builder: (column) => column);

  GeneratedColumn<String> get cMWSciName => $composableBuilder(
      column: $table.cMWSciName, builder: (column) => column);

  GeneratedColumn<String> get diffSinceCMW => $composableBuilder(
      column: $table.diffSinceCMW, builder: (column) => column);

  GeneratedColumn<String> get mSW3Matchtype => $composableBuilder(
      column: $table.mSW3Matchtype, builder: (column) => column);

  GeneratedColumn<String> get mSW3SciName => $composableBuilder(
      column: $table.mSW3SciName, builder: (column) => column);

  GeneratedColumn<String> get diffSinceMSW3 => $composableBuilder(
      column: $table.diffSinceMSW3, builder: (column) => column);
}

class $TaxonomyTableManager extends RootTableManager<
    _$AppDatabase,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyAnnotationComposer,
    $TaxonomyCreateCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder,
    (TaxonomyData, BaseReferences<_$AppDatabase, Taxonomy, TaxonomyData>),
    TaxonomyData,
    PrefetchHooks Function()> {
  $TaxonomyTableManager(_$AppDatabase db, Taxonomy table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaxonomyFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaxonomyOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaxonomyAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> phylosort = const Value.absent(),
            Value<String?> subclass = const Value.absent(),
            Value<String?> infraclass = const Value.absent(),
            Value<String?> magnorder = const Value.absent(),
            Value<String?> superorder = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> suborder = const Value.absent(),
            Value<String?> infraorder = const Value.absent(),
            Value<String?> parvorder = const Value.absent(),
            Value<String?> superfamily = const Value.absent(),
            Value<String?> family = const Value.absent(),
            Value<String?> subfamily = const Value.absent(),
            Value<String?> tribe = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> subgenus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> sciName = const Value.absent(),
            Value<String?> authoritySpeciesAuthor = const Value.absent(),
            Value<int?> authoritySpeciesYear = const Value.absent(),
            Value<int?> authorityParentheses = const Value.absent(),
            Value<String?> mainCommonName = const Value.absent(),
            Value<String?> otherCommonNames = const Value.absent(),
            Value<String?> originalNameCombination = const Value.absent(),
            Value<String?> authoritySpeciesCitation = const Value.absent(),
            Value<String?> authoritySpeciesLink = const Value.absent(),
            Value<String?> typeVoucher = const Value.absent(),
            Value<String?> typeKind = const Value.absent(),
            Value<String?> typeVoucherURIs = const Value.absent(),
            Value<String?> typeLocality = const Value.absent(),
            Value<String?> typeLocalityLatitude = const Value.absent(),
            Value<String?> typeLocalityLongitude = const Value.absent(),
            Value<String?> nominalNames = const Value.absent(),
            Value<String?> taxonomyNotes = const Value.absent(),
            Value<String?> taxonomyNotesCitation = const Value.absent(),
            Value<String?> distributionNotes = const Value.absent(),
            Value<String?> distributionNotesCitation = const Value.absent(),
            Value<String?> subregionDistribution = const Value.absent(),
            Value<String?> countryDistribution = const Value.absent(),
            Value<String?> continentDistribution = const Value.absent(),
            Value<String?> biogeographicRealm = const Value.absent(),
            Value<String?> iucnStatus = const Value.absent(),
            Value<String?> extinct = const Value.absent(),
            Value<String?> domestic = const Value.absent(),
            Value<String?> flagged = const Value.absent(),
            Value<String?> cMWSciName = const Value.absent(),
            Value<String?> diffSinceCMW = const Value.absent(),
            Value<String?> mSW3Matchtype = const Value.absent(),
            Value<String?> mSW3SciName = const Value.absent(),
            Value<String?> diffSinceMSW3 = const Value.absent(),
          }) =>
              TaxonomyCompanion(
            id: id,
            phylosort: phylosort,
            subclass: subclass,
            infraclass: infraclass,
            magnorder: magnorder,
            superorder: superorder,
            taxonOrder: taxonOrder,
            suborder: suborder,
            infraorder: infraorder,
            parvorder: parvorder,
            superfamily: superfamily,
            family: family,
            subfamily: subfamily,
            tribe: tribe,
            genus: genus,
            subgenus: subgenus,
            specificEpithet: specificEpithet,
            sciName: sciName,
            authoritySpeciesAuthor: authoritySpeciesAuthor,
            authoritySpeciesYear: authoritySpeciesYear,
            authorityParentheses: authorityParentheses,
            mainCommonName: mainCommonName,
            otherCommonNames: otherCommonNames,
            originalNameCombination: originalNameCombination,
            authoritySpeciesCitation: authoritySpeciesCitation,
            authoritySpeciesLink: authoritySpeciesLink,
            typeVoucher: typeVoucher,
            typeKind: typeKind,
            typeVoucherURIs: typeVoucherURIs,
            typeLocality: typeLocality,
            typeLocalityLatitude: typeLocalityLatitude,
            typeLocalityLongitude: typeLocalityLongitude,
            nominalNames: nominalNames,
            taxonomyNotes: taxonomyNotes,
            taxonomyNotesCitation: taxonomyNotesCitation,
            distributionNotes: distributionNotes,
            distributionNotesCitation: distributionNotesCitation,
            subregionDistribution: subregionDistribution,
            countryDistribution: countryDistribution,
            continentDistribution: continentDistribution,
            biogeographicRealm: biogeographicRealm,
            iucnStatus: iucnStatus,
            extinct: extinct,
            domestic: domestic,
            flagged: flagged,
            cMWSciName: cMWSciName,
            diffSinceCMW: diffSinceCMW,
            mSW3Matchtype: mSW3Matchtype,
            mSW3SciName: mSW3SciName,
            diffSinceMSW3: diffSinceMSW3,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> phylosort = const Value.absent(),
            Value<String?> subclass = const Value.absent(),
            Value<String?> infraclass = const Value.absent(),
            Value<String?> magnorder = const Value.absent(),
            Value<String?> superorder = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> suborder = const Value.absent(),
            Value<String?> infraorder = const Value.absent(),
            Value<String?> parvorder = const Value.absent(),
            Value<String?> superfamily = const Value.absent(),
            Value<String?> family = const Value.absent(),
            Value<String?> subfamily = const Value.absent(),
            Value<String?> tribe = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> subgenus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> sciName = const Value.absent(),
            Value<String?> authoritySpeciesAuthor = const Value.absent(),
            Value<int?> authoritySpeciesYear = const Value.absent(),
            Value<int?> authorityParentheses = const Value.absent(),
            Value<String?> mainCommonName = const Value.absent(),
            Value<String?> otherCommonNames = const Value.absent(),
            Value<String?> originalNameCombination = const Value.absent(),
            Value<String?> authoritySpeciesCitation = const Value.absent(),
            Value<String?> authoritySpeciesLink = const Value.absent(),
            Value<String?> typeVoucher = const Value.absent(),
            Value<String?> typeKind = const Value.absent(),
            Value<String?> typeVoucherURIs = const Value.absent(),
            Value<String?> typeLocality = const Value.absent(),
            Value<String?> typeLocalityLatitude = const Value.absent(),
            Value<String?> typeLocalityLongitude = const Value.absent(),
            Value<String?> nominalNames = const Value.absent(),
            Value<String?> taxonomyNotes = const Value.absent(),
            Value<String?> taxonomyNotesCitation = const Value.absent(),
            Value<String?> distributionNotes = const Value.absent(),
            Value<String?> distributionNotesCitation = const Value.absent(),
            Value<String?> subregionDistribution = const Value.absent(),
            Value<String?> countryDistribution = const Value.absent(),
            Value<String?> continentDistribution = const Value.absent(),
            Value<String?> biogeographicRealm = const Value.absent(),
            Value<String?> iucnStatus = const Value.absent(),
            Value<String?> extinct = const Value.absent(),
            Value<String?> domestic = const Value.absent(),
            Value<String?> flagged = const Value.absent(),
            Value<String?> cMWSciName = const Value.absent(),
            Value<String?> diffSinceCMW = const Value.absent(),
            Value<String?> mSW3Matchtype = const Value.absent(),
            Value<String?> mSW3SciName = const Value.absent(),
            Value<String?> diffSinceMSW3 = const Value.absent(),
          }) =>
              TaxonomyCompanion.insert(
            id: id,
            phylosort: phylosort,
            subclass: subclass,
            infraclass: infraclass,
            magnorder: magnorder,
            superorder: superorder,
            taxonOrder: taxonOrder,
            suborder: suborder,
            infraorder: infraorder,
            parvorder: parvorder,
            superfamily: superfamily,
            family: family,
            subfamily: subfamily,
            tribe: tribe,
            genus: genus,
            subgenus: subgenus,
            specificEpithet: specificEpithet,
            sciName: sciName,
            authoritySpeciesAuthor: authoritySpeciesAuthor,
            authoritySpeciesYear: authoritySpeciesYear,
            authorityParentheses: authorityParentheses,
            mainCommonName: mainCommonName,
            otherCommonNames: otherCommonNames,
            originalNameCombination: originalNameCombination,
            authoritySpeciesCitation: authoritySpeciesCitation,
            authoritySpeciesLink: authoritySpeciesLink,
            typeVoucher: typeVoucher,
            typeKind: typeKind,
            typeVoucherURIs: typeVoucherURIs,
            typeLocality: typeLocality,
            typeLocalityLatitude: typeLocalityLatitude,
            typeLocalityLongitude: typeLocalityLongitude,
            nominalNames: nominalNames,
            taxonomyNotes: taxonomyNotes,
            taxonomyNotesCitation: taxonomyNotesCitation,
            distributionNotes: distributionNotes,
            distributionNotesCitation: distributionNotesCitation,
            subregionDistribution: subregionDistribution,
            countryDistribution: countryDistribution,
            continentDistribution: continentDistribution,
            biogeographicRealm: biogeographicRealm,
            iucnStatus: iucnStatus,
            extinct: extinct,
            domestic: domestic,
            flagged: flagged,
            cMWSciName: cMWSciName,
            diffSinceCMW: diffSinceCMW,
            mSW3Matchtype: mSW3Matchtype,
            mSW3SciName: mSW3SciName,
            diffSinceMSW3: diffSinceMSW3,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $TaxonomyProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyAnnotationComposer,
    $TaxonomyCreateCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder,
    (TaxonomyData, BaseReferences<_$AppDatabase, Taxonomy, TaxonomyData>),
    TaxonomyData,
    PrefetchHooks Function()>;
typedef $SynonymCreateCompanionBuilder = SynonymCompanion Function({
  Value<int?> synId,
  Value<int?> hespId,
  Value<int?> speciesId,
  Value<String?> species,
  Value<String?> rootName,
  Value<String?> author,
  Value<String?> year,
  Value<int?> authorityParentheses,
  Value<String?> nomenclatureStatus,
  Value<String?> validity,
  Value<String?> originalCombination,
  Value<String?> originalRank,
  Value<String?> authorityCitation,
  Value<String?> uncheckedAuthorityCitation,
  Value<String?> sourcedUnverifiedCitations,
  Value<String?> citationGroup,
  Value<String?> citationKind,
  Value<String?> authorityPage,
  Value<String?> authorityLink,
  Value<String?> authorityPageLink,
  Value<String?> uncheckedAuthorityPageLink,
  Value<String?> oldTypeLocality,
  Value<String?> originalTypeLocality,
  Value<String?> uncheckedTypeLocality,
  Value<String?> emendedTypeLocality,
  Value<String?> typeLatitude,
  Value<String?> typeLongitude,
  Value<String?> typeCountry,
  Value<String?> typeSubregion,
  Value<String?> typeSubregion2,
  Value<String?> holotype,
  Value<String?> typeKind,
  Value<String?> typeSpecimenLink,
  Value<String?> taxonOrder,
  Value<String?> family,
  Value<String?> genus,
  Value<String?> specificEpithet,
  Value<String?> subspecificEpithet,
  Value<String?> variantOf,
  Value<String?> seniorHomonym,
  Value<String?> variantNameCitations,
  Value<String?> nameUsages,
  Value<String?> comments,
  Value<int> rowid,
});
typedef $SynonymUpdateCompanionBuilder = SynonymCompanion Function({
  Value<int?> synId,
  Value<int?> hespId,
  Value<int?> speciesId,
  Value<String?> species,
  Value<String?> rootName,
  Value<String?> author,
  Value<String?> year,
  Value<int?> authorityParentheses,
  Value<String?> nomenclatureStatus,
  Value<String?> validity,
  Value<String?> originalCombination,
  Value<String?> originalRank,
  Value<String?> authorityCitation,
  Value<String?> uncheckedAuthorityCitation,
  Value<String?> sourcedUnverifiedCitations,
  Value<String?> citationGroup,
  Value<String?> citationKind,
  Value<String?> authorityPage,
  Value<String?> authorityLink,
  Value<String?> authorityPageLink,
  Value<String?> uncheckedAuthorityPageLink,
  Value<String?> oldTypeLocality,
  Value<String?> originalTypeLocality,
  Value<String?> uncheckedTypeLocality,
  Value<String?> emendedTypeLocality,
  Value<String?> typeLatitude,
  Value<String?> typeLongitude,
  Value<String?> typeCountry,
  Value<String?> typeSubregion,
  Value<String?> typeSubregion2,
  Value<String?> holotype,
  Value<String?> typeKind,
  Value<String?> typeSpecimenLink,
  Value<String?> taxonOrder,
  Value<String?> family,
  Value<String?> genus,
  Value<String?> specificEpithet,
  Value<String?> subspecificEpithet,
  Value<String?> variantOf,
  Value<String?> seniorHomonym,
  Value<String?> variantNameCitations,
  Value<String?> nameUsages,
  Value<String?> comments,
  Value<int> rowid,
});

class $SynonymFilterComposer extends Composer<_$AppDatabase, Synonym> {
  $SynonymFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get synId => $composableBuilder(
      column: $table.synId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hespId => $composableBuilder(
      column: $table.hespId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speciesId => $composableBuilder(
      column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rootName => $composableBuilder(
      column: $table.rootName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nomenclatureStatus => $composableBuilder(
      column: $table.nomenclatureStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validity => $composableBuilder(
      column: $table.validity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalCombination => $composableBuilder(
      column: $table.originalCombination,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalRank => $composableBuilder(
      column: $table.originalRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityCitation => $composableBuilder(
      column: $table.authorityCitation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uncheckedAuthorityCitation => $composableBuilder(
      column: $table.uncheckedAuthorityCitation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourcedUnverifiedCitations => $composableBuilder(
      column: $table.sourcedUnverifiedCitations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citationGroup => $composableBuilder(
      column: $table.citationGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citationKind => $composableBuilder(
      column: $table.citationKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityPage => $composableBuilder(
      column: $table.authorityPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityLink => $composableBuilder(
      column: $table.authorityLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityPageLink => $composableBuilder(
      column: $table.authorityPageLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uncheckedAuthorityPageLink => $composableBuilder(
      column: $table.uncheckedAuthorityPageLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get oldTypeLocality => $composableBuilder(
      column: $table.oldTypeLocality,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalTypeLocality => $composableBuilder(
      column: $table.originalTypeLocality,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uncheckedTypeLocality => $composableBuilder(
      column: $table.uncheckedTypeLocality,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emendedTypeLocality => $composableBuilder(
      column: $table.emendedTypeLocality,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeLatitude => $composableBuilder(
      column: $table.typeLatitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeLongitude => $composableBuilder(
      column: $table.typeLongitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeCountry => $composableBuilder(
      column: $table.typeCountry, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeSubregion => $composableBuilder(
      column: $table.typeSubregion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeSubregion2 => $composableBuilder(
      column: $table.typeSubregion2,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get holotype => $composableBuilder(
      column: $table.holotype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeKind => $composableBuilder(
      column: $table.typeKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeSpecimenLink => $composableBuilder(
      column: $table.typeSpecimenLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subspecificEpithet => $composableBuilder(
      column: $table.subspecificEpithet,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantOf => $composableBuilder(
      column: $table.variantOf, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seniorHomonym => $composableBuilder(
      column: $table.seniorHomonym, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variantNameCitations => $composableBuilder(
      column: $table.variantNameCitations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameUsages => $composableBuilder(
      column: $table.nameUsages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnFilters(column));
}

class $SynonymOrderingComposer extends Composer<_$AppDatabase, Synonym> {
  $SynonymOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get synId => $composableBuilder(
      column: $table.synId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hespId => $composableBuilder(
      column: $table.hespId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speciesId => $composableBuilder(
      column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rootName => $composableBuilder(
      column: $table.rootName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nomenclatureStatus => $composableBuilder(
      column: $table.nomenclatureStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validity => $composableBuilder(
      column: $table.validity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalCombination => $composableBuilder(
      column: $table.originalCombination,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalRank => $composableBuilder(
      column: $table.originalRank,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityCitation => $composableBuilder(
      column: $table.authorityCitation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uncheckedAuthorityCitation => $composableBuilder(
      column: $table.uncheckedAuthorityCitation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourcedUnverifiedCitations => $composableBuilder(
      column: $table.sourcedUnverifiedCitations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citationGroup => $composableBuilder(
      column: $table.citationGroup,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citationKind => $composableBuilder(
      column: $table.citationKind,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityPage => $composableBuilder(
      column: $table.authorityPage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityLink => $composableBuilder(
      column: $table.authorityLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityPageLink => $composableBuilder(
      column: $table.authorityPageLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uncheckedAuthorityPageLink => $composableBuilder(
      column: $table.uncheckedAuthorityPageLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oldTypeLocality => $composableBuilder(
      column: $table.oldTypeLocality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalTypeLocality => $composableBuilder(
      column: $table.originalTypeLocality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uncheckedTypeLocality => $composableBuilder(
      column: $table.uncheckedTypeLocality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emendedTypeLocality => $composableBuilder(
      column: $table.emendedTypeLocality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeLatitude => $composableBuilder(
      column: $table.typeLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeLongitude => $composableBuilder(
      column: $table.typeLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeCountry => $composableBuilder(
      column: $table.typeCountry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeSubregion => $composableBuilder(
      column: $table.typeSubregion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeSubregion2 => $composableBuilder(
      column: $table.typeSubregion2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get holotype => $composableBuilder(
      column: $table.holotype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeKind => $composableBuilder(
      column: $table.typeKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeSpecimenLink => $composableBuilder(
      column: $table.typeSpecimenLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subspecificEpithet => $composableBuilder(
      column: $table.subspecificEpithet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantOf => $composableBuilder(
      column: $table.variantOf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seniorHomonym => $composableBuilder(
      column: $table.seniorHomonym,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variantNameCitations => $composableBuilder(
      column: $table.variantNameCitations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameUsages => $composableBuilder(
      column: $table.nameUsages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnOrderings(column));
}

class $SynonymAnnotationComposer extends Composer<_$AppDatabase, Synonym> {
  $SynonymAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get synId =>
      $composableBuilder(column: $table.synId, builder: (column) => column);

  GeneratedColumn<int> get hespId =>
      $composableBuilder(column: $table.hespId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get rootName =>
      $composableBuilder(column: $table.rootName, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get authorityParentheses => $composableBuilder(
      column: $table.authorityParentheses, builder: (column) => column);

  GeneratedColumn<String> get nomenclatureStatus => $composableBuilder(
      column: $table.nomenclatureStatus, builder: (column) => column);

  GeneratedColumn<String> get validity =>
      $composableBuilder(column: $table.validity, builder: (column) => column);

  GeneratedColumn<String> get originalCombination => $composableBuilder(
      column: $table.originalCombination, builder: (column) => column);

  GeneratedColumn<String> get originalRank => $composableBuilder(
      column: $table.originalRank, builder: (column) => column);

  GeneratedColumn<String> get authorityCitation => $composableBuilder(
      column: $table.authorityCitation, builder: (column) => column);

  GeneratedColumn<String> get uncheckedAuthorityCitation => $composableBuilder(
      column: $table.uncheckedAuthorityCitation, builder: (column) => column);

  GeneratedColumn<String> get sourcedUnverifiedCitations => $composableBuilder(
      column: $table.sourcedUnverifiedCitations, builder: (column) => column);

  GeneratedColumn<String> get citationGroup => $composableBuilder(
      column: $table.citationGroup, builder: (column) => column);

  GeneratedColumn<String> get citationKind => $composableBuilder(
      column: $table.citationKind, builder: (column) => column);

  GeneratedColumn<String> get authorityPage => $composableBuilder(
      column: $table.authorityPage, builder: (column) => column);

  GeneratedColumn<String> get authorityLink => $composableBuilder(
      column: $table.authorityLink, builder: (column) => column);

  GeneratedColumn<String> get authorityPageLink => $composableBuilder(
      column: $table.authorityPageLink, builder: (column) => column);

  GeneratedColumn<String> get uncheckedAuthorityPageLink => $composableBuilder(
      column: $table.uncheckedAuthorityPageLink, builder: (column) => column);

  GeneratedColumn<String> get oldTypeLocality => $composableBuilder(
      column: $table.oldTypeLocality, builder: (column) => column);

  GeneratedColumn<String> get originalTypeLocality => $composableBuilder(
      column: $table.originalTypeLocality, builder: (column) => column);

  GeneratedColumn<String> get uncheckedTypeLocality => $composableBuilder(
      column: $table.uncheckedTypeLocality, builder: (column) => column);

  GeneratedColumn<String> get emendedTypeLocality => $composableBuilder(
      column: $table.emendedTypeLocality, builder: (column) => column);

  GeneratedColumn<String> get typeLatitude => $composableBuilder(
      column: $table.typeLatitude, builder: (column) => column);

  GeneratedColumn<String> get typeLongitude => $composableBuilder(
      column: $table.typeLongitude, builder: (column) => column);

  GeneratedColumn<String> get typeCountry => $composableBuilder(
      column: $table.typeCountry, builder: (column) => column);

  GeneratedColumn<String> get typeSubregion => $composableBuilder(
      column: $table.typeSubregion, builder: (column) => column);

  GeneratedColumn<String> get typeSubregion2 => $composableBuilder(
      column: $table.typeSubregion2, builder: (column) => column);

  GeneratedColumn<String> get holotype =>
      $composableBuilder(column: $table.holotype, builder: (column) => column);

  GeneratedColumn<String> get typeKind =>
      $composableBuilder(column: $table.typeKind, builder: (column) => column);

  GeneratedColumn<String> get typeSpecimenLink => $composableBuilder(
      column: $table.typeSpecimenLink, builder: (column) => column);

  GeneratedColumn<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get genus =>
      $composableBuilder(column: $table.genus, builder: (column) => column);

  GeneratedColumn<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet, builder: (column) => column);

  GeneratedColumn<String> get subspecificEpithet => $composableBuilder(
      column: $table.subspecificEpithet, builder: (column) => column);

  GeneratedColumn<String> get variantOf =>
      $composableBuilder(column: $table.variantOf, builder: (column) => column);

  GeneratedColumn<String> get seniorHomonym => $composableBuilder(
      column: $table.seniorHomonym, builder: (column) => column);

  GeneratedColumn<String> get variantNameCitations => $composableBuilder(
      column: $table.variantNameCitations, builder: (column) => column);

  GeneratedColumn<String> get nameUsages => $composableBuilder(
      column: $table.nameUsages, builder: (column) => column);

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);
}

class $SynonymTableManager extends RootTableManager<
    _$AppDatabase,
    Synonym,
    SynonymData,
    $SynonymFilterComposer,
    $SynonymOrderingComposer,
    $SynonymAnnotationComposer,
    $SynonymCreateCompanionBuilder,
    $SynonymUpdateCompanionBuilder,
    (SynonymData, BaseReferences<_$AppDatabase, Synonym, SynonymData>),
    SynonymData,
    PrefetchHooks Function()> {
  $SynonymTableManager(_$AppDatabase db, Synonym table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SynonymFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SynonymOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SynonymAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> synId = const Value.absent(),
            Value<int?> hespId = const Value.absent(),
            Value<int?> speciesId = const Value.absent(),
            Value<String?> species = const Value.absent(),
            Value<String?> rootName = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> year = const Value.absent(),
            Value<int?> authorityParentheses = const Value.absent(),
            Value<String?> nomenclatureStatus = const Value.absent(),
            Value<String?> validity = const Value.absent(),
            Value<String?> originalCombination = const Value.absent(),
            Value<String?> originalRank = const Value.absent(),
            Value<String?> authorityCitation = const Value.absent(),
            Value<String?> uncheckedAuthorityCitation = const Value.absent(),
            Value<String?> sourcedUnverifiedCitations = const Value.absent(),
            Value<String?> citationGroup = const Value.absent(),
            Value<String?> citationKind = const Value.absent(),
            Value<String?> authorityPage = const Value.absent(),
            Value<String?> authorityLink = const Value.absent(),
            Value<String?> authorityPageLink = const Value.absent(),
            Value<String?> uncheckedAuthorityPageLink = const Value.absent(),
            Value<String?> oldTypeLocality = const Value.absent(),
            Value<String?> originalTypeLocality = const Value.absent(),
            Value<String?> uncheckedTypeLocality = const Value.absent(),
            Value<String?> emendedTypeLocality = const Value.absent(),
            Value<String?> typeLatitude = const Value.absent(),
            Value<String?> typeLongitude = const Value.absent(),
            Value<String?> typeCountry = const Value.absent(),
            Value<String?> typeSubregion = const Value.absent(),
            Value<String?> typeSubregion2 = const Value.absent(),
            Value<String?> holotype = const Value.absent(),
            Value<String?> typeKind = const Value.absent(),
            Value<String?> typeSpecimenLink = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> family = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> subspecificEpithet = const Value.absent(),
            Value<String?> variantOf = const Value.absent(),
            Value<String?> seniorHomonym = const Value.absent(),
            Value<String?> variantNameCitations = const Value.absent(),
            Value<String?> nameUsages = const Value.absent(),
            Value<String?> comments = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SynonymCompanion(
            synId: synId,
            hespId: hespId,
            speciesId: speciesId,
            species: species,
            rootName: rootName,
            author: author,
            year: year,
            authorityParentheses: authorityParentheses,
            nomenclatureStatus: nomenclatureStatus,
            validity: validity,
            originalCombination: originalCombination,
            originalRank: originalRank,
            authorityCitation: authorityCitation,
            uncheckedAuthorityCitation: uncheckedAuthorityCitation,
            sourcedUnverifiedCitations: sourcedUnverifiedCitations,
            citationGroup: citationGroup,
            citationKind: citationKind,
            authorityPage: authorityPage,
            authorityLink: authorityLink,
            authorityPageLink: authorityPageLink,
            uncheckedAuthorityPageLink: uncheckedAuthorityPageLink,
            oldTypeLocality: oldTypeLocality,
            originalTypeLocality: originalTypeLocality,
            uncheckedTypeLocality: uncheckedTypeLocality,
            emendedTypeLocality: emendedTypeLocality,
            typeLatitude: typeLatitude,
            typeLongitude: typeLongitude,
            typeCountry: typeCountry,
            typeSubregion: typeSubregion,
            typeSubregion2: typeSubregion2,
            holotype: holotype,
            typeKind: typeKind,
            typeSpecimenLink: typeSpecimenLink,
            taxonOrder: taxonOrder,
            family: family,
            genus: genus,
            specificEpithet: specificEpithet,
            subspecificEpithet: subspecificEpithet,
            variantOf: variantOf,
            seniorHomonym: seniorHomonym,
            variantNameCitations: variantNameCitations,
            nameUsages: nameUsages,
            comments: comments,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<int?> synId = const Value.absent(),
            Value<int?> hespId = const Value.absent(),
            Value<int?> speciesId = const Value.absent(),
            Value<String?> species = const Value.absent(),
            Value<String?> rootName = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> year = const Value.absent(),
            Value<int?> authorityParentheses = const Value.absent(),
            Value<String?> nomenclatureStatus = const Value.absent(),
            Value<String?> validity = const Value.absent(),
            Value<String?> originalCombination = const Value.absent(),
            Value<String?> originalRank = const Value.absent(),
            Value<String?> authorityCitation = const Value.absent(),
            Value<String?> uncheckedAuthorityCitation = const Value.absent(),
            Value<String?> sourcedUnverifiedCitations = const Value.absent(),
            Value<String?> citationGroup = const Value.absent(),
            Value<String?> citationKind = const Value.absent(),
            Value<String?> authorityPage = const Value.absent(),
            Value<String?> authorityLink = const Value.absent(),
            Value<String?> authorityPageLink = const Value.absent(),
            Value<String?> uncheckedAuthorityPageLink = const Value.absent(),
            Value<String?> oldTypeLocality = const Value.absent(),
            Value<String?> originalTypeLocality = const Value.absent(),
            Value<String?> uncheckedTypeLocality = const Value.absent(),
            Value<String?> emendedTypeLocality = const Value.absent(),
            Value<String?> typeLatitude = const Value.absent(),
            Value<String?> typeLongitude = const Value.absent(),
            Value<String?> typeCountry = const Value.absent(),
            Value<String?> typeSubregion = const Value.absent(),
            Value<String?> typeSubregion2 = const Value.absent(),
            Value<String?> holotype = const Value.absent(),
            Value<String?> typeKind = const Value.absent(),
            Value<String?> typeSpecimenLink = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> family = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> subspecificEpithet = const Value.absent(),
            Value<String?> variantOf = const Value.absent(),
            Value<String?> seniorHomonym = const Value.absent(),
            Value<String?> variantNameCitations = const Value.absent(),
            Value<String?> nameUsages = const Value.absent(),
            Value<String?> comments = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SynonymCompanion.insert(
            synId: synId,
            hespId: hespId,
            speciesId: speciesId,
            species: species,
            rootName: rootName,
            author: author,
            year: year,
            authorityParentheses: authorityParentheses,
            nomenclatureStatus: nomenclatureStatus,
            validity: validity,
            originalCombination: originalCombination,
            originalRank: originalRank,
            authorityCitation: authorityCitation,
            uncheckedAuthorityCitation: uncheckedAuthorityCitation,
            sourcedUnverifiedCitations: sourcedUnverifiedCitations,
            citationGroup: citationGroup,
            citationKind: citationKind,
            authorityPage: authorityPage,
            authorityLink: authorityLink,
            authorityPageLink: authorityPageLink,
            uncheckedAuthorityPageLink: uncheckedAuthorityPageLink,
            oldTypeLocality: oldTypeLocality,
            originalTypeLocality: originalTypeLocality,
            uncheckedTypeLocality: uncheckedTypeLocality,
            emendedTypeLocality: emendedTypeLocality,
            typeLatitude: typeLatitude,
            typeLongitude: typeLongitude,
            typeCountry: typeCountry,
            typeSubregion: typeSubregion,
            typeSubregion2: typeSubregion2,
            holotype: holotype,
            typeKind: typeKind,
            typeSpecimenLink: typeSpecimenLink,
            taxonOrder: taxonOrder,
            family: family,
            genus: genus,
            specificEpithet: specificEpithet,
            subspecificEpithet: subspecificEpithet,
            variantOf: variantOf,
            seniorHomonym: seniorHomonym,
            variantNameCitations: variantNameCitations,
            nameUsages: nameUsages,
            comments: comments,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $SynonymProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    Synonym,
    SynonymData,
    $SynonymFilterComposer,
    $SynonymOrderingComposer,
    $SynonymAnnotationComposer,
    $SynonymCreateCompanionBuilder,
    $SynonymUpdateCompanionBuilder,
    (SynonymData, BaseReferences<_$AppDatabase, Synonym, SynonymData>),
    SynonymData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $MddInfoTableManager get mddInfo => $MddInfoTableManager(_db, _db.mddInfo);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db, _db.taxonomy);
  $SynonymTableManager get synonym => $SynonymTableManager(_db, _db.synonym);
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

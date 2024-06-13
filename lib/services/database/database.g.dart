// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  late final GeneratedColumn<String> authoritySpeciesYear =
      GeneratedColumn<String>('authoritySpeciesYear', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _authorityParenthesesMeta =
      const VerificationMeta('authorityParentheses');
  late final GeneratedColumn<String> authorityParentheses =
      GeneratedColumn<String>('authorityParentheses', aliasedName, true,
          type: DriftSqlType.string,
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
  static const VerificationMeta _holotypeVoucherMeta =
      const VerificationMeta('holotypeVoucher');
  late final GeneratedColumn<String> holotypeVoucher = GeneratedColumn<String>(
      'holotypeVoucher', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _holotypeVoucherURIsMeta =
      const VerificationMeta('holotypeVoucherURIs');
  late final GeneratedColumn<String> holotypeVoucherURIs =
      GeneratedColumn<String>('holotypeVoucherURIs', aliasedName, true,
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
        holotypeVoucher,
        holotypeVoucherURIs,
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
    if (data.containsKey('holotypeVoucher')) {
      context.handle(
          _holotypeVoucherMeta,
          holotypeVoucher.isAcceptableOrUnknown(
              data['holotypeVoucher']!, _holotypeVoucherMeta));
    }
    if (data.containsKey('holotypeVoucherURIs')) {
      context.handle(
          _holotypeVoucherURIsMeta,
          holotypeVoucherURIs.isAcceptableOrUnknown(
              data['holotypeVoucherURIs']!, _holotypeVoucherURIsMeta));
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
          DriftSqlType.string, data['${effectivePrefix}authoritySpeciesYear']),
      authorityParentheses: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}authorityParentheses']),
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
      holotypeVoucher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}holotypeVoucher']),
      holotypeVoucherURIs: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}holotypeVoucherURIs']),
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
  final String? authoritySpeciesYear;
  final String? authorityParentheses;
  final String? mainCommonName;
  final String? otherCommonNames;
  final String? originalNameCombination;
  final String? authoritySpeciesCitation;
  final String? authoritySpeciesLink;
  final String? holotypeVoucher;
  final String? holotypeVoucherURIs;
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
      this.holotypeVoucher,
      this.holotypeVoucherURIs,
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
      map['authoritySpeciesYear'] = Variable<String>(authoritySpeciesYear);
    }
    if (!nullToAbsent || authorityParentheses != null) {
      map['authorityParentheses'] = Variable<String>(authorityParentheses);
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
    if (!nullToAbsent || holotypeVoucher != null) {
      map['holotypeVoucher'] = Variable<String>(holotypeVoucher);
    }
    if (!nullToAbsent || holotypeVoucherURIs != null) {
      map['holotypeVoucherURIs'] = Variable<String>(holotypeVoucherURIs);
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
      holotypeVoucher: holotypeVoucher == null && nullToAbsent
          ? const Value.absent()
          : Value(holotypeVoucher),
      holotypeVoucherURIs: holotypeVoucherURIs == null && nullToAbsent
          ? const Value.absent()
          : Value(holotypeVoucherURIs),
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
          serializer.fromJson<String?>(json['authoritySpeciesYear']),
      authorityParentheses:
          serializer.fromJson<String?>(json['authorityParentheses']),
      mainCommonName: serializer.fromJson<String?>(json['mainCommonName']),
      otherCommonNames: serializer.fromJson<String?>(json['otherCommonNames']),
      originalNameCombination:
          serializer.fromJson<String?>(json['originalNameCombination']),
      authoritySpeciesCitation:
          serializer.fromJson<String?>(json['authoritySpeciesCitation']),
      authoritySpeciesLink:
          serializer.fromJson<String?>(json['authoritySpeciesLink']),
      holotypeVoucher: serializer.fromJson<String?>(json['holotypeVoucher']),
      holotypeVoucherURIs:
          serializer.fromJson<String?>(json['holotypeVoucherURIs']),
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
      'authoritySpeciesYear': serializer.toJson<String?>(authoritySpeciesYear),
      'authorityParentheses': serializer.toJson<String?>(authorityParentheses),
      'mainCommonName': serializer.toJson<String?>(mainCommonName),
      'otherCommonNames': serializer.toJson<String?>(otherCommonNames),
      'originalNameCombination':
          serializer.toJson<String?>(originalNameCombination),
      'authoritySpeciesCitation':
          serializer.toJson<String?>(authoritySpeciesCitation),
      'authoritySpeciesLink': serializer.toJson<String?>(authoritySpeciesLink),
      'holotypeVoucher': serializer.toJson<String?>(holotypeVoucher),
      'holotypeVoucherURIs': serializer.toJson<String?>(holotypeVoucherURIs),
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
          Value<String?> authoritySpeciesYear = const Value.absent(),
          Value<String?> authorityParentheses = const Value.absent(),
          Value<String?> mainCommonName = const Value.absent(),
          Value<String?> otherCommonNames = const Value.absent(),
          Value<String?> originalNameCombination = const Value.absent(),
          Value<String?> authoritySpeciesCitation = const Value.absent(),
          Value<String?> authoritySpeciesLink = const Value.absent(),
          Value<String?> holotypeVoucher = const Value.absent(),
          Value<String?> holotypeVoucherURIs = const Value.absent(),
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
        holotypeVoucher: holotypeVoucher.present
            ? holotypeVoucher.value
            : this.holotypeVoucher,
        holotypeVoucherURIs: holotypeVoucherURIs.present
            ? holotypeVoucherURIs.value
            : this.holotypeVoucherURIs,
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
          ..write('holotypeVoucher: $holotypeVoucher, ')
          ..write('holotypeVoucherURIs: $holotypeVoucherURIs, ')
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
        holotypeVoucher,
        holotypeVoucherURIs,
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
          other.holotypeVoucher == this.holotypeVoucher &&
          other.holotypeVoucherURIs == this.holotypeVoucherURIs &&
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
  final Value<String?> authoritySpeciesYear;
  final Value<String?> authorityParentheses;
  final Value<String?> mainCommonName;
  final Value<String?> otherCommonNames;
  final Value<String?> originalNameCombination;
  final Value<String?> authoritySpeciesCitation;
  final Value<String?> authoritySpeciesLink;
  final Value<String?> holotypeVoucher;
  final Value<String?> holotypeVoucherURIs;
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
    this.holotypeVoucher = const Value.absent(),
    this.holotypeVoucherURIs = const Value.absent(),
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
    this.holotypeVoucher = const Value.absent(),
    this.holotypeVoucherURIs = const Value.absent(),
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
    Expression<String>? authoritySpeciesYear,
    Expression<String>? authorityParentheses,
    Expression<String>? mainCommonName,
    Expression<String>? otherCommonNames,
    Expression<String>? originalNameCombination,
    Expression<String>? authoritySpeciesCitation,
    Expression<String>? authoritySpeciesLink,
    Expression<String>? holotypeVoucher,
    Expression<String>? holotypeVoucherURIs,
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
      if (holotypeVoucher != null) 'holotypeVoucher': holotypeVoucher,
      if (holotypeVoucherURIs != null)
        'holotypeVoucherURIs': holotypeVoucherURIs,
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
      Value<String?>? authoritySpeciesYear,
      Value<String?>? authorityParentheses,
      Value<String?>? mainCommonName,
      Value<String?>? otherCommonNames,
      Value<String?>? originalNameCombination,
      Value<String?>? authoritySpeciesCitation,
      Value<String?>? authoritySpeciesLink,
      Value<String?>? holotypeVoucher,
      Value<String?>? holotypeVoucherURIs,
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
      holotypeVoucher: holotypeVoucher ?? this.holotypeVoucher,
      holotypeVoucherURIs: holotypeVoucherURIs ?? this.holotypeVoucherURIs,
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
      map['authoritySpeciesYear'] =
          Variable<String>(authoritySpeciesYear.value);
    }
    if (authorityParentheses.present) {
      map['authorityParentheses'] =
          Variable<String>(authorityParentheses.value);
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
    if (holotypeVoucher.present) {
      map['holotypeVoucher'] = Variable<String>(holotypeVoucher.value);
    }
    if (holotypeVoucherURIs.present) {
      map['holotypeVoucherURIs'] = Variable<String>(holotypeVoucherURIs.value);
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
          ..write('holotypeVoucher: $holotypeVoucher, ')
          ..write('holotypeVoucherURIs: $holotypeVoucherURIs, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final Taxonomy taxonomy = Taxonomy(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [taxonomy];
}

typedef $TaxonomyInsertCompanionBuilder = TaxonomyCompanion Function({
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
  Value<String?> authoritySpeciesYear,
  Value<String?> authorityParentheses,
  Value<String?> mainCommonName,
  Value<String?> otherCommonNames,
  Value<String?> originalNameCombination,
  Value<String?> authoritySpeciesCitation,
  Value<String?> authoritySpeciesLink,
  Value<String?> holotypeVoucher,
  Value<String?> holotypeVoucherURIs,
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
  Value<String?> authoritySpeciesYear,
  Value<String?> authorityParentheses,
  Value<String?> mainCommonName,
  Value<String?> otherCommonNames,
  Value<String?> originalNameCombination,
  Value<String?> authoritySpeciesCitation,
  Value<String?> authoritySpeciesLink,
  Value<String?> holotypeVoucher,
  Value<String?> holotypeVoucherURIs,
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

class $TaxonomyTableManager extends RootTableManager<
    _$AppDatabase,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyProcessedTableManager,
    $TaxonomyInsertCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder> {
  $TaxonomyTableManager(_$AppDatabase db, Taxonomy table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $TaxonomyFilterComposer(ComposerState(db, table)),
          orderingComposer: $TaxonomyOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $TaxonomyProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
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
            Value<String?> authoritySpeciesYear = const Value.absent(),
            Value<String?> authorityParentheses = const Value.absent(),
            Value<String?> mainCommonName = const Value.absent(),
            Value<String?> otherCommonNames = const Value.absent(),
            Value<String?> originalNameCombination = const Value.absent(),
            Value<String?> authoritySpeciesCitation = const Value.absent(),
            Value<String?> authoritySpeciesLink = const Value.absent(),
            Value<String?> holotypeVoucher = const Value.absent(),
            Value<String?> holotypeVoucherURIs = const Value.absent(),
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
            holotypeVoucher: holotypeVoucher,
            holotypeVoucherURIs: holotypeVoucherURIs,
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
          getInsertCompanionBuilder: ({
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
            Value<String?> authoritySpeciesYear = const Value.absent(),
            Value<String?> authorityParentheses = const Value.absent(),
            Value<String?> mainCommonName = const Value.absent(),
            Value<String?> otherCommonNames = const Value.absent(),
            Value<String?> originalNameCombination = const Value.absent(),
            Value<String?> authoritySpeciesCitation = const Value.absent(),
            Value<String?> authoritySpeciesLink = const Value.absent(),
            Value<String?> holotypeVoucher = const Value.absent(),
            Value<String?> holotypeVoucherURIs = const Value.absent(),
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
            holotypeVoucher: holotypeVoucher,
            holotypeVoucherURIs: holotypeVoucherURIs,
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
        ));
}

class $TaxonomyProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyProcessedTableManager,
    $TaxonomyInsertCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder> {
  $TaxonomyProcessedTableManager(super.$state);
}

class $TaxonomyFilterComposer extends FilterComposer<_$AppDatabase, Taxonomy> {
  $TaxonomyFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get phylosort => $state.composableBuilder(
      column: $state.table.phylosort,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subclass => $state.composableBuilder(
      column: $state.table.subclass,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get infraclass => $state.composableBuilder(
      column: $state.table.infraclass,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get magnorder => $state.composableBuilder(
      column: $state.table.magnorder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get superorder => $state.composableBuilder(
      column: $state.table.superorder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get taxonOrder => $state.composableBuilder(
      column: $state.table.taxonOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get suborder => $state.composableBuilder(
      column: $state.table.suborder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get infraorder => $state.composableBuilder(
      column: $state.table.infraorder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parvorder => $state.composableBuilder(
      column: $state.table.parvorder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get superfamily => $state.composableBuilder(
      column: $state.table.superfamily,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get family => $state.composableBuilder(
      column: $state.table.family,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subfamily => $state.composableBuilder(
      column: $state.table.subfamily,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tribe => $state.composableBuilder(
      column: $state.table.tribe,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get genus => $state.composableBuilder(
      column: $state.table.genus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subgenus => $state.composableBuilder(
      column: $state.table.subgenus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get specificEpithet => $state.composableBuilder(
      column: $state.table.specificEpithet,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sciName => $state.composableBuilder(
      column: $state.table.sciName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authoritySpeciesAuthor => $state.composableBuilder(
      column: $state.table.authoritySpeciesAuthor,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authoritySpeciesYear => $state.composableBuilder(
      column: $state.table.authoritySpeciesYear,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authorityParentheses => $state.composableBuilder(
      column: $state.table.authorityParentheses,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mainCommonName => $state.composableBuilder(
      column: $state.table.mainCommonName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get otherCommonNames => $state.composableBuilder(
      column: $state.table.otherCommonNames,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get originalNameCombination => $state.composableBuilder(
      column: $state.table.originalNameCombination,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authoritySpeciesCitation =>
      $state.composableBuilder(
          column: $state.table.authoritySpeciesCitation,
          builder: (column, joinBuilders) =>
              ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authoritySpeciesLink => $state.composableBuilder(
      column: $state.table.authoritySpeciesLink,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get holotypeVoucher => $state.composableBuilder(
      column: $state.table.holotypeVoucher,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get holotypeVoucherURIs => $state.composableBuilder(
      column: $state.table.holotypeVoucherURIs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get typeLocality => $state.composableBuilder(
      column: $state.table.typeLocality,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get typeLocalityLatitude => $state.composableBuilder(
      column: $state.table.typeLocalityLatitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get typeLocalityLongitude => $state.composableBuilder(
      column: $state.table.typeLocalityLongitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nominalNames => $state.composableBuilder(
      column: $state.table.nominalNames,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get taxonomyNotes => $state.composableBuilder(
      column: $state.table.taxonomyNotes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get taxonomyNotesCitation => $state.composableBuilder(
      column: $state.table.taxonomyNotesCitation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get distributionNotes => $state.composableBuilder(
      column: $state.table.distributionNotes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get distributionNotesCitation =>
      $state.composableBuilder(
          column: $state.table.distributionNotesCitation,
          builder: (column, joinBuilders) =>
              ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subregionDistribution => $state.composableBuilder(
      column: $state.table.subregionDistribution,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get countryDistribution => $state.composableBuilder(
      column: $state.table.countryDistribution,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get continentDistribution => $state.composableBuilder(
      column: $state.table.continentDistribution,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get biogeographicRealm => $state.composableBuilder(
      column: $state.table.biogeographicRealm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get iucnStatus => $state.composableBuilder(
      column: $state.table.iucnStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get extinct => $state.composableBuilder(
      column: $state.table.extinct,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get domestic => $state.composableBuilder(
      column: $state.table.domestic,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get flagged => $state.composableBuilder(
      column: $state.table.flagged,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cMWSciName => $state.composableBuilder(
      column: $state.table.cMWSciName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get diffSinceCMW => $state.composableBuilder(
      column: $state.table.diffSinceCMW,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mSW3Matchtype => $state.composableBuilder(
      column: $state.table.mSW3Matchtype,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mSW3SciName => $state.composableBuilder(
      column: $state.table.mSW3SciName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get diffSinceMSW3 => $state.composableBuilder(
      column: $state.table.diffSinceMSW3,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $TaxonomyOrderingComposer
    extends OrderingComposer<_$AppDatabase, Taxonomy> {
  $TaxonomyOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get phylosort => $state.composableBuilder(
      column: $state.table.phylosort,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subclass => $state.composableBuilder(
      column: $state.table.subclass,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get infraclass => $state.composableBuilder(
      column: $state.table.infraclass,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get magnorder => $state.composableBuilder(
      column: $state.table.magnorder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get superorder => $state.composableBuilder(
      column: $state.table.superorder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get taxonOrder => $state.composableBuilder(
      column: $state.table.taxonOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get suborder => $state.composableBuilder(
      column: $state.table.suborder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get infraorder => $state.composableBuilder(
      column: $state.table.infraorder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parvorder => $state.composableBuilder(
      column: $state.table.parvorder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get superfamily => $state.composableBuilder(
      column: $state.table.superfamily,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get family => $state.composableBuilder(
      column: $state.table.family,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subfamily => $state.composableBuilder(
      column: $state.table.subfamily,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tribe => $state.composableBuilder(
      column: $state.table.tribe,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get genus => $state.composableBuilder(
      column: $state.table.genus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subgenus => $state.composableBuilder(
      column: $state.table.subgenus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get specificEpithet => $state.composableBuilder(
      column: $state.table.specificEpithet,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sciName => $state.composableBuilder(
      column: $state.table.sciName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authoritySpeciesAuthor =>
      $state.composableBuilder(
          column: $state.table.authoritySpeciesAuthor,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authoritySpeciesYear => $state.composableBuilder(
      column: $state.table.authoritySpeciesYear,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authorityParentheses => $state.composableBuilder(
      column: $state.table.authorityParentheses,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mainCommonName => $state.composableBuilder(
      column: $state.table.mainCommonName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get otherCommonNames => $state.composableBuilder(
      column: $state.table.otherCommonNames,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get originalNameCombination =>
      $state.composableBuilder(
          column: $state.table.originalNameCombination,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authoritySpeciesCitation =>
      $state.composableBuilder(
          column: $state.table.authoritySpeciesCitation,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authoritySpeciesLink => $state.composableBuilder(
      column: $state.table.authoritySpeciesLink,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get holotypeVoucher => $state.composableBuilder(
      column: $state.table.holotypeVoucher,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get holotypeVoucherURIs => $state.composableBuilder(
      column: $state.table.holotypeVoucherURIs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get typeLocality => $state.composableBuilder(
      column: $state.table.typeLocality,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get typeLocalityLatitude => $state.composableBuilder(
      column: $state.table.typeLocalityLatitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get typeLocalityLongitude => $state.composableBuilder(
      column: $state.table.typeLocalityLongitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nominalNames => $state.composableBuilder(
      column: $state.table.nominalNames,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get taxonomyNotes => $state.composableBuilder(
      column: $state.table.taxonomyNotes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get taxonomyNotesCitation => $state.composableBuilder(
      column: $state.table.taxonomyNotesCitation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get distributionNotes => $state.composableBuilder(
      column: $state.table.distributionNotes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get distributionNotesCitation => $state
      .composableBuilder(
          column: $state.table.distributionNotesCitation,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subregionDistribution => $state.composableBuilder(
      column: $state.table.subregionDistribution,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get countryDistribution => $state.composableBuilder(
      column: $state.table.countryDistribution,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get continentDistribution => $state.composableBuilder(
      column: $state.table.continentDistribution,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get biogeographicRealm => $state.composableBuilder(
      column: $state.table.biogeographicRealm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get iucnStatus => $state.composableBuilder(
      column: $state.table.iucnStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get extinct => $state.composableBuilder(
      column: $state.table.extinct,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get domestic => $state.composableBuilder(
      column: $state.table.domestic,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get flagged => $state.composableBuilder(
      column: $state.table.flagged,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cMWSciName => $state.composableBuilder(
      column: $state.table.cMWSciName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get diffSinceCMW => $state.composableBuilder(
      column: $state.table.diffSinceCMW,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mSW3Matchtype => $state.composableBuilder(
      column: $state.table.mSW3Matchtype,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mSW3SciName => $state.composableBuilder(
      column: $state.table.mSW3SciName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get diffSinceMSW3 => $state.composableBuilder(
      column: $state.table.diffSinceMSW3,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db, _db.taxonomy);
}

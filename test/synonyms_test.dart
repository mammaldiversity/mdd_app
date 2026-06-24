import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/synonyms.dart';

void main() {
  group('SynonymName logic tests', () {
    test('getSynonym returns originalCombination if present', () {
      final data = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        originalCombination: 'Originalus combinatus',
        species: 'test_species',
        rootName: 'test_root',
        author: 'Smith',
        year: '2024',
        authorityParentheses: 0,
      );
      final synonymName = SynonymName(data: data);
      final result = synonymName.getSynonym();

      expect(result.name, 'Originalus combinatus');
      expect(result.authorYear, 'Smith, 2024');
    });

    test('getSynonym falls back to species and rootName', () {
      final data = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        species: 'test_species',
        rootName: 'test_root',
        author: 'Doe',
        year: '2023',
        authorityParentheses: 1,
      );
      final synonymName = SynonymName(data: data);
      final result = synonymName.getSynonym();

      expect(result.name, 'test_species test_root');
      expect(result.authorYear, 'Doe, 2023'); // Still without parentheses
    });

    test('getAuthorityCitation ignores authorityParentheses', () {
      final dataWithParentheses = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        author: 'Jones',
        year: '1999',
        authorityParentheses: 1,
      );
      expect(SynonymName(data: dataWithParentheses).getAuthorityCitation(), 'Jones, 1999');

      final dataWithoutParentheses = SynonymData(
        synId: 2,
        hespId: 1,
        speciesId: 1,
        author: 'Jones',
        year: '1999',
        authorityParentheses: 0,
      );
      expect(SynonymName(data: dataWithoutParentheses).getAuthorityCitation(), 'Jones, 1999');
    });

    test('getAuthoritySeparator handles colon-separated statuses', () {
      final dataWithColon = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        nomenclatureStatus: 'unjustified_emendation',
      );
      expect(SynonymName(data: dataWithColon).shouldSeparateSynonymAuthorityWithColon(), true);
      expect(SynonymName(data: dataWithColon).getAuthoritySeparator(), ': ');

      final dataWithColonMultiple = SynonymData(
        synId: 2,
        hespId: 1,
        speciesId: 1,
        nomenclatureStatus: 'valid | justified_emendation',
      );
      expect(SynonymName(data: dataWithColonMultiple).shouldSeparateSynonymAuthorityWithColon(), true);
      expect(SynonymName(data: dataWithColonMultiple).getAuthoritySeparator(), ': ');

      final dataWithoutColon = SynonymData(
        synId: 3,
        hespId: 1,
        speciesId: 1,
        nomenclatureStatus: 'valid',
      );
      expect(SynonymName(data: dataWithoutColon).shouldSeparateSynonymAuthorityWithColon(), false);
      expect(SynonymName(data: dataWithoutColon).getAuthoritySeparator(), ' ');
    });

    test('createStructuredTypeLocality constructs correctly', () {
      final dataLocality = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        typeCountry: 'USA',
        typeSubregion: 'Texas',
        typeLatitude: '30.2672',
        typeLongitude: '-97.7431',
      );
      
      final localityString = SynonymName(data: dataLocality).createStructuredTypeLocality();
      // 30.2672 * 3600 = 108961.92 -> 108962 -> 30 deg, 16 min, 2 sec
      // -97.7431 * 3600 = -351875.16 -> 351875 -> 97 deg, 44 min, 35 sec
      expect(localityString, 'USA: Texas: 30°16′2″N, 97°44′35″W.');
    });

    test('createStructuredTypeLocality handles missing coordinates', () {
      final dataLocality = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        typeCountry: 'Canada',
        typeSubregion: 'NA',
        typeSubregion2: 'Ontario',
      );
      
      final localityString = SynonymName(data: dataLocality).createStructuredTypeLocality();
      expect(localityString, 'Canada: Ontario.');
    });

    test('createStructuredTypeLocality handles empty data', () {
      final dataLocality = SynonymData(
        synId: 1,
        hespId: 1,
        speciesId: 1,
        typeCountry: 'NA',
      );
      
      final localityString = SynonymName(data: dataLocality).createStructuredTypeLocality();
      expect(localityString, '');
    });
  });
}

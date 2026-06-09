import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

void main() {
  group('StatisticsService Data Cleaning', () {
    test('cleanBiogeographicRealmData handles "?" suffix and aggregates correctly', () {
      final rawData = [
        StatSpeciesByBiogeographicRealmResult(name: 'Indomalaya', count: 100),
        StatSpeciesByBiogeographicRealmResult(name: 'Indomalaya?', count: 50),
        StatSpeciesByBiogeographicRealmResult(name: 'Palearctic|Indomalaya?', count: 10),
        StatSpeciesByBiogeographicRealmResult(name: 'NA', count: 999),
        StatSpeciesByBiogeographicRealmResult(name: '', count: 999),
        StatSpeciesByBiogeographicRealmResult(name: 'Afrotropic', count: 200),
      ];

      final result = StatisticsService.cleanBiogeographicRealmData(rawData);

      // Indomalaya = 100 + 50 + 10 = 160
      // Palearctic = 10
      // Afrotropic = 200
      // NA and '' are ignored
      
      expect(result.length, 3);
      
      // The result should be sorted by count descending
      expect(result[0].key, 'Afrotropic');
      expect(result[0].value, 200);
      
      expect(result[1].key, 'Indomalaya');
      expect(result[1].value, 160);
      
      expect(result[2].key, 'Palearctic');
      expect(result[2].value, 10);
    });

    test('cleanIucnStatusData removes text in parentheses and aggregates correctly', () {
      final rawData = [
        StatSpeciesByIucnStatusResult(name: 'VU', count: 50),
        StatSpeciesByIucnStatusResult(name: 'VU (vulnerable)', count: 20),
        StatSpeciesByIucnStatusResult(name: 'LC', count: 100),
        StatSpeciesByIucnStatusResult(name: 'EN (Endangered)', count: 10),
      ];

      final result = StatisticsService.cleanIucnStatusData(rawData);

      // VU = 50 + 20 = 70
      // LC = 100
      // EN = 10
      
      expect(result.length, 3);
      
      // Sorted descending
      expect(result[0].key, 'LC');
      expect(result[0].value, 100);
      
      expect(result[1].key, 'VU');
      expect(result[1].value, 70);
      
      expect(result[2].key, 'EN');
      expect(result[2].value, 10);
    });
  });
}

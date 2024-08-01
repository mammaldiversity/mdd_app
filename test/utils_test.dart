import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/utils.dart';

void main() {
  // Test the SearchFilterView class
  test('Sentence case', () {
    String input = 'hello';
    expect(input.toSentenceCase(), 'Hello');
  });
}

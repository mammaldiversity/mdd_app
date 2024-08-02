import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/utils.dart';

void main() {
  // Test the SearchFilterView class
  test('Sentence case', () {
    String input = 'hello';
    expect(input.toSentenceCase(), 'Hello');
  });

  test('Enum to sentence case', () {
    String input = 'helloWorld';
    expect(input.enumToSentenceCase(), 'Hello world');
  });
}

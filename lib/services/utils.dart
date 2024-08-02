extension StringExtension on String {
  String toSentenceCase() {
    try {
      return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
    } catch (e) {
      return '';
    }
  }

  /// Converts an enum string to a sentence case.
  /// camelCase matches are converted to 'Camel case'.
  /// It will not match camelCase that contains numbers.
  String enumToSentenceCase() {
    bool isCamelCase = contains(RegExp(r'^([a-z]+)([A-Z][a-z]+)'));
    if (isCamelCase) {
      return replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
          .toSentenceCase();
    }
    return toSentenceCase();
  }
}

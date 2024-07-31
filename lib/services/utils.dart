extension StringExtension on String {
  String toSentenceCase() {
    try {
      return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
    } catch (e) {
      return '';
    }
  }
}

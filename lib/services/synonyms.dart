//! Module to parse synonyms data from the database.

import 'package:mdd/services/database/database.dart';

class SynonymName {
  const SynonymName({required this.data});

  final SynonymData data;

  ({String name, String authorYear}) getSynonym() {
    final String name = _getNames();
    final String authorYear = getAuthorYear();
    return (name: name, authorYear: authorYear);
  }

  String _getNames() {
    if (data.originalCombination != null &&
        data.originalCombination!.isNotEmpty) {
      return data.originalCombination!;
    } else {
      final String species = data.species ?? '';
      final String rootName = data.rootName ?? '';
      return '$species $rootName';
    }
  }

  String getAuthorYear() {
    final String author = data.author ?? '';
    final String year = data.year ?? '';
    if (data.authorityParentheses == 1) {
      return '($author, $year)';
    } else {
      return '$author $year';
    }
  }
}

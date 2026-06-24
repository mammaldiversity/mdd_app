//! Module to parse synonyms data from the database.

import 'package:mdd/services/database/database.dart';

class SynonymName {
  const SynonymName({required this.data});

  final SynonymData data;

  ({String name, String authorYear}) getSynonym() {
    final String name = _getNames();
    final String authorYear = getAuthorityCitation();
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

  String getAuthorityCitation() {
    final String author = data.author ?? '';
    final String year = data.year ?? '';
    // Synonym authority citations do not use parentheses
    return '$author, $year';
  }

  bool shouldSeparateSynonymAuthorityWithColon() {
    if (data.nomenclatureStatus == null || data.nomenclatureStatus!.isEmpty) {
      return false;
    }

    final Set<String> colonSeparatedStatuses = {
      'incorrect_subsequent_spelling',
      'justified_emendation',
      'mandatory_change',
      'misidentification',
      'name_combination',
      'unjustified_emendation',
      'variant',
    };

    return data.nomenclatureStatus!
        .split('|')
        .map((status) => status.trim())
        .any((status) => colonSeparatedStatuses.contains(status));
  }

  String getAuthoritySeparator() {
    return shouldSeparateSynonymAuthorityWithColon() ? ': ' : ' ';
  }

  bool _isPresent(String? value) {
    if (value == null) return false;
    final String text = value.trim();
    return text.isNotEmpty && text != 'NA';
  }

  String? _formatCoordinate(
    String? coordinate,
    String positiveDirection,
    String negativeDirection,
  ) {
    if (!_isPresent(coordinate)) {
      return null;
    }
    final double? numericCoordinate = double.tryParse(coordinate!);
    if (numericCoordinate == null || numericCoordinate.isNaN) {
      return null;
    }

    final String direction =
        numericCoordinate >= 0 ? positiveDirection : negativeDirection;
    final int totalSeconds = (numericCoordinate.abs() * 3600).round();
    final int degrees = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (seconds > 0) {
      return '$degrees°$minutes′$seconds″$direction';
    }
    if (minutes > 0) {
      return '$degrees°$minutes′$direction';
    }
    return '$degrees°$direction';
  }

  String createStructuredTypeLocality() {
    final List<String?> localityFields = [
      data.typeCountry,
      data.typeSubregion,
      data.typeSubregion2,
    ];
    final List<String> localityParts = localityFields
        .where((part) => _isPresent(part))
        .cast<String>()
        .toList();

    final List<String?> coordinateFields = [
      _formatCoordinate(data.typeLatitude, 'N', 'S'),
      _formatCoordinate(data.typeLongitude, 'E', 'W'),
    ];
    final List<String> coordinateParts =
        coordinateFields.where((part) => part != null).cast<String>().toList();

    final List<String> parts = [
      ...localityParts,
      if (coordinateParts.isNotEmpty) coordinateParts.join(', '),
    ].where((part) => part.isNotEmpty).toList();

    return parts.isNotEmpty ? '${parts.join(': ')}.' : '';
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mdd/services/essential_url.dart';

const Map<String, String> externalRequestHeaders = {
  'User-Agent': 'MDD App ($appSourceCode)',
};

Future<Map<String, dynamic>> _getJson(http.Client client, Uri uri) async {
  final response = await client.get(uri, headers: externalRequestHeaders);
  if (response.statusCode != 200) {
    throw http.ClientException('HTTP ${response.statusCode}', uri);
  }
  return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
}

/// Formats an integer with thousands separators, e.g. 12345 -> 12,345.
String formatCount(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

class GbifSummary {
  const GbifSummary({
    required this.taxonKey,
    required this.matchedName,
    required this.occurrences,
  });

  final int taxonKey;
  final String matchedName;
  final int occurrences;
}

class GbifClient {
  const GbifClient(this.client);

  final http.Client client;

  static String densityTileUrl(int taxonKey) =>
      'https://api.gbif.org/v2/map/occurrence/density/{z}/{x}/{y}@1x.png'
      '?taxonKey=$taxonKey&srs=EPSG:3857&style=purpleYellow.point';

  static String basemapTileUrl({required bool isDark}) =>
      'https://tile.gbif.org/3857/omt/{z}/{x}/{y}@1x.png'
      '?style=${isDark ? 'gbif-dark' : 'gbif-light'}';

  static String speciesPageUrl(int taxonKey) =>
      'https://www.gbif.org/species/$taxonKey';

  /// Returns the accepted GBIF taxon key and name, or null if unmatched.
  Future<({int key, String name})?> matchSpecies(String name) async {
    final json = await _getJson(
      client,
      Uri.https('api.gbif.org', '/v1/species/match', {
        'name': name,
        'rank': 'SPECIES',
        'class': 'Mammalia',
      }),
    );
    if (json['matchType'] == 'NONE') return null;
    final int? key = (json['acceptedUsageKey'] ?? json['usageKey']) as int?;
    if (key == null) return null;
    final String matchedName =
        (json['species'] ?? json['canonicalName'] ?? name) as String;
    return (key: key, name: matchedName);
  }

  Future<int> occurrenceCount(int taxonKey) async {
    final json = await _getJson(
      client,
      Uri.https('api.gbif.org', '/v1/occurrence/search', {
        'taxonKey': '$taxonKey',
        'limit': '0',
      }),
    );
    return (json['count'] as num?)?.toInt() ?? 0;
  }

  Future<GbifSummary?> fetchSummary(String name) async {
    final match = await matchSpecies(name);
    if (match == null) return null;
    return GbifSummary(
      taxonKey: match.key,
      matchedName: match.name,
      occurrences: await occurrenceCount(match.key),
    );
  }
}

enum GenBankRecord { assemblies, genes, mitochondrial, nucleotide }

class GenBankCount {
  const GenBankCount({
    required this.record,
    required this.label,
    required this.description,
    required this.count,
    required this.url,
  });

  final GenBankRecord record;
  final String label;
  final String description;
  final int count;
  final String url;
}

class GenBankClient {
  const GenBankClient(
    this.client, {
    this.requestGap = const Duration(milliseconds: 350),
  });

  final http.Client client;

  /// Delay between requests to stay under NCBI's 3 requests/s limit.
  final Duration requestGap;

  static String organismTerm(String name) => '"$name"[Organism]';

  static String mitochondrialTerm(String name) =>
      '${organismTerm(name)} AND mitochondrion[filter]';

  static String ncbiSearchUrl(String db, String term) =>
      Uri.https('www.ncbi.nlm.nih.gov', '/$db/', {'term': term}).toString();

  static String genomeDatasetsUrl(String name) => Uri.https(
    'www.ncbi.nlm.nih.gov',
    '/datasets/genome/',
    {'taxon': name},
  ).toString();

  Future<int> count(String db, String term) async {
    final json = await _getJson(
      client,
      Uri.https('eutils.ncbi.nlm.nih.gov', '/entrez/eutils/esearch.fcgi', {
        'db': db,
        'term': term,
        'retmode': 'json',
        'rettype': 'count',
        'tool': 'mdd_app',
      }),
    );
    final result = json['esearchresult'] as Map<String, dynamic>?;
    return int.tryParse('${result?['count'] ?? 0}') ?? 0;
  }

  Future<List<GenBankCount>> fetchSummary(String name) async {
    final organism = organismTerm(name);
    final mito = mitochondrialTerm(name);
    final queries = [
      (
        record: GenBankRecord.assemblies,
        label: 'Genome assemblies',
        description: 'NCBI Assembly',
        db: 'assembly',
        term: organism,
        url: genomeDatasetsUrl(name),
      ),
      (
        record: GenBankRecord.genes,
        label: 'Genes',
        description: 'NCBI Gene records',
        db: 'gene',
        term: organism,
        url: ncbiSearchUrl('gene', organism),
      ),
      (
        record: GenBankRecord.mitochondrial,
        label: 'Mitochondrial DNA',
        description: 'Nucleotide sequences from the mitochondrion',
        db: 'nuccore',
        term: mito,
        url: ncbiSearchUrl('nuccore', mito),
      ),
      (
        record: GenBankRecord.nucleotide,
        label: 'All nucleotide sequences',
        description: 'GenBank nucleotide records',
        db: 'nuccore',
        term: organism,
        url: ncbiSearchUrl('nuccore', organism),
      ),
    ];

    final results = <GenBankCount>[];
    for (final (index, query) in queries.indexed) {
      if (index > 0 && requestGap > Duration.zero) {
        await Future<void>.delayed(requestGap);
      }
      results.add(
        GenBankCount(
          record: query.record,
          label: query.label,
          description: query.description,
          count: await count(query.db, query.term),
          url: query.url,
        ),
      );
    }
    return results;
  }
}

class CrossrefWork {
  const CrossrefWork({
    required this.title,
    required this.authors,
    required this.year,
    required this.journal,
    required this.doi,
    this.authorNames = const [],
    this.volume = '',
    this.issue = '',
    this.pages = '',
  });

  final String title;

  /// Short form for the list, e.g. "Smith et al.".
  final String authors;
  final int? year;
  final String journal;
  final String doi;

  /// Every author as "Family, G.", for the copied citation.
  final List<String> authorNames;
  final String volume;
  final String issue;
  final String pages;

  String get url => 'https://doi.org/$doi';

  /// Journal, volume (issue), pages, e.g. "J. Mammal., 101 (2), 12-20".
  String get source {
    String text = journal;
    if (volume.isNotEmpty) text += '${text.isEmpty ? '' : ', '}$volume';
    if (issue.isNotEmpty) text += ' ($issue)';
    if (pages.isNotEmpty) text += ', $pages';
    return text;
  }

  /// A plain-text citation: authors, year, title, source, DOI.
  String get citation {
    final String names = authorNames.isNotEmpty
        ? authorNames.join(', ')
        : authors;
    return [
      if (names.isNotEmpty) '$names.',
      if (year != null) '($year).',
      if (title.isNotEmpty) '${title.replaceAll(RegExp(r'\.$'), '')}.',
      if (source.isNotEmpty) '$source.',
      url,
    ].join(' ');
  }

  factory CrossrefWork.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> authorList =
        (json['author'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
    String familyOf(Map<String, dynamic> author) =>
        '${author['family'] ?? author['name'] ?? ''}'.trim();
    String authors = '';
    if (authorList.isNotEmpty) {
      authors = familyOf(authorList.first);
      if (authorList.length == 2) {
        authors += ' & ${familyOf(authorList[1])}';
      } else if (authorList.length > 2) {
        authors += ' et al.';
      }
    }
    final List<String> authorNames = [
      for (final author in authorList)
        if (familyOf(author).isNotEmpty)
          _withInitials(familyOf(author), '${author['given'] ?? ''}'),
    ];
    final List<dynamic>? dateParts =
        (json['issued'] as Map<String, dynamic>?)?['date-parts']
            as List<dynamic>?;
    final dynamic yearValue = dateParts != null && dateParts.isNotEmpty
        ? (dateParts.first as List<dynamic>?)?.firstOrNull
        : null;
    return CrossrefWork(
      title: _cleanTitle(_firstString(json['title'])),
      authors: authors,
      authorNames: authorNames,
      year: yearValue is num ? yearValue.toInt() : null,
      journal: _firstString(json['container-title']),
      volume: _firstString(json['volume']),
      issue: _firstString(json['issue']),
      pages: _firstString(json['page']),
      doi: (json['DOI'] ?? '') as String,
    );
  }

  static String _withInitials(String family, String given) {
    final String initials = given
        .split(RegExp(r'[\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}.')
        .join(' ');
    return initials.isEmpty ? family : '$family, $initials';
  }

  /// Drops publisher markup, which some deposits escape (`&lt;i&gt;`).
  static String _cleanTitle(String raw) {
    const Map<String, String> entities = {
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&nbsp;': ' ',
    };
    String title = raw;
    entities.forEach((entity, char) => title = title.replaceAll(entity, char));
    return title
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\(\s+'), '(')
        .replaceAll(RegExp(r'\s+\)'), ')')
        .trim();
  }

  static String _firstString(dynamic value) {
    if (value is List && value.isNotEmpty) return '${value.first}'.trim();
    if (value is String) return value.trim();
    return '';
  }
}

class CrossrefClient {
  const CrossrefClient(this.client);

  final http.Client client;

  static const int maxWorks = 20;

  static String searchUrl(String name) =>
      Uri.https('search.crossref.org', '/', {'q': name}).toString();

  Future<List<CrossrefWork>> fetchWorks(String name) async {
    final json = await _getJson(
      client,
      Uri.https('api.crossref.org', '/works', {
        'query.bibliographic': '"$name"',
        'rows': '40',
        'select': 'DOI,title,author,issued,container-title,volume,issue,page',
      }),
    );
    final List<dynamic> items =
        (json['message'] as Map<String, dynamic>?)?['items']
            as List<dynamic>? ??
        [];
    return filterWorks(
      items.map((e) => CrossrefWork.fromJson(e as Map<String, dynamic>)),
      name,
    );
  }

  /// Crossref relevance matching is fuzzy; keep works whose title
  /// mentions the species binomial.
  static List<CrossrefWork> filterWorks(
    Iterable<CrossrefWork> works,
    String name,
  ) {
    final String needle = name.toLowerCase();
    return works
        .where(
          (work) =>
              work.doi.isNotEmpty && work.title.toLowerCase().contains(needle),
        )
        .take(maxWorks)
        .toList();
  }

  /// Groups works by year, newest first; works without a year come last.
  static List<(int?, List<CrossrefWork>)> groupByYear(
    Iterable<CrossrefWork> works,
  ) {
    final Map<int?, List<CrossrefWork>> grouped = {};
    for (final work in works) {
      (grouped[work.year] ??= []).add(work);
    }
    final List<int?> years = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null) return b == null ? 0 : 1;
        if (b == null) return -1;
        return b.compareTo(a);
      });
    return [for (final year in years) (year, grouped[year]!)];
  }
}

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

/// A latitude/longitude box, in degrees.
typedef OccurrenceExtent = ({
  double south,
  double west,
  double north,
  double east,
});

class GbifSummary {
  const GbifSummary({
    required this.taxonKey,
    required this.matchedName,
    required this.occurrences,
    this.extent,
  });

  final int taxonKey;
  final String matchedName;
  final int occurrences;

  /// The box holding every georeferenced record; null when there are none.
  final OccurrenceExtent? extent;
}

class GbifClient {
  const GbifClient(this.client);

  final http.Client client;

  /// Density tiles of all occurrences, 512 px at @1x. Binned into
  /// hexagons: single-pixel points vanish at the zoom a whole range needs.
  static String densityTileUrl(int taxonKey) =>
      'https://api.gbif.org/v2/map/occurrence/density/{z}/{x}/{y}@1x.png'
      '?taxonKey=$taxonKey'
      '&srs=EPSG:3857&bin=hex&hexPerTile=60'
      '&style=purpleYellow-noborder.poly';

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

  /// The extent of the records drawn on the density map, from the map
  /// API's capabilities; null when the taxon has no georeferenced records.
  Future<OccurrenceExtent?> occurrenceExtent(int taxonKey) async {
    final json = await _getJson(
      client,
      Uri.https(
        'api.gbif.org',
        '/v2/map/occurrence/density/capabilities.json',
        {'taxonKey': '$taxonKey'},
      ),
    );
    if ((_asInt(json['total']) ?? 0) == 0) return null;
    final double? south = _asDouble(json['minLat']);
    final double? west = _asDouble(json['minLng']);
    final double? north = _asDouble(json['maxLat']);
    final double? east = _asDouble(json['maxLng']);
    if (south == null || west == null || north == null || east == null) {
      return null;
    }
    return (south: south, west: west, north: north, east: east);
  }

  Future<GbifSummary?> fetchSummary(String name) async {
    final match = await matchSpecies(name);
    if (match == null) return null;
    final (occurrences, extent) = await (
      occurrenceCount(match.key),
      occurrenceExtent(match.key),
    ).wait;
    return GbifSummary(
      taxonKey: match.key,
      matchedName: match.name,
      occurrences: occurrences,
      extent: extent,
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

/// A sequence length in the unit a genomicist would use, e.g. 2.30 Gb
/// rather than 2,297,552,363 bp, to three significant figures.
({String value, String unit}) formatBases(int length) {
  const scales = [(1e9, 'Gb'), (1e6, 'Mb'), (1e3, 'kb')];
  for (final (scale, unit) in scales) {
    if (length >= scale) {
      final double scaled = length / scale;
      final int digits = scaled >= 100 ? 0 : (scaled >= 10 ? 1 : 2);
      return (value: scaled.toStringAsFixed(digits), unit: unit);
    }
  }
  return (value: '$length', unit: 'bp');
}

/// A nuclear genome assembly, as NCBI Datasets reports it.
class GenomeAssembly {
  const GenomeAssembly({
    required this.accession,
    this.assemblyName,
    this.organismName,
    this.isReference = false,
    this.assemblyLevel,
    this.releaseDate,
    this.submitter,
    this.genomeSize,
    this.chromosomeCount,
    this.contigN50,
    this.gcPercent,
  });

  final String accession;
  final String? assemblyName;

  /// A subspecies when the species itself has no assembly.
  final String? organismName;

  /// NCBI's designated reference, rather than the best of the rest.
  final bool isReference;
  final String? assemblyLevel;
  final String? releaseDate;
  final String? submitter;
  final int? genomeSize;
  final int? chromosomeCount;
  final int? contigN50;
  final double? gcPercent;

  String get url => 'https://www.ncbi.nlm.nih.gov/datasets/genome/$accession/';

  static GenomeAssembly? fromReport(Map<String, dynamic> report) {
    final String? accession =
        (report['accession'] ?? report['current_accession']) as String?;
    if (accession == null) return null;
    final info = report['assembly_info'] as Map<String, dynamic>? ?? {};
    final stats = report['assembly_stats'] as Map<String, dynamic>? ?? {};
    final organism = report['organism'] as Map<String, dynamic>? ?? {};
    return GenomeAssembly(
      accession: accession,
      assemblyName: info['assembly_name'] as String?,
      organismName: organism['organism_name'] as String?,
      isReference: info['refseq_category'] == 'reference genome',
      assemblyLevel: info['assembly_level'] as String?,
      releaseDate: info['release_date'] as String?,
      submitter: info['submitter'] as String?,
      genomeSize: _asInt(stats['total_sequence_length']),
      chromosomeCount: _asInt(stats['total_number_of_chromosomes']),
      contigN50: _asInt(stats['contig_n50']),
      gcPercent: _asDouble(stats['gc_percent']),
    );
  }

  /// The best of a species' assemblies: its own over a subspecies', then
  /// the most complete level, then the longest contigs, then the newest.
  static GenomeAssembly? best(
    Iterable<GenomeAssembly> assemblies,
    String name,
  ) {
    const levels = ['Contig', 'Scaffold', 'Chromosome', 'Complete Genome'];
    int compare(GenomeAssembly a, GenomeAssembly b) {
      int byOwn(GenomeAssembly x) => x.organismName == name ? 1 : 0;
      final keys = [
        byOwn(a).compareTo(byOwn(b)),
        levels
            .indexOf(a.assemblyLevel ?? '')
            .compareTo(levels.indexOf(b.assemblyLevel ?? '')),
        (a.contigN50 ?? 0).compareTo(b.contigN50 ?? 0),
        (a.releaseDate ?? '').compareTo(b.releaseDate ?? ''),
      ];
      return keys.firstWhere((k) => k != 0, orElse: () => 0);
    }

    final list = assemblies.toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => compare(a, b) >= 0 ? a : b);
  }
}

int? _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('${value ?? ''}');

double? _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('${value ?? ''}');

enum GeneCategory {
  proteinCoding('Protein-coding'),
  rna('Non-coding RNA'),
  pseudo('Pseudogene'),
  other('Other');

  const GeneCategory(this.label);

  final String label;

  static GeneCategory of(String geneType) {
    final String type = geneType.toLowerCase();
    if (type.contains('protein')) return proteinCoding;
    if (type.contains('rna')) return rna;
    if (type.contains('pseudo')) return pseudo;
    return other;
  }
}

/// Annotated genes split into [GeneCategory], in the category order.
class GeneComposition {
  const GeneComposition(this.counts);

  /// Raw counts keyed by NCBI gene type, e.g. PROTEIN_CODING, tRNA.
  final Map<String, int> counts;

  int get total => counts.values.fold(0, (sum, count) => sum + count);

  Map<GeneCategory, int> get byCategory {
    final Map<GeneCategory, int> result = {};
    for (final category in GeneCategory.values) {
      final int count = counts.entries
          .where((e) => GeneCategory.of(e.key) == category)
          .fold(0, (sum, e) => sum + e.value);
      if (count > 0) result[category] = count;
    }
    return result;
  }
}

/// Genome size and gene composition from NCBI Datasets.
class GenomeSummary {
  const GenomeSummary({
    required this.assembly,
    required this.assemblyCount,
    required this.genes,
  });

  final GenomeAssembly? assembly;
  final int assemblyCount;
  final GeneComposition genes;

  bool get isEmpty => assembly == null && genes.total == 0;
}

class NcbiDatasetsClient {
  const NcbiDatasetsClient(this.client);

  final http.Client client;

  /// Assemblies compared when the species has no designated reference.
  static const int assemblyCandidates = 20;

  static Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.https('api.ncbi.nlm.nih.gov', '/datasets/v2/$path', query);

  /// Annotated genes of each NCBI gene type; empty when unannotated.
  Future<Map<String, int>> geneTypeCounts(String name) async {
    final json = await _getJson(client, _uri('gene/taxon/$name/counts'));
    final List<dynamic> report = json['report'] as List<dynamic>? ?? [];
    return {
      for (final item in report.whereType<Map<String, dynamic>>())
        if (item['gene_type'] is String && (_asInt(item['count']) ?? 0) > 0)
          item['gene_type'] as String: _asInt(item['count'])!,
    };
  }

  Future<({List<GenomeAssembly> assemblies, int total})> assemblies(
    String name, {
    bool referenceOnly = false,
    int pageSize = 1,
    bool accessionsOnly = false,
  }) async {
    final json = await _getJson(
      client,
      _uri('genome/taxon/$name/dataset_report', {
        if (referenceOnly) 'filters.reference_only': 'true',
        if (!referenceOnly) 'filters.assembly_source': 'genbank',
        if (!referenceOnly) 'filters.assembly_version': 'current',
        'page_size': '$pageSize',
        if (accessionsOnly) 'returned_content': 'ASSM_ACC',
      }),
    );
    final List<dynamic> reports = json['reports'] as List<dynamic>? ?? [];
    final assemblies = [
      for (final report in reports.whereType<Map<String, dynamic>>())
        ?GenomeAssembly.fromReport(report),
    ];
    return (
      assemblies: assemblies,
      total: _asInt(json['total_count']) ?? assemblies.length,
    );
  }

  /// Asks for the gene counts, the reference genome and the assembly count
  /// together; only when there are assemblies but no reference does it fetch
  /// candidates to choose the best one from.
  Future<GenomeSummary> fetchSummary(String name) async {
    final (genes, reference, count) = await (
      geneTypeCounts(name),
      assemblies(name, referenceOnly: true),
      assemblies(name, accessionsOnly: true),
    ).wait;
    GenomeAssembly? assembly = reference.assemblies.firstOrNull;
    if (assembly == null && count.total > 0) {
      final candidates = await assemblies(name, pageSize: assemblyCandidates);
      assembly = GenomeAssembly.best(candidates.assemblies, name);
    }
    return GenomeSummary(
      assembly: assembly,
      assemblyCount: count.total,
      genes: GeneComposition(genes),
    );
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

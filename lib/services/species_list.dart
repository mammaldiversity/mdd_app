import 'package:mdd/services/database/database.dart' as db;
import 'package:mdd/services/database/mdd_query.dart';

const String mddSpeciesPermanentLink = 'https://www.mammaldiversity.org/taxon/';

class TaxonGroupService {
  const TaxonGroupService({required this.taxonList});

  final List<MddGroupListResult> taxonList;

  Map<String, List<MddGroupListResult>> groupByOrder() {
    Map<String, List<MddGroupListResult>> taxonGroups = {};
    for (final MddGroupListResult taxon in taxonList) {
      if (taxon.taxonOrder != null &&
          taxonGroups.containsKey(taxon.taxonOrder)) {
        taxonGroups[taxon.taxonOrder!] = [
          ...taxonGroups[taxon.taxonOrder!]!,
          taxon,
        ];
      } else {
        taxonGroups[taxon.taxonOrder ?? ''] = [taxon];
      }
    }
    return taxonGroups;
  }

  Map<String, List<MddGroupListResult>> groupByFamily() {
    Map<String, List<MddGroupListResult>> taxonGroups = {};
    for (final MddGroupListResult taxon in taxonList) {
      if (taxon.family != null && taxonGroups.containsKey(taxon.family)) {
        taxonGroups[taxon.family!] = [
          ...taxonGroups[taxon.family!]!,
          taxon,
        ];
      } else {
        taxonGroups[taxon.family ?? ''] = [taxon];
      }
    }
    return taxonGroups;
  }

  Map<String, List<MddGroupListResult>> groupByGenus() {
    Map<String, List<MddGroupListResult>> taxonGroups = {};
    for (final MddGroupListResult taxon in taxonList) {
      if (taxon.genus != null && taxonGroups.containsKey(taxon.genus)) {
        taxonGroups[taxon.genus!] = [
          ...taxonGroups[taxon.genus!]!,
          taxon,
        ];
      } else {
        taxonGroups[taxon.genus ?? ''] = [taxon];
      }
    }
    return taxonGroups;
  }
}

class SpeciesText {
  const SpeciesText({required this.taxonData});

  final db.TaxonomyData taxonData;

  String get speciesName {
    return '${taxonData.genus} ${taxonData.specificEpithet}';
  }

  String get speciesAuthorCitation {
    String authors = taxonData.authoritySpeciesAuthor ?? '';
    String year = taxonData.authoritySpeciesYear.toString();
    if (isParentheses(taxonData.authoritySpeciesCitation)) {
      return '($authors, $year)';
    }
    return '$authors, $year';
  }

  bool isParentheses(String? text) {
    return taxonData.authorityParentheses == 1;
  }
}

String matchIUCNStatus(String? iucnStatus) {
  switch (iucnStatus) {
    case 'LC':
      return 'Least Concern';
    case 'NT':
      return 'Near Threatened';
    case 'VU':
      return 'Vulnerable';
    case 'EN':
      return 'Endangered';
    case 'CR':
      return 'Critically Endangered';
    case 'EW':
      return 'Extinct in the Wild';
    case 'EX':
      return 'Extinct';
    default:
      return 'Not Evaluated';
  }
}

String generatePermanentLink(int taxonID) {
  return '$mddSpeciesPermanentLink$taxonID';
}

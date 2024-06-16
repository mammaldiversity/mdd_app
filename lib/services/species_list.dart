import 'package:mdd/services/database/mdd_query.dart';

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
}

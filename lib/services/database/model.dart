import 'package:mdd/services/database/database.dart';

class MddData {
  const MddData({
    required this.speciesData,
    required this.synonyms,
  });

  final TaxonomyData speciesData;
  final List<SynonymData> synonyms;

  factory MddData.fromJson(Map<String, dynamic> json) {
    return MddData(
      speciesData: TaxonomyData.fromJson(json['speciesData']),
      synonyms: List<SynonymData>.from(
          json['synonyms'].map((data) => SynonymData.fromJson(data))),
    );
  }
}

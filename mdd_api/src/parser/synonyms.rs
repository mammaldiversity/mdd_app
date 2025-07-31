use convert_case::Casing;
use serde::{Deserialize, Serialize};

/// MDD synonym CSV columns are in snake_case
/// Prefixed with MDD_
/// This struct will remove the prefix
/// and convert to camelCase for JSON serialization
#[derive(Debug, Serialize, Default, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SynonymData {
    pub syn_id: u32,
    pub hesp_id: u32,
    // MDD species_id
    pub species_id: Option<u32>,
    species: String,
    root_name: String,
    author: String,
    year: String,
    authority_parentheses: u8,
    nomenclature_status: String,
    validity: String,
    original_combination: String,
    original_rank: String,
    authority_citation: String,
    unchecked_authority_citation: String,
    sourced_unverified_citations: String,
    citation_group: String,
    citation_kind: String,
    authority_page: String,
    authority_link: String,
    authority_page_link: String,
    unchecked_authority_page_link: String,
    old_type_locality: String,
    original_type_locality: String,
    unchecked_type_locality: String,
    emended_type_locality: String,
    type_latitude: String,
    type_longitude: String,
    type_country: String,
    type_subregion: String,
    type_subregion2: String,
    holotype: String,
    type_kind: String,
    type_specimen_link: String,
    #[serde(alias = "order")]
    taxon_order: String,
    family: String,
    genus: String,
    specific_epithet: String,
    subspecific_epithet: String,
    variant_of: String,
    senior_homonym: String,
    variant_name_citations: String,
    name_usages: String,
    comments: String,
}

impl SynonymData {
    pub fn new() -> Self {
        Self {
            syn_id: 0,
            hesp_id: 0,
            species_id: None,
            species: "".to_string(),
            root_name: "".to_string(),
            author: "".to_string(),
            year: "".to_string(),
            authority_parentheses: 0,
            nomenclature_status: "".to_string(),
            validity: "".to_string(),
            original_combination: "".to_string(),
            original_rank: "".to_string(),
            authority_citation: "".to_string(),
            unchecked_authority_citation: "".to_string(),
            sourced_unverified_citations: "".to_string(),
            citation_group: "".to_string(),
            citation_kind: "".to_string(),
            authority_page: "".to_string(),
            authority_link: "".to_string(),
            authority_page_link: "".to_string(),
            unchecked_authority_page_link: "".to_string(),
            old_type_locality: "".to_string(),
            original_type_locality: "".to_string(),
            unchecked_type_locality: "".to_string(),
            emended_type_locality: "".to_string(),
            type_latitude: "".to_string(),
            type_longitude: "".to_string(),
            type_country: "".to_string(),
            type_subregion: "".to_string(),
            type_subregion2: "".to_string(),
            holotype: "".to_string(),
            type_kind: "".to_string(),
            type_specimen_link: "".to_string(),
            taxon_order: "".to_string(),
            family: "".to_string(),
            genus: "".to_string(),
            specific_epithet: "".to_string(),
            subspecific_epithet: "".to_string(),
            variant_of: "".to_string(),
            senior_homonym: "".to_string(),
            variant_name_citations: "".to_string(),
            name_usages: "".to_string(),
            comments: "".to_string(),
        }
    }

    pub fn from_csv_to_json(&self, csv_data: &str) -> Vec<SynonymData> {
        let data = self.clean_colnames(csv_data);
        let mut rdr = csv::Reader::from_reader(data.as_slice());
        let mut records = Vec::new();
        for result in rdr.deserialize() {
            let record: Self = result.unwrap_or_default();
            records.push(record);
        }
        records
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(&self).expect("Failed to serialize")
    }

    // The mdd csv files contain a prefix with MDD_.
    // We need to remove before we can parse the files.
    // We will return is as byte string
    fn clean_colnames(&self, data: &str) -> Vec<u8> {
        let mut cleaned_data = Vec::new();
        let cols = data.lines().next().unwrap_or("").to_string();
        let mut colnames = cols
            .trim()
            .split(',')
            .map(|col| col.trim_start_matches("MDD_").to_string())
            .map(|col| col.to_case(convert_case::Case::Camel))
            .collect::<Vec<String>>()
            .join(",");
        colnames.push('\n');
        cleaned_data.push(colnames.as_bytes().to_vec());
        for line in data.lines().skip(1) {
            // Remove trailing whitespace and add newline
            let line = line.trim_end().to_string() + "\n";
            cleaned_data.push(line.as_bytes().to_vec());
        }
        cleaned_data.concat()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_remove_mdd_prefix() {
        let synonym_data = SynonymData::new();
        let input = "MDD_syn_id,hesp_id,species_id,species,root_name,author,year";
        let output = synonym_data.clean_colnames(input);
        assert_eq!(
            output,
            b"synId,hespId,speciesId,species,rootName,author,year\n".to_vec()
        );
    }

    #[test]
    fn test_parsing_synonym_csv() {
        let path = "tests/data/syndata.csv";
        let data = std::fs::read_to_string(path).unwrap();
        let synonym_data = SynonymData::new();
        let records = synonym_data.from_csv_to_json(&data);
        assert!(!records.is_empty());
    }
}

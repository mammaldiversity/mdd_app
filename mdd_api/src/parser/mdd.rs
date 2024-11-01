//! Parse MDD csv data into a structured format.

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MddData {
    id: u32,
    sci_name: String,
    main_common_name: String,
    other_common_names: String,
    phylosort: u16,
    subclass: String,
    infraclass: String,
    magnorder: String,
    superorder: String,
    // order is a reserved keyword in Rust.
    // So, we need to rename it to taxonOrder.
    // #[serde(rename(serialize = "taxonOrder", deserialize = "order"))]
    #[serde(alias = "order")]
    taxon_order: String,
    suborder: String,
    infraorder: String,
    parvorder: String,
    superfamily: String,
    family: String,
    subfamily: String,
    tribe: String,
    genus: String,
    subgenus: String,
    specific_epithet: String,
    authority_species_author: String,
    authority_species_year: u16,
    authority_parentheses: u8,
    original_name_combination: String,
    authority_species_citation: String,
    authority_species_link: String,
    type_voucher: String,
    type_kind: String,
    #[serde(rename = "typeVoucherURIs")]
    type_voucher_uri: String,
    type_locality: String,
    type_locality_latitude: String,
    type_locality_longitude: String,
    nominal_names: String,
    taxonomy_notes: String,
    taxonomy_notes_citation: String,
    distribution_notes: String,
    distribution_notes_citation: String,
    subregion_distribution: String,
    country_distribution: String,
    continent_distribution: String,
    biogeographic_realm: String,
    iucn_status: String,
    extinct: String,
    domestic: String,
    flagged: String,
    #[serde(rename = "CMW_sciName")]
    cmw_sci_name: String,
    #[serde(rename = "diffSinceCMW")]
    diff_since_cmw: String,
    #[serde(rename = "MSW3_matchtype")]
    msw3_match_type: String,
    #[serde(rename = "MSW3_sciName")]
    msw3_sci_name: String,
    #[serde(rename = "diffSinceMSW3")]
    diff_since_msw3: String,
}

impl MddData {
    pub fn new() -> Self {
        Self {
            id: 0,
            phylosort: 0,
            subclass: "".to_string(),
            infraclass: "".to_string(),
            magnorder: "".to_string(),
            superorder: "".to_string(),
            taxon_order: "".to_string(),
            suborder: "".to_string(),
            infraorder: "".to_string(),
            parvorder: "".to_string(),
            superfamily: "".to_string(),
            family: "".to_string(),
            subfamily: "".to_string(),
            tribe: "".to_string(),
            genus: "".to_string(),
            subgenus: "".to_string(),
            specific_epithet: "".to_string(),
            sci_name: "".to_string(),
            authority_species_author: "".to_string(),
            authority_species_year: 0,
            authority_parentheses: 0,
            main_common_name: "".to_string(),
            other_common_names: "".to_string(),
            original_name_combination: "".to_string(),
            authority_species_citation: "".to_string(),
            authority_species_link: "".to_string(),
            type_voucher: "".to_string(),
            type_kind: "".to_string(),
            type_voucher_uri: "".to_string(),
            type_locality: "".to_string(),
            type_locality_latitude: "".to_string(),
            type_locality_longitude: "".to_string(),
            nominal_names: "".to_string(),
            taxonomy_notes: "".to_string(),
            taxonomy_notes_citation: "".to_string(),
            distribution_notes: "".to_string(),
            distribution_notes_citation: "".to_string(),
            subregion_distribution: "".to_string(),
            country_distribution: "".to_string(),
            continent_distribution: "".to_string(),
            biogeographic_realm: "".to_string(),
            iucn_status: "".to_string(),
            extinct: "".to_string(),
            domestic: "".to_string(),
            flagged: "".to_string(),
            cmw_sci_name: "".to_string(),
            diff_since_cmw: "".to_string(),
            msw3_match_type: "".to_string(),
            msw3_sci_name: "".to_string(),
            diff_since_msw3: "".to_string(),
        }
    }

    /// Parse csv data to json.
    /// Return in String json format.
    pub fn from_csv_to_json(&self, csv_data: &str) -> Vec<MddData> {
        let mut rdr = csv::Reader::from_reader(csv_data.as_bytes());
        let mut records = Vec::new();
        for result in rdr.deserialize() {
            let record: Self = result.unwrap();
            records.push(record);
        }
        records
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(&self).expect("Failed to serialize")
    }
}

#[cfg(test)]
mod tests {
    use std::path::Path;

    use super::*;

    #[test]
    fn test_parse_to_json() {
        let csv_data = Path::new("tests/data/test_data.csv");
        let csv_data = std::fs::read_to_string(csv_data).unwrap();
        let parser = MddData::new();
        let json_data = parser.from_csv_to_json(&csv_data);
        // let data = AllMddData::from_json(&json_data);
        assert_eq!(json_data.len(), 112);
    }
}

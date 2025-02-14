//! Parse MDD csv data into a structured format.

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MddData {
    pub id: u32,
    pub sci_name: String,
    pub main_common_name: String,
    pub other_common_names: String,
    pub phylosort: u16,
    pub subclass: String,
    pub infraclass: String,
    pub magnorder: String,
    pub superorder: String,
    // order is a reserved keyword in Rust.
    // So, we need to rename it to taxonOrder.
    // #[serde(rename(serialize = "taxonOrder", deserialize = "order"))]
    #[serde(alias = "order")]
    pub taxon_order: String,
    pub suborder: String,
    pub infraorder: String,
    pub parvorder: String,
    pub superfamily: String,
    pub family: String,
    pub subfamily: String,
    pub tribe: String,
    pub genus: String,
    pub subgenus: String,
    pub specific_epithet: String,
    pub authority_species_author: String,
    pub authority_species_year: u16,
    pub authority_parentheses: u8,
    pub original_name_combination: String,
    pub authority_species_citation: String,
    pub authority_species_link: String,
    pub type_voucher: String,
    pub type_kind: String,
    #[serde(rename = "typeVoucherURIs")]
    pub type_voucher_uri: String,
    pub type_locality: String,
    pub type_locality_latitude: String,
    pub type_locality_longitude: String,
    pub nominal_names: String,
    pub taxonomy_notes: String,
    pub taxonomy_notes_citation: String,
    pub distribution_notes: String,
    pub distribution_notes_citation: String,
    pub subregion_distribution: String,
    pub country_distribution: String,
    pub continent_distribution: String,
    pub biogeographic_realm: String,
    pub iucn_status: String,
    pub extinct: u8,
    pub domestic: u8,
    pub flagged: u8,
    #[serde(rename = "CMW_sciName")]
    pub cmw_sci_name: String,
    #[serde(rename = "diffSinceCMW")]
    pub diff_since_cmw: u8,
    #[serde(rename = "MSW3_matchtype")]
    pub msw3_match_type: String,
    #[serde(rename = "MSW3_sciName")]
    pub msw3_sci_name: String,
    #[serde(rename = "diffSinceMSW3")]
    pub diff_since_msw3: String,
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
            extinct: 0,
            domestic: 0,
            flagged: 0,
            cmw_sci_name: "".to_string(),
            diff_since_cmw: 0,
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

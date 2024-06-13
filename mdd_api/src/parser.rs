//! Parse MDD csv data into a structured format.
//!
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CsvToJSONParser {
    id: usize,
    phylosort: usize,
    subclass: String,
    infraclass: String,
    magnorder: String,
    superorder: String,
    #[serde(rename = "order")]
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
    sci_name: String,
    authority_species_author: String,
    authority_species_year: String,
    authority_parentheses: String,
    main_common_name: String,
    other_common_names: String,
    original_name_combination: String,
    authority_species_citation: String,
    authority_species_link: String,
    holotype_voucher: String,
    #[serde(rename = "holotypeVoucherURIs")]
    holotype_voucher_uri: String,
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

impl CsvToJSONParser {
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
            authority_species_year: "".to_string(),
            authority_parentheses: "".to_string(),
            main_common_name: "".to_string(),
            other_common_names: "".to_string(),
            original_name_combination: "".to_string(),
            authority_species_citation: "".to_string(),
            authority_species_link: "".to_string(),
            holotype_voucher: "".to_string(),
            holotype_voucher_uri: "".to_string(),
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
    pub fn parse_to_json(&self, csv_data: &str) -> String {
        let mut rdr = csv::Reader::from_reader(csv_data.as_bytes());
        let mut records = Vec::new();
        for result in rdr.deserialize() {
            let record: CsvToJSONParser = result.unwrap();
            records.push(record);
        }
        serde_json::to_string(&records).unwrap()
    }
}

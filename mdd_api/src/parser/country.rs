//! This module defines the `CountryMDDStats` struct, which holds statistics about MDD species in a specific country.
//! It parse MDD data and aggregates statistics for each country.
//! Excludes domesticated and widely distributed species.
//! Basically, any species that do not list country distribution in MDD data, including human.

use std::{
    collections::{BTreeMap, HashMap, HashSet},
    path::Path,
};

use regex::Regex;
use serde::{Deserialize, Serialize};

use crate::{
    helper::{country_code, MDD_LIST_SEPARATOR},
    parser::mdd::MddData,
};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CountryMDDStats {
    pub total_countries: u32,
    pub domesticated: Vec<u32>,
    pub widespread: Vec<u32>,
    /// Map of country code to `CountryData`.
    /// The key is the country or region name.
    /// Predicted distribution is indicated by a question mark at the end of the country code.
    pub country_data: BTreeMap<String, CountryData>,
}

impl CountryMDDStats {
    pub fn new() -> Self {
        Self {
            total_countries: 0,
            domesticated: Vec::new(),
            widespread: Vec::new(),
            country_data: BTreeMap::new(),
        }
    }

    /// Parses the MDD data and updates the country statistics.
    /// It parses the country distribution and aggregates statistics for each country.
    /// It excludes domesticated species and widespread species (e.g., "NA" country list).
    /// If the country list does not match any known country code, it uses the country name as the code.
    pub fn parse_country_data(&mut self, mdd_data: &[MddData]) {
        let mut records: HashMap<String, CountryRecord> = HashMap::new();
        for species in mdd_data {
            if species.country_distribution.is_empty() {
                continue;
            }

            // Update domesticated species count.
            if species.country_distribution.to_lowercase() == "domesticated" {
                self.domesticated.push(species.id);
                continue; // Skip domesticated species.
            }

            // Update widespread species count.
            if species.country_distribution.to_lowercase() == "na" {
                self.widespread.push(species.id);
                continue; // Skip widespread species.
            }

            if species.country_distribution.contains('|') {
                // Multiple countries distribution.
                self.parse_multiple_countries(&mut records, &species.country_distribution, species);
            } else {
                self.update_record(&species.country_distribution, &mut records, species);
            }
        }
        self.update_data(&mut records);
    }

    pub fn write_to_json_file(&self, file_path: &Path) {
        let json_data = self.to_json();
        std::fs::write(file_path, json_data).expect("Failed to write CountryMDDStats to JSON file");
        // self.print_missing_country_codes();
    }

    fn to_json(&self) -> String {
        serde_json::to_string(self).expect("Failed to serialize CountryMDDStats")
    }

    // // We use regex two uppercase letters to check country codes from country data.
    // // If it does not match, we consider it a missing code.
    // // and print it out.
    // fn print_missing_country_codes(&self) {
    //     let io = std::io::stdout();
    //     let mut buff = BufWriter::new(io);
    //     writeln!(buff, "Missing country codes:")
    //         .expect("Failed to write missing country codes header");
    //     self.country_data.keys().for_each(|country_code| {
    //         let re = &COUNTRY_CODE_REGEX;
    //         if !re.is_match(country_code) {
    //             writeln!(buff, "{}", country_code).expect("Failed to write missing country code");
    //         }
    //     });
    // }

    fn update_data(&mut self, records: &mut HashMap<String, CountryRecord>) {
        for (country, record) in records.iter_mut() {
            // Create CountryData from the record.
            let country_data = CountryData::from_record(record);
            // Insert into the country_data map.
            self.country_data.insert(country.to_string(), country_data);
        }
        // Update total countries count.
        self.total_countries = self.country_data.len() as u32;
    }

    fn parse_multiple_countries(
        &mut self,
        records: &mut HashMap<String, CountryRecord>,
        distribution: &str,
        data: &MddData,
    ) {
        let countries = distribution.split(MDD_LIST_SEPARATOR);
        for country in countries {
            self.update_record(country, records, data);
        }
    }

    fn update_record(
        &mut self,
        country_name: &str,
        records: &mut HashMap<String, CountryRecord>,
        data: &MddData,
    ) {
        let country_name = country_name.trim();
        if country_name.is_empty() {
            eprintln!(
                "Warning: Empty country name found in MDD data for species ID: {}. \
                It could be due to trailing spaces. \
                 This will be skipped.",
                data.id
            );
            return;
        }
        let predicted = country_name.ends_with('?');
        let country_name = if predicted {
            country_name.replace("?", "").to_string()
        } else {
            country_name.to_string()
        };

        if !country_code::is_known_country_region(&country_name) {
            eprintln!(
                "Warning: '{}' does not match any known country code.",
                country_name
            );
        }

        let record = records
            .entry(country_name.to_string())
            .or_insert_with(|| CountryRecord::new(country_name.to_string()));
        record.update(data, predicted);
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CountryData {
    /// Alpha-2 country code.
    pub code: String,
    pub total_orders: u32,
    pub total_families: u32,
    pub total_genera: u32,
    pub total_living_species: u32,
    pub total_extinct_species: u32,
    /// List of MDD species IDs distributed in the country.
    /// We include both living and extinct species to provide all lists.
    /// This is used to generate the species list for the country.
    /// The caller will know the extinction status from the MDD record.
    pub species_list: Vec<String>,
}

impl CountryData {
    pub fn new() -> Self {
        Self {
            code: String::new(),
            total_orders: 0,
            total_families: 0,
            total_genera: 0,
            total_living_species: 0,
            total_extinct_species: 0,
            species_list: Vec::new(),
        }
    }

    fn from_record(record: &CountryRecord) -> Self {
        Self {
            code: record.code.to_string(),
            total_orders: record.orders.len() as u32,
            total_families: record.families.len() as u32,
            total_genera: record.genera.len() as u32,
            total_living_species: record.living_species_ids.len() as u32,
            total_extinct_species: record.extinct_species_ids.len() as u32,
            species_list: record
                .living_species_ids
                .iter()
                .chain(record.extinct_species_ids.iter())
                .map(|id| id.to_string())
                .collect(),
        }
    }
}

// Holds records of orders, families, and genera for a country.
// to help keep track of unique orders, families, and genera for the stats.
struct CountryRecord {
    // Alpha-2 country code.
    code: String,
    orders: HashSet<String>,
    families: HashSet<String>,
    genera: HashSet<String>,
    // List of species mdd IDs in the country.
    living_species_ids: Vec<String>,
    extinct_species_ids: Vec<String>,
}

impl CountryRecord {
    fn new(country_name: String) -> Self {
        let country_code = country_code::get_country_code(&country_name);
        Self {
            code: country_code,
            orders: HashSet::new(),
            families: HashSet::new(),
            genera: HashSet::new(),
            living_species_ids: Vec::new(),
            extinct_species_ids: Vec::new(),
        }
    }

    fn update(&mut self, data: &MddData, predicted_distribution: bool) {
        self.add_species(data.id.to_string(), data.extinct, predicted_distribution);
        self.add_order(data.taxon_order.to_string());
        self.add_family(data.family.to_string());
        self.add_genus(data.genus.to_string());
    }

    fn add_species(&mut self, species_id: String, extinct: u8, predicted_distribution: bool) {
        let id = if predicted_distribution {
            format!("{}?", species_id)
        } else {
            species_id
        };
        if extinct == 1 {
            self.extinct_species_ids.push(id);
        } else {
            self.living_species_ids.push(id);
        }
    }

    fn add_order(&mut self, order: String) {
        self.orders.insert(order);
    }

    fn add_family(&mut self, family: String) {
        self.families.insert(family);
    }

    fn add_genus(&mut self, genus: String) {
        self.genera.insert(genus);
    }
}

// We create lazy static regex to match country codes.
lazy_static::lazy_static! {
    static ref COUNTRY_CODE_REGEX: Regex = Regex::new(r"^[A-Z]{2}$").expect("Failed to compile country code regex");
}

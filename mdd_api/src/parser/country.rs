//! This module defines the `CountryMDDStats` struct, which holds statistics about MDD species in a specific country.
//! It parse MDD data and aggregates statistics for each country.
//! Excludes domesticated and widely distributed species.
//! Basically, any species that do not list country distribution in MDD data, including human.
pub struct CountryMDDStats {
    pub country_code: String,
    pub country_name: String,
    pub total_orders: u32,
    pub total_families: u32,
    pub total_genera: u32,
    pub total_living_species: u32,
    pub total_extinct_species: u32,
    /// List of MDD species IDs distributed in the country.
    pub species_list: Vec<u32>,
}

impl CountryMDDStats {
    pub fn new(country_code: String, country_name: String) -> Self {
        Self {
            country_code,
            country_name,
            total_orders: 0,
            total_families: 0,
            total_genera: 0,
            total_living_species: 0,
            total_extinct_species: 0,
            species_list: Vec::new(),
        }
    }

    pub fn add_species(&mut self, species_id: u32, is_extinct: bool) {
        self.species_list.push(species_id);
        if is_extinct {
            self.total_extinct_species += 1;
        } else {
            self.total_living_species += 1;
        }
    }
}

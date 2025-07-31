use flate2::bufread::GzDecoder;
use mdd::MddData;
use serde::{Deserialize, Serialize};
use synonyms::SynonymData;

pub mod country;
pub mod mdd;
pub mod synonyms;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ReleasedMddData {
    pub metadata: MetaData,
    pub data: Vec<SimpleMDD>,
    pub synonym_only: Vec<SynonymData>,
}

impl ReleasedMddData {
    pub fn new() -> Self {
        Self {
            metadata: MetaData::new(),
            data: Vec::new(),
            synonym_only: Vec::new(),
        }
    }

    pub fn from_gz_bytes(bytes: &[u8]) -> Self {
        let data = GzDecoder::new(bytes);
        serde_json::from_reader(data).expect("Failed to deserialize")
    }

    pub fn from_json(json_data: &str) -> Self {
        serde_json::from_str(json_data).expect("Failed to deserialize")
    }

    pub fn from_parser(
        mdd_data: Vec<MddData>,
        synonym_data: Vec<SynonymData>,
        version: &str,
        release_date: &str,
    ) -> Self {
        let mut simple_mdd = Vec::new();
        // Get the synonyms that have no species id
        let synonym_only = synonym_data
            .iter()
            .filter(|s| s.species_id.is_none())
            .map(|s| s.clone())
            .collect();

        // iter over the mdd data and get all the synonyms that match the species id
        let metadata = MetaData::from_mdd(&mdd_data, &synonym_data, version, release_date);
        for mdd in mdd_data {
            let synonyms: Vec<SynonymData> = synonym_data
                .iter()
                .filter(|s| s.species_id == Some(mdd.id))
                .map(|s| s.clone())
                .collect();
            simple_mdd.push(SimpleMDD::new(mdd, synonyms));
        }

        Self {
            data: simple_mdd,
            synonym_only,
            metadata,
        }
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(&self).expect("Failed to serialize")
    }

    pub fn get_data(&self) -> (Vec<String>, Vec<String>) {
        let mdd = self.data.iter().map(|d| d.to_json()).collect();
        let synonyms = self.synonym_only.iter().map(|s| s.to_json()).collect();
        (mdd, synonyms)
    }

    pub fn get_version(&self) -> &str {
        &self.metadata.version
    }

    pub fn get_release_date(&self) -> &str {
        &self.metadata.release_date
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct SimpleMDD {
    mdd_id: u32,
    species_data: MddData,
    synonyms: Vec<SynonymData>,
}

impl SimpleMDD {
    fn new(species: MddData, synonyms: Vec<SynonymData>) -> Self {
        Self {
            mdd_id: species.id,
            species_data: species,
            synonyms,
        }
    }

    fn to_json(&self) -> String {
        serde_json::to_string(&self).expect("Failed to serialize")
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct MetaData {
    version: String,
    release_date: String,
    species_count: u32,
    synonym_count: u32,
    recently_extinct: u32,
    living: u32,
    domestic: u32,
    living_wild: u32,
    genus_count: u32,
    family_count: u32,
    order_count: u32,
}

impl MetaData {
    fn new() -> Self {
        Self {
            version: "".to_string(),
            release_date: "".to_string(),
            species_count: 0,
            synonym_count: 0,
            recently_extinct: 0,
            living: 0,
            domestic: 0,
            living_wild: 0,
            genus_count: 0,
            family_count: 0,
            order_count: 0,
        }
    }

    fn from_mdd(
        data: &[MddData],
        synonyms: &[SynonymData],
        version: &str,
        release_date: &str,
    ) -> Self {
        let species_count = data.len() as u32;
        let synonym_count = synonyms.len() as u32;
        let recently_extinct = data.iter().filter(|d| d.extinct == 1).count() as u32;
        let living = species_count - recently_extinct;
        let domestic = data.iter().filter(|d| d.domestic == 1).count() as u32;
        let living_wild = living - domestic;
        let genus_count = data
            .iter()
            .map(|d| d.genus.clone())
            .collect::<std::collections::HashSet<_>>()
            .len() as u32;
        let family_count = data
            .iter()
            .map(|d| d.family.clone())
            .collect::<std::collections::HashSet<_>>()
            .len() as u32;
        let order_count = data
            .iter()
            .map(|d| d.taxon_order.clone())
            .collect::<std::collections::HashSet<_>>()
            .len() as u32;

        Self {
            version: version.to_string(),
            release_date: release_date.to_string(),
            species_count,
            synonym_count,
            recently_extinct,
            living,
            domestic,
            living_wild,
            genus_count,
            family_count,
            order_count,
        }
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AllMddData {
    version: String,
    release_date: String,
    data: Vec<MddData>,
    synonyms: Vec<SynonymData>,
}

impl AllMddData {
    pub fn new() -> Self {
        Self {
            version: "".to_string(),
            release_date: "".to_string(),
            data: Vec::new(),
            synonyms: Vec::new(),
        }
    }

    pub fn from_json(json_data: &str) -> Self {
        serde_json::from_str(json_data).expect("Failed to deserialize")
    }

    /// Create a new AllMddData object from a Gzipped byte array.
    pub fn from_gz_bytes(bytes: &[u8]) -> Self {
        let data = GzDecoder::new(bytes);
        serde_json::from_reader(data).expect("Failed to deserialize")
    }

    pub fn from_parser(mdd_data: Vec<MddData>, synonym_data: Vec<SynonymData>) -> Self {
        Self {
            version: "".to_string(),
            data: mdd_data,
            synonyms: synonym_data,
            release_date: "".to_string(),
        }
    }

    pub fn add_data(&mut self, data: MddData) {
        self.data.push(data);
    }

    pub fn set_version(&mut self, version: &str) {
        self.version = version.to_string();
    }

    pub fn set_release_date(&mut self, release_date: &str) {
        self.release_date = release_date.to_string();
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(&self).expect("Failed to serialize")
    }

    pub fn get_data(&self) -> (Vec<String>, Vec<String>) {
        let mdd = self.data.iter().map(|d| d.to_json()).collect();
        let synonyms = self.synonyms.iter().map(|s| s.to_json()).collect();
        (mdd, synonyms)
    }

    pub fn get_mdd_data(&self) -> Vec<String> {
        self.data.iter().map(|d| d.to_json()).collect()
    }

    pub fn get_version(&self) -> &str {
        &self.version
    }

    pub fn get_release_date(&self) -> &str {
        &self.release_date
    }
}

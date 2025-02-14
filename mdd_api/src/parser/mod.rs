use flate2::bufread::GzDecoder;
use mdd::MddData;
use serde::{Deserialize, Serialize};
use synonyms::SynonymData;

pub mod mdd;
pub mod synonyms;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WebMddData {
    version: String,
    release_date: String,
    data: Vec<SimpleMDD>,
    synonym_only: Vec<SynonymData>,
}

impl WebMddData {
    pub fn new() -> Self {
        Self {
            version: "".to_string(),
            release_date: "".to_string(),
            data: Vec::new(),
            synonym_only: Vec::new(),
        }
    }

    pub fn from_json(json_data: &str) -> Self {
        serde_json::from_str(json_data).expect("Failed to deserialize")
    }

    pub fn from_parser(mdd_data: Vec<MddData>, synonym_data: Vec<SynonymData>) -> Self {
        let mut simple_mdd = Vec::new();
        // Get the synonyms that have no species id
        let synonym_only = synonym_data
            .iter()
            .filter(|s| s.species_id == 0)
            .map(|s| s.clone())
            .collect();

        // iter over the mdd data and get all the synonyms that match the species id

        for mdd in mdd_data {
            let synonyms: Vec<SynonymData> = synonym_data
                .iter()
                .filter(|s| s.species_id == mdd.id)
                .map(|s| s.clone())
                .collect();
            simple_mdd.push(SimpleMDD::new(mdd, synonyms));
        }

        Self {
            version: "".to_string(),
            release_date: "".to_string(),
            data: simple_mdd,
            synonym_only,
        }
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
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct SimpleMDD {
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

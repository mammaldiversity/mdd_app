use mdd_api::parser::ReleasedMddData;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub struct MddHelper {
    /// MDD file version
    pub version: String,
    /// MDD release date
    pub release_date: String,
    /// MDD main data
    pub mdd_data: Vec<String>,
    /// Synonyms data
    pub syn_data: Vec<String>,
}

impl MddHelper {
    pub fn parse(bytes: Vec<u8>) -> Self {
        let mdd_data = ReleasedMddData::from_gz_bytes(&bytes);
        let (mdd, syn) = mdd_data.get_data();
        let version = mdd_data.get_version().to_string();
        let release_date = mdd_data.get_release_date().to_string();
        Self {
            version: version,
            release_date: release_date,
            mdd_data: mdd,
            syn_data: syn,
        }
    }
}

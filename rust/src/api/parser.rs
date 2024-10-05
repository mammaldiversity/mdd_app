use std::path::Path;

use mdd_api::{parser::AllMddData, writer::MddWriter};

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
    pub fn new() -> Self {
        Self {
            version: "".to_string(),
            release_date: "".to_string(),
            mdd_data: Vec::new(),
            syn_data: Vec::new(),
        }
    }

    pub fn get_data(&mut self, bytes: Vec<u8>) {
        let mdd_data = AllMddData::from_gz_bytes(&bytes);
        let (mdd, syn) = mdd_data.get_data();
        self.version = mdd_data.get_version().to_string();
        self.release_date = mdd_data.get_release_date().to_string();
        self.mdd_data = mdd;
        self.syn_data = syn;
    }
}

/// Wrapper for writer API to write data to a file.
/// Supports writing to JSON and CSV.
pub struct DatabaseWriter {
    pub json_data: String,
    pub output_dir: String,
    pub output_filename: String,
    pub to_csv: bool,
}

impl DatabaseWriter {
    pub fn new(
        json_data: String,
        output_dir: String,
        output_filename: String,
        to_csv: bool,
    ) -> Self {
        DatabaseWriter {
            json_data,
            output_dir,
            output_filename,
            to_csv,
        }
    }

    pub fn write(&self) -> String {
        let writer = MddWriter::new(
            Path::new(&self.output_dir),
            &self.output_filename,
            self.to_csv,
        );
        let output_path = writer.write(&self.json_data).expect("Failed to write data");
        output_path.to_string_lossy().to_string()
    }
}

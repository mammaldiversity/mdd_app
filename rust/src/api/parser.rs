use std::path::Path;

use mdd_api::{parser::MddParser, writer::MddWriter};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn parse_csv_to_json(csv_data: &str) -> Vec<String> {
    let parser = MddParser::new();
    parser.parse_to_json(csv_data)
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

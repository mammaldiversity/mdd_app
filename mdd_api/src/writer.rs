use std::{
    fs,
    path::{Path, PathBuf},
};

use crate::parser::MddParser;

const CSV_EXTENSION: &str = "csv";
const JSON_EXTENSION: &str = "json";

pub struct MddWriter<'a> {
    pub output_dir: &'a Path,
    pub output_filename: &'a str,
    pub to_csv: bool,
}

impl<'a> MddWriter<'a> {
    pub fn new(output_dir: &'a Path, output_filename: &'a str, to_csv: bool) -> Self {
        MddWriter {
            output_dir,
            output_filename,
            to_csv,
        }
    }
    /// Parse json data to csv.
    /// Write to a file.
    pub fn write(&self, json_data: &str) -> Result<PathBuf, Box<dyn std::error::Error>> {
        fs::create_dir_all(&self.output_dir)?;
        let output_path = self.create_output_path();
        // Replace taxonOrder with order to avoid conflict with parser.
        let data = json_data.replace("taxonOrder", "order");
        if self.to_csv {
            self.to_csv(&data, &output_path)?;
        } else {
            self.to_json(&data, &output_path)?;
        }
        Ok(output_path)
    }

    /// Write json
    fn to_csv(
        &self,
        json_data: &str,
        output_path: &Path,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let mut wtr = csv::Writer::from_path(output_path)?;
        let records: Vec<MddParser> = serde_json::from_str(&json_data)?;
        for record in records {
            wtr.serialize(record)?;
        }
        wtr.flush()?;
        Ok(())
    }

    /// Write json
    /// Write to a file.
    fn to_json(
        &self,
        json_data: &str,
        output_path: &Path,
    ) -> Result<(), Box<dyn std::error::Error>> {
        std::fs::write(output_path, json_data)?;
        Ok(())
    }

    // Check if file exists, or else create a new filename
    // with suffix _1, _2, _3, etc.
    fn create_output_path(&self) -> PathBuf {
        let extension = self.get_extension();
        self.output_dir
            .join(&self.output_filename)
            .with_extension(extension)
    }

    fn get_extension(&self) -> &str {
        if self.to_csv {
            CSV_EXTENSION
        } else {
            JSON_EXTENSION
        }
    }
}

#[cfg(test)]
mod test {
    use std::env;

    use tempdir::TempDir;

    use super::*;

    #[test]
    fn test_write_json() {
        let json_mdd: &str = r#"[{"id":1,"phylosort":1,"subclass":"Theria"}]"#;
        let output_dir = TempDir::new("output").unwrap();
        let output_dir = env::current_dir().unwrap().join(output_dir.path());
        let filename = "output";
        let parser = MddWriter::new(&output_dir, filename, false);
        parser.write(json_mdd).unwrap();
        let json_result = output_dir.join(filename).with_extension(JSON_EXTENSION);
        assert_eq!(json_result.exists(), true);
    }

    #[test]
    fn test_write_csv() {
        let input_path = "tests/data/export.json";
        let json_mdd = std::fs::read_to_string(input_path).unwrap();
        let output_dir = TempDir::new("output").unwrap();
        let output_dir = env::current_dir().unwrap().join(output_dir.path());
        let filename = "output";
        let parser = MddWriter::new(&output_dir, filename, true);
        parser.write(&json_mdd).unwrap();
    }

    #[test]
    fn check_filename() {
        let output_dir = TempDir::new("output").unwrap();
        let output_dir = env::current_dir().unwrap().join(output_dir.path());
        let filename = "output";
        let parser = MddWriter::new(&output_dir, filename, false);
        let output_path = parser.create_output_path();
        assert_eq!(output_path, output_dir.join("output.json"));
    }
}

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
    pub fn write(&self, json_data: &str) -> Result<(), Box<dyn std::error::Error>> {
        fs::create_dir_all(&self.output_dir)?;
        let output_path = self._create_output_path();
        if self.to_csv {
            self.to_csv(json_data, &output_path)?;
        } else {
            self.to_json(json_data, &output_path)?;
        }
        Ok(())
    }

    /// Write json
    fn to_csv(
        &self,
        json_data: &str,
        output_path: &Path,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let mut wtr = csv::Writer::from_path(output_path)?;
        let records: Vec<MddParser> = serde_json::from_str(json_data)?;
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
    fn _create_output_path(&self) -> PathBuf {
        let mut output_path = self.output_dir.join(&self.output_filename);
        let mut i = 1;
        while output_path.exists() {
            output_path = self
                .output_dir
                .join(format!("{}_{}", self.output_filename, i));
            i += 1;
        }
        if self.to_csv {
            output_path.with_extension(CSV_EXTENSION)
        } else {
            output_path.with_extension(JSON_EXTENSION)
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
}
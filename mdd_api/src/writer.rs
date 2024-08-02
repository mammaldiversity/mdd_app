use std::{fs, path::Path};

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
        if self.to_csv {
            let output_file = self
                .output_dir
                .join(&self.output_filename)
                .with_extension(CSV_EXTENSION);
            self.to_csv(json_data, &output_file)?;
        } else {
            let output_file = self
                .output_dir
                .join(&self.output_filename)
                .with_extension(JSON_EXTENSION);
            self.to_json(json_data, &output_file)?;
        }
        Ok(())
    }

    /// Write json
    fn to_csv(
        &self,
        json_data: &str,
        output_path: &Path,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let output_file = output_path.with_extension(CSV_EXTENSION);

        let mut wtr = csv::Writer::from_path(output_file)?;
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
        let output_file = output_path.with_extension(JSON_EXTENSION);
        std::fs::write(output_file, json_data)?;
        Ok(())
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

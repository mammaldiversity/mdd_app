use std::{
    fs,
    path::{Path, PathBuf},
};

use args::{Cli, JsonArgs};
use chrono::DateTime;
use clap::Parser;
use mdd_api::{
    helper::country_code::CountryRegionCode,
    parser::{country::CountryMDDStats, mdd::MddData, synonyms::SynonymData, ReleasedMddData},
};
use regex::Regex;

use crate::args::FromZipArgs;

mod args;

const DEFAULT_OUTPUT_FNAME: &str = "data";
const DEFAULT_COUNTRY_STATS_FNAME: &str = "country_stats";
const DEFAULT_COUNTRY_REGION_FNAME: &str = "country_region_code";
const JSON_EXT: &str = "json";
const GZIP_EXT: &str = "json.gz";
const DEFAULT_PREFIX: &str = "mdd";

fn main() {
    let args = Cli::parse();
    match args {
        Cli::ToJson(args) => {
            let parser = JsonParser::from_args(&args);
            parser.parse_to_json();
        }
        Cli::FromZip(args) => {
            let parser = ZipParser::from_args(&args);
            parser.parse_to_json();
        }
        Cli::FromToml(_) => {
            println!("Not implemented");
        }
        Cli::ToDb(_) => {
            println!("Not implemented");
        }
    }
}

struct ZipParser<'a> {
    input_path: &'a Path,
    output_path: &'a Path,
}

impl<'a> ZipParser<'a> {
    fn from_args(args: &'a FromZipArgs) -> Self {
        Self {
            input_path: &args.input,
            output_path: &args.output,
        }
    }

    fn parse_to_json(&self) {
        self.extract_zip_file();
        // We will find the MDD file prefix with MDD_v in the file name.
        // and synonym file with prefix "Species_Syn_v"
        let glob_files = glob::glob(&format!(
            "{}/MDD/*.csv",
            self.output_path
                .to_str()
                .expect("Failed to convert Path to str")
        ));
        let files = match glob_files {
            Ok(files) => files.filter_map(Result::ok).collect::<Vec<PathBuf>>(),
            Err(e) => panic!("Failed to find MDD files with pattern: {}", e),
        };
        let mdd_file = self.find_mdd_file(&files);
        let syn_file = self.find_synonym_file(&files);
        if mdd_file.is_none() || syn_file.is_none() {
            panic!("MDD or synonym file not found in the zip archive. Please check the zip file.");
        }

        let json_parser = JsonParser::from_path(
            mdd_file.as_ref().expect("MDD file not found"),
            syn_file.as_ref().expect("Synonym file not found"),
            self.output_path,
        );
        json_parser.parse_to_json();
    }

    fn extract_zip_file(&self) {
        let zip = std::fs::File::open(self.input_path).expect("Failed to open zip file");
        let mut archive = zip::ZipArchive::new(zip).expect("Failed to read zip file");
        // We extract the file for now to keep it simple.
        archive
            .extract(&self.output_path)
            .expect("Failed to extract zip file");
    }

    fn find_mdd_file(&self, files: &[PathBuf]) -> Option<PathBuf> {
        for file in files {
            if file
                .file_name()
                .expect("Failed to get file name")
                .to_str()
                .expect("Failed to convert OsStr to str")
                .starts_with("MDD_v")
            {
                return Some(file.to_path_buf());
            }
        }
        None
    }

    fn find_synonym_file(&self, files: &[PathBuf]) -> Option<PathBuf> {
        for file in files {
            if file
                .file_name()
                .expect("Failed to get file name")
                .to_str()
                .expect("Failed to convert OsStr to str")
                .starts_with("Species_Syn_v")
            {
                return Some(file.to_path_buf());
            }
        }
        None
    }
}

struct JsonParser<'a> {
    input_path: &'a Path,
    synonym_path: &'a Path,
    output_path: &'a Path,
    plain_text: bool,
    mdd_version: Option<&'a str>,
    release_date: Option<&'a str>,
    limit: Option<usize>,
    prefix: Option<&'a str>,
}

impl<'a> JsonParser<'a> {
    fn from_path(input_path: &'a Path, synonym_path: &'a Path, output_path: &'a Path) -> Self {
        Self {
            input_path,
            synonym_path,
            output_path,
            plain_text: true,
            mdd_version: None,
            release_date: None,
            limit: None,
            prefix: Some(DEFAULT_PREFIX),
        }
    }

    fn from_args(args: &'a JsonArgs) -> Self {
        Self {
            input_path: &args.input,
            synonym_path: &args.synonym,
            output_path: &args.output,
            plain_text: args.plain_text,
            mdd_version: args.mdd_version.as_deref(),
            release_date: args.release_date.as_deref(),
            limit: args.limit,
            prefix: args.prefix.as_deref(),
        }
    }

    fn parse_to_json(&self) {
        let mdd_data = std::fs::read_to_string(self.input_path).expect("Failed to read MDD file");
        let syn_data =
            std::fs::read_to_string(self.synonym_path).expect("Failed to read synonym file");

        println!("Parsing MDD data from: {:?}", self.input_path);
        let parser = MddData::new();
        let mut mdd_data = parser.from_csv_to_json(&mdd_data);
        println!("Found MDD data records: {}", mdd_data.len());

        println!("Parsing synonym data from: {:?}", self.synonym_path);
        let synonyms = SynonymData::new();
        let mut synonym_data = synonyms.from_csv_to_json(&syn_data);
        println!("Found synonym data records: {}", synonym_data.len());

        if synonym_data.is_empty() {
            println!("No synonym data found");
        }

        println!("Creating country mammal diversity statistics from MDD records");
        let mut country_stats = CountryMDDStats::new();
        country_stats.parse_country_data(&mdd_data);
        println!(
            "Total countries and regions: {}, Total domesticated species: {}, Total widespread species: {}",
            country_stats.total_countries,
            country_stats.domesticated.len(),
            country_stats.widespread.len()
        );

        if self.limit.is_some() {
            self.limit_mdd_data(&mut mdd_data, self.limit.unwrap());
            self.limit_synonym_data(&mut synonym_data, self.limit.unwrap());
        }
        let mdd_version = self.get_version();
        let release_date = self.get_release_date();
        println!(
            "Using MDD version: {}, release date: {}",
            mdd_version, release_date
        );
        let all_data =
            ReleasedMddData::from_parser(mdd_data, synonym_data, &mdd_version, &release_date);
        let json = all_data.to_json();
        fs::create_dir_all(self.output_path).unwrap_or_else(|_| {
            panic!("Failed to create output directory: {:?}", self.output_path)
        });
        if self.plain_text {
            self.write_plain_text(&json);
            self.write_gzip(&json);
            println!("Output written to: {:?}", self.get_output_path(false));
        } else {
            self.write_gzip(&json);
        }

        // Write country statistics to JSON file
        country_stats.write_to_json_file(
            &self
                .output_path
                .join(DEFAULT_COUNTRY_STATS_FNAME)
                .with_extension(JSON_EXT),
        );

        CountryRegionCode::new().write_to_file(
            &self
                .output_path
                .join(DEFAULT_COUNTRY_REGION_FNAME)
                .with_extension(JSON_EXT),
        );
    }

    // We use the version if specified.
    // Otherwise, we will infer from the file name.
    // MDD species file_stem example: MDD_v2.2_6815species.
    // In this case, the version is 2.2.
    fn get_version(&self) -> String {
        match self.mdd_version {
            Some(version) => version.to_string(),
            None => {
                let file_stem = self
                    .input_path
                    .file_stem()
                    .expect("Invalid file name")
                    .to_str()
                    .expect("Failed to convert OsStr to str");
                // Use regex to capture the version number
                let re =
                    Regex::new(r"MDD_v(\d+\.\d+)").expect("Failed to compile MDD version regex");
                if let Some(caps) = re.captures(file_stem) {
                    caps.get(1)
                        .map_or("unknown".to_string(), |m| m.as_str().to_string())
                } else {
                    "unknown".to_string()
                }
            }
        }
    }

    // We infer release date from the metadata if not specified.
    fn get_release_date(&self) -> String {
        match self.release_date {
            Some(date) => date.to_string(),
            None => {
                let file_meta =
                    fs::metadata(self.input_path).expect("Failed to read file metadata");
                let modified_time = file_meta
                    .modified()
                    .expect("Failed to get file modified time");
                let date = DateTime::<chrono::Local>::from(modified_time);
                date.format("%B %e, %Y").to_string()
            }
        }
    }

    fn limit_mdd_data(&self, data: &mut Vec<MddData>, limit: usize) {
        data.truncate(limit);
    }

    fn limit_synonym_data(&self, data: &mut Vec<SynonymData>, limit: usize) {
        data.truncate(limit);
    }

    fn write_plain_text(&self, data: &str) {
        let output = self.get_output_path(false);
        std::fs::write(output, data).expect("Unable to write file");
    }

    fn write_gzip(&self, data: &str) {
        let output = self.get_output_path(true);
        let file = std::fs::File::create(output).expect("Unable to create file");
        let mut encoder = flate2::write::GzEncoder::new(file, flate2::Compression::default());
        std::io::Write::write_all(&mut encoder, data.as_bytes()).expect("Unable to write file");
    }

    fn get_output_path(&self, is_gunzip: bool) -> PathBuf {
        let fname = match self.prefix {
            Some(prefix) => prefix,
            None => DEFAULT_OUTPUT_FNAME,
        };
        let output = self.output_path.join(fname);
        if is_gunzip {
            output.with_extension(GZIP_EXT)
        } else {
            output.with_extension(JSON_EXT)
        }
    }
}

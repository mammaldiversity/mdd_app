use std::{
    fs,
    path::{Path, PathBuf},
};

use args::{Cli, JsonArgs};
use clap::Parser;
use mdd_api::parser::{
    country::CountryMDDStats, mdd::MddData, synonyms::SynonymData, ReleasedMddData,
};

mod args;

const DEFAULT_OUTPUT_FNAME: &str = "data";
const DEFAULT_COUNTRY_STATS_FNAME: &str = "country_stats";
const JSON_EXT: &str = "json";
const GZIP_EXT: &str = "json.gz";

fn main() {
    let args = Cli::parse();
    match args {
        Cli::ToJson(export) => {
            let parser = JsonParser::from_args(&export);
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

struct JsonParser<'a> {
    input_path: &'a Path,
    synonym_path: &'a Path,
    output_path: &'a Path,
    plain_text: bool,
    mdd_version: &'a str,
    release_date: &'a str,
    limit: Option<usize>,
    prefix: Option<&'a str>,
}

impl<'a> JsonParser<'a> {
    fn from_args(args: &'a JsonArgs) -> Self {
        Self {
            input_path: &args.input,
            synonym_path: &args.synonym,
            output_path: &args.output,
            plain_text: args.plain_text,
            mdd_version: &args.mdd_version,
            release_date: &args.release_date,
            limit: args.limit,
            prefix: args.prefix.as_deref(),
        }
    }

    fn parse_to_json(&self) {
        let mdd_data = std::fs::read_to_string(self.input_path).unwrap();
        let syn_data = std::fs::read_to_string(self.synonym_path).unwrap();

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
        let all_data = ReleasedMddData::from_parser(
            mdd_data,
            synonym_data,
            self.mdd_version,
            self.release_date,
        );
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

use std::path::{Path, PathBuf};

use args::{Cli, JsonArgs};
use clap::Parser;
use mdd_api::parser::{mdd::MddData, synonyms::SynonymData, ReleasedMddData};

mod args;

const DEFAULT_OUTPUT_FNAME: &str = "data";

fn main() {
    let args = Cli::parse();
    match args {
        Cli::ToJson(export) => {
            let parser = JsonParser::from_args(&export);
            parser.parse_to_json();
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
        let parser = MddData::new();
        let mut mdd_data = parser.from_csv_to_json(&mdd_data);
        let synonyms = SynonymData::new();
        let mut synonym_data = synonyms.from_csv_to_json(&syn_data);
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
        if self.plain_text {
            self.write_plain_text(&json);
            self.write_gzip(&json);
        } else {
            self.write_gzip(&json);
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
            output.with_extension("json.gz")
        } else {
            output.with_extension("json")
        }
    }
}

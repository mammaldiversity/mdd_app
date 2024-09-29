use std::path::Path;

use args::{Cli, JsonArgs};
use clap::Parser;
use mdd_api::parser::{mdd::MddData, synonyms::SynonymData, AllMddData};

mod args;

fn main() {
    let args = Cli::parse();
    match args {
        Cli::ToJson(export) => {
            let parser = JsonParser::from_args(&export);
            parser.parse_to_json();
        }
    }
}

struct JsonParser<'a> {
    input_path: &'a Path,
    synonym_path: &'a Path,
    output_path: &'a Path,
}

impl<'a> JsonParser<'a> {
    fn new(input_path: &'a Path, synonym_path: &'a Path, output_path: &'a Path) -> Self {
        Self {
            input_path,
            synonym_path,
            output_path,
        }
    }

    fn from_args(args: &'a JsonArgs) -> Self {
        Self::new(&args.input, &args.synonym, &args.output)
    }

    fn parse_to_json(&self) {
        let mdd_data = std::fs::read_to_string(self.input_path).unwrap();
        let syn_data = std::fs::read_to_string(self.synonym_path).unwrap();
        let parser = MddData::new();
        let mdd_data = parser.from_csv_to_json(&mdd_data);
        let synonyms = SynonymData::new();
        let synonym_data = synonyms.from_csv_to_json(&syn_data);
        let all_data = AllMddData::from_parser(mdd_data, synonym_data);
        let json = all_data.to_json();
        self.write_gzip(&json);
    }

    fn write_gzip(&self, data: &str) {
        let output = self.output_path.join("data.json.gz");
        let file = std::fs::File::create(output).expect("Unable to create file");
        let mut encoder = flate2::write::GzEncoder::new(file, flate2::Compression::default());
        std::io::Write::write_all(&mut encoder, data.as_bytes()).expect("Unable to write file");
    }
}

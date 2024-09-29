use std::path::Path;

use args::{Cli, JsonArgs};
use clap::Parser;
use mdd_api::parser::MddParser;

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
    output_path: &'a Path,
}

impl<'a> JsonParser<'a> {
    fn new(input_path: &'a Path, output_path: &'a Path) -> Self {
        Self {
            input_path,
            output_path,
        }
    }

    fn from_args(args: &'a JsonArgs) -> Self {
        Self::new(&args.input, &args.output)
    }

    fn parse_to_json(&self) {
        let csv_data = std::fs::read_to_string(self.input_path).unwrap();
        let parser = MddParser::new();
        let json_data = parser.from_csv_to_json(&csv_data);
        let output = self.output_path.join("data.json");
        std::fs::write(output, json_data).expect("Unable to write file");
    }
}

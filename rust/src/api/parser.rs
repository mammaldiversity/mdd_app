use mdd_api::parser::CsvToJSONParser;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn parse_csv_to_json(csv_data: &str) -> String {
    let parser = CsvToJSONParser::new();
    parser.parse_to_json(csv_data)
}

use mdd_api::parser::metadata::ReleaseToml;
use std::path::Path;

#[test]
fn test_from_file() {
    let release_meta = Path::new("tests/data/release.toml");

    let metadata = ReleaseToml::from_file(&release_meta).unwrap();
    let toml_content = std::fs::read_to_string(&release_meta).unwrap();
    let expected_metadata = ReleaseToml::from_toml(toml_content.as_str()).unwrap();

    assert_eq!(metadata.to_toml(), expected_metadata.to_toml());
}

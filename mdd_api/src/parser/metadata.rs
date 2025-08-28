//! Module to parse metadata information in the MDD release files.
use serde::{Deserialize, Serialize};

/// Metadata about the MDD release.
/// This metadata parse the version, release date, and other information
/// from TOML file.
/// # Example TOML format
/// ```toml
/// name = "MDD"
/// version = "2024.1"
/// release_date = "2024-06-01"
/// mdd_file = "mdd_2024_1.csv"
/// synonym_file = "synonyms_2024_1.csv"
/// remarks = "This is a sample release."
/// ```
///
///
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ReleaseToml {
    pub metadata: ReleaseMetadata,
}

impl ReleaseToml {
    pub fn from_file<P: AsRef<std::path::Path>>(
        path: P,
    ) -> Result<Self, Box<dyn std::error::Error>> {
        let content = std::fs::read_to_string(path)?;
        let metadata: Self = toml::from_str(&content)?;
        Ok(metadata)
    }

    pub fn from_toml(toml_str: &str) -> Result<Self, toml::de::Error> {
        toml::from_str(toml_str)
    }

    pub fn to_toml(&self) -> String {
        toml::to_string(self).expect("Failed to serialize to TOML")
    }
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct ReleaseMetadata {
    pub name: String,
    pub version: String,
    pub release_date: String,
    pub mdd_file: String,
    pub synonym_file: String,
    pub remarks: Option<String>,
}

impl ReleaseMetadata {
    pub fn new(
        name: String,
        version: String,
        release_date: String,
        mdd_file: String,
        synonym_file: String,
        remarks: Option<String>,
    ) -> Self {
        Self {
            name,
            version,
            release_date,
            mdd_file,
            synonym_file,
            remarks,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_release_metadata() {
        let toml_str = r#"
        [metadata]
        name = "MDD"
        version = "2024.1"
        release_date = "2024-06-01"
        mdd_file = "mdd_2024_1.csv"
        synonym_file = "synonyms_2024_1.csv"
        remarks = "This is a sample release."
        "#;

        let metadata = ReleaseToml::from_toml(toml_str).expect("Failed to parse TOML");
        assert_eq!(metadata.metadata.name, "MDD");
        assert_eq!(metadata.metadata.version, "2024.1");
        assert_eq!(metadata.metadata.release_date, "2024-06-01");
        assert_eq!(metadata.metadata.mdd_file, "mdd_2024_1.csv");
        assert_eq!(metadata.metadata.synonym_file, "synonyms_2024_1.csv");
        assert_eq!(
            metadata.metadata.remarks,
            Some("This is a sample release.".into())
        );
    }
}

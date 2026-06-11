#![allow(unexpected_cfgs)]
use flate2::read::GzDecoder;
use mdd_api::mdd::ReleasedMddData;
use mdd_api::mdd::{species::SpeciesData, synonyms::SynonymData};
use std::fs::File;
use std::io::Read;
use tar::Archive;
use toml::Value;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

use serde::Serialize;

#[derive(Serialize)]
pub struct MddHelper {
    /// MDD file version
    pub version: String,
    /// MDD release date
    pub release_date: String,
    /// MDD main data
    pub mdd_data: Vec<String>,
    /// Synonyms data
    pub syn_data: Vec<String>,
}

impl MddHelper {
    pub fn parse(bytes: Vec<u8>) -> Self {
        let mdd_data = ReleasedMddData::from_gz_bytes(&bytes);
        let (mdd, syn) = mdd_data.get_data();
        let version = mdd_data.get_version().to_string();
        let release_date = mdd_data.get_release_date().to_string();
        Self {
            version: version,
            release_date: release_date,
            mdd_data: mdd,
            syn_data: syn,
        }
    }

    pub fn parse_mdd_zip(zip_path: String) -> Self {
        let file = File::open(&zip_path).expect("Failed to open zip file");
        let mut archive = zip::ZipArchive::new(file).expect("Failed to read zip file");

        let mut mdd_csv = String::new();
        let mut syn_csv = String::new();
        let mut version = String::from("Unknown");
        let mut release_date = String::from("Unknown");

        for i in 0..archive.len() {
            let mut file = archive.by_index(i).expect("Failed to read zip entry");
            let file_name = file.name().to_string();

            if file_name.ends_with("release.toml") && !file_name.contains("__MACOSX") {
                let mut contents = String::new();
                if file.read_to_string(&mut contents).is_ok() {
                    if let Ok(toml_val) = contents.parse::<Value>() {
                        if let Some(metadata) = toml_val.get("metadata") {
                            if let Some(v) = metadata.get("version").and_then(|v| v.as_str()) {
                                version = v.to_string();
                            }
                            if let Some(d) = metadata.get("release_date").and_then(|d| d.as_str()) {
                                release_date = d.to_string();
                            }
                        }
                    }
                }
            } else if file_name.contains("MDD_v")
                && file_name.ends_with(".csv")
                && !file_name.contains("__MACOSX")
            {
                let _ = file.read_to_string(&mut mdd_csv);
            } else if file_name.contains("Species_Syn_v")
                && file_name.ends_with(".csv")
                && !file_name.contains("__MACOSX")
            {
                let _ = file.read_to_string(&mut syn_csv);
            }
        }

        let mdd_parser = SpeciesData::new();
        let syn_parser = SynonymData::new();

        let parsed_mdd = mdd_parser.from_csv(&mdd_csv);
        let parsed_syn = syn_parser.from_csv(&syn_csv);

        let released_data =
            ReleasedMddData::from_parser(parsed_mdd, parsed_syn, &version, &release_date);
        let (mdd, syn) = released_data.get_data();

        Self {
            version: version,
            release_date: release_date,
            mdd_data: mdd,
            syn_data: syn,
        }
    }
}

#[derive(Serialize)]
pub struct MilHelper {
    pub mil_data: String,
}

impl MilHelper {
    pub fn parse_mil_data(tar_path: String) -> Self {
        let mut json_content = String::new();

        if tar_path.ends_with(".json") {
            let mut raw_file = std::fs::File::open(&tar_path).expect("Failed to open JSON file");
            raw_file
                .read_to_string(&mut json_content)
                .unwrap_or_default();
        } else {
            let file = File::open(&tar_path).expect("Failed to open tar.gz file");
            let tar = GzDecoder::new(file);
            let mut archive = Archive::new(tar);

            if let Ok(entries) = archive.entries() {
                for file in entries.flatten() {
                    let path = file.path().unwrap_or_default();
                    let path_str = path.to_string_lossy();

                    if (path_str.ends_with("mil.json") || path_str.ends_with(".json"))
                        && !path_str.contains("__MACOSX")
                    {
                        let mut f = file;
                        if f.read_to_string(&mut json_content).is_ok() {
                            break;
                        }
                    }
                }
            }
        }

        if json_content.is_empty() {
            // fallback if it wasn't a tar.gz or just a raw json
            let mut raw_file =
                std::fs::File::open(&tar_path).expect("Failed to open fallback file");
            raw_file
                .read_to_string(&mut json_content)
                .unwrap_or_default();
        }

        Self {
            mil_data: json_content,
        }
    }
}

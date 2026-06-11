#![allow(unexpected_cfgs)]
use mdd_api::mdd::metadata::ReleaseToml;
use mdd_api::mdd::ReleasedMddData;
use mdd_api::mdd::{species::SpeciesData, synonyms::SynonymData};
use mdd_api::mil::prep::MilParser;
use serde::Serialize;
use std::fs::File;
use std::io::Read;
use std::io::Write;
use tempdir::TempDir;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

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
                    if let Ok(release_toml) = ReleaseToml::from_toml(&contents) {
                        version = release_toml.metadata.version;
                        release_date = release_toml.metadata.release_date;
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
    pub fn parse_mil_data(tar_path: String, db_path: String) -> Self {
        let mut json_content = String::new();

        if tar_path.ends_with(".json") {
            let mut raw_file = File::open(&tar_path).expect("Failed to open JSON file");
            raw_file
                .read_to_string(&mut json_content)
                .unwrap_or_default();
        } else {
            // Create a temporary directory
            if let Ok(temp_dir) = TempDir::new("mil_update") {
                let temp_csv_path = temp_dir.path().join("temp_mdd.csv");
                let temp_json_path = temp_dir.path().join("temp_mil.json");

                // Query SQLite DB to build temp_mdd.csv
                if let Ok(conn) = rusqlite::Connection::open(&db_path) {
                    if let Ok(mut stmt) =
                        conn.prepare("SELECT id, genus, specificEpithet FROM taxonomy")
                    {
                        if let Ok(mut writer) = std::fs::File::create(&temp_csv_path) {
                            // Write CSV header
                            let _ = writeln!(writer, "id,genus,specificEpithet");
                            // Query rows and write
                            if let Ok(mut rows) = stmt.query([]) {
                                while let Ok(Some(row)) = rows.next() {
                                    if let (Ok(id), Ok(genus), Ok(specific_epithet)) = (
                                        row.get::<_, u32>(0),
                                        row.get::<_, String>(1),
                                        row.get::<_, String>(2),
                                    ) {
                                        let _ = writeln!(
                                            writer,
                                            "{},{},{}",
                                            id, genus, specific_epithet
                                        );
                                    }
                                }
                            }
                        }
                    }
                }

                let mil_file_path = std::path::Path::new(&tar_path);
                let mil_parser =
                    MilParser::new(mil_file_path, &temp_csv_path, None, &temp_json_path);
                if mil_parser.prepare_metadata().is_ok() {
                    if let Ok(mut json_file) = std::fs::File::open(&temp_json_path) {
                        let _ = json_file.read_to_string(&mut json_content);
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs::File;
    use std::io::Write;
    use zip::write::SimpleFileOptions;
    use zip::ZipWriter;

    fn get_mock_mdd_csv() -> &'static str {
        "id,sciName,mainCommonName,otherCommonNames,phylosort,subclass,infraclass,magnorder,superorder,order,suborder,infraorder,parvorder,superfamily,family,subfamily,tribe,genus,subgenus,specificEpithet,authoritySpeciesAuthor,authoritySpeciesYear,authorityParentheses,originalNameCombination,authoritySpeciesCitation,authoritySpeciesLink,typeVoucher,typeKind,typeVoucherURIs,typeLocality,typeLocalityLatitude,typeLocalityLongitude,nominalNames,taxonomyNotes,taxonomyNotesCitation,distributionNotes,distributionNotesCitation,subregionDistribution,countryDistribution,continentDistribution,biogeographicRealm,iucnStatus,extinct,domestic,flagged,CMW_sciName,diffSinceCMW,MSW3_matchtype,MSW3_sciName,diffSinceMSW3\n\
        100,Mus musculus,,,1,,,,,,,,,,,,,Mus,,musculus,,0,0,,,,,,,,,,,,,,,,,,,,0,0,0,,0,,,\n"
    }

    fn get_mock_syn_csv() -> &'static str {
        "MDD_syn_id,hesp_id,species_id,species,root_name,author,year,authority_parentheses,nomenclature_status,validity,original_combination,original_rank,authority_citation,unchecked_authority_citation,sourced_unverified_citations,citation_group,citation_kind,authority_page,authority_link,authority_page_link,unchecked_authority_page_link,old_type_locality,original_type_locality,unchecked_type_locality,emended_type_locality,type_latitude,type_longitude,type_country,type_subregion,type_subregion2,holotype,type_kind,type_specimen_link,order,family,genus,specific_epithet,subspecific_epithet,variant_of,senior_homonym,variant_name_citations,name_usages,comments\n\
        1,0,100,Mus musculus,Mus musculus,Linnaeus,1758,0,,valid,,species,citation,,,,,,link,,,loc,loc2,,loc3,0,0,Country,Sub,Sub2,Holotype,Kind,SpecLink,Rodentia,Muridae,Mus,musculus,,,,,,\n"
    }

    #[test]
    fn test_parse_mdd_zip_with_release_toml() {
        let temp_dir = std::env::temp_dir();
        let zip_path = temp_dir.join("test_mdd_release.zip");

        let file = File::create(&zip_path).unwrap();
        let mut zip = ZipWriter::new(file);
        let options = SimpleFileOptions::default();

        zip.start_file("MDD/release.toml", options).unwrap();
        zip.write_all(
            br#"[metadata]
name = "The Mammal Diversity Database"
version = "v2.4"
release_date = "2026-01-02"
mdd_file = "MDD_v2.4_6871species.csv"
synonym_file = "Species_Syn_v2.4.csv"
zenodo_citation = "test citation"
remarks = "test remarks"
"#,
        )
        .unwrap();

        zip.start_file("MDD/MDD_v2.4_6871species.csv", options)
            .unwrap();
        zip.write_all(get_mock_mdd_csv().as_bytes()).unwrap();

        zip.start_file("MDD/Species_Syn_v2.4.csv", options).unwrap();
        zip.write_all(get_mock_syn_csv().as_bytes()).unwrap();

        zip.finish().unwrap();

        let helper = MddHelper::parse_mdd_zip(zip_path.to_str().unwrap().to_string());
        assert_eq!(helper.version, "v2.4");
        assert_eq!(helper.release_date, "2026-01-02");
        assert_eq!(helper.mdd_data.len(), 1);
        assert_eq!(helper.syn_data.len(), 0);

        let _ = std::fs::remove_file(zip_path);
    }
}

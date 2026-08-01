#![allow(unexpected_cfgs)]
use mdd_api::mdd::metadata::ReleaseToml;
use mdd_api::mdd::ReleasedMddData;
use mdd_api::mdd::{species::SpeciesData, synonyms::SynonymData};
use mdd_api::mil::prep::MilParser;
use serde::Serialize;
use std::fs::File;
use std::io::Read;
use std::io::Write;
use std::path::Path;
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
    /// MDD release remarks
    pub remarks: Option<String>,
    /// MDD release DOI
    pub doi: Option<String>,
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
        let remarks = mdd_data.get_remarks().map(|s| s.to_string());
        let doi = mdd_data.get_doi().map(|s| s.to_string());
        Self {
            version,
            release_date,
            remarks,
            doi,
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
        let mut remarks: Option<String> = None;
        let mut doi: Option<String> = None;

        for i in 0..archive.len() {
            let mut file = archive.by_index(i).expect("Failed to read zip entry");
            let file_name = file.name().to_string();

            if file_name.ends_with("release.toml") && !file_name.contains("__MACOSX") {
                let mut contents = String::new();
                if file.read_to_string(&mut contents).is_ok() {
                    if let Ok(release_toml) = ReleaseToml::from_toml(&contents) {
                        version = release_toml.metadata.version;
                        release_date = release_toml.metadata.release_date;
                        remarks = release_toml.metadata.remarks;
                        doi = release_toml.metadata.doi;
                    }
                }
            } else if file_name.contains("MDD_v")
                && file_name.ends_with(".csv")
                && !file_name.contains("__MACOSX")
            {
                let _ = file.read_to_string(&mut mdd_csv);
            } else if file_name.contains("Species_Syn_")
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

        let release_metadata = mdd_api::mdd::metadata::ReleaseMetadata {
            name: "MDD".to_string(),
            version: version.clone(),
            release_date: release_date.clone(),
            mdd_file: "".to_string(),
            synonym_file: "".to_string(),
            doi: doi.clone(),
            remarks: remarks.clone(),
        };
        let released_data = ReleasedMddData::from_parser(parsed_mdd, parsed_syn, &release_metadata);
        let (mdd, syn) = released_data.get_data();

        Self {
            version,
            release_date,
            remarks,
            doi,
            mdd_data: mdd,
            syn_data: syn,
        }
    }
}

#[derive(Serialize)]
pub struct MilHelper {
    pub mil_version: String,
    pub mil_data: String,
}

impl MilHelper {
    pub fn extract_mil_version(path: &str) -> String {
        let filename = Path::new(path)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(path);

        let re =
            regex::Regex::new(r"(?i)(mil-v\d{4}-\d{2}-\d{2}|v\d{4}-\d{2}-\d{2}|v\d+\.\d+\.\d+)")
                .unwrap();
        if let Some(mat) = re.find(filename) {
            mat.as_str().to_string()
        } else {
            let name = filename
                .strip_suffix(".tar.gz")
                .or_else(|| filename.strip_suffix(".tgz"))
                .or_else(|| filename.strip_suffix(".json"))
                .unwrap_or(filename);
            name.to_string()
        }
    }

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

                let mil_file_path = Path::new(&tar_path);
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

        // Copy MIL images to assets/mil-images
        let target_img_dir = Path::new("assets/mil-images");
        let _ = copy_mil_images(Path::new(&tar_path), target_img_dir);

        let mil_version = Self::extract_mil_version(&tar_path);

        Self {
            mil_version,
            mil_data: json_content,
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
pub fn copy_mil_images(
    tar_path: &Path,
    dest_dir: &Path,
) -> Result<usize, Box<dyn std::error::Error>> {
    if !dest_dir.exists() {
        std::fs::create_dir_all(dest_dir)?;
    }

    if tar_path.is_dir() {
        return copy_images_from_dir(tar_path, dest_dir);
    }

    let path_str = tar_path.to_string_lossy().to_lowercase();
    let file = File::open(tar_path)?;
    let mut count = 0;

    if path_str.ends_with(".tar.gz") || path_str.ends_with(".tgz") {
        let gz = flate2::read::GzDecoder::new(file);
        let mut archive = tar::Archive::new(gz);
        for entry in archive.entries()? {
            let mut entry = entry?;
            let entry_path = entry.path()?.to_path_buf();
            let entry_str = entry_path.to_string_lossy();
            if entry_str.contains("images-540px-webp") {
                if let Some(ext) = entry_path.extension() {
                    let ext_str = ext.to_string_lossy().to_lowercase();
                    if ext_str == "webp"
                        || ext_str == "jpg"
                        || ext_str == "jpeg"
                        || ext_str == "png"
                    {
                        if let Some(file_name) = entry_path.file_name() {
                            let out_path = dest_dir.join(file_name);
                            let mut out_file = File::create(&out_path)?;
                            std::io::copy(&mut entry, &mut out_file)?;
                            count += 1;
                        }
                    }
                }
            }
        }
    } else if path_str.ends_with(".tar") {
        let mut archive = tar::Archive::new(file);
        for entry in archive.entries()? {
            let mut entry = entry?;
            let entry_path = entry.path()?.to_path_buf();
            let entry_str = entry_path.to_string_lossy();
            if entry_str.contains("images-540px-webp") {
                if let Some(ext) = entry_path.extension() {
                    let ext_str = ext.to_string_lossy().to_lowercase();
                    if ext_str == "webp"
                        || ext_str == "jpg"
                        || ext_str == "jpeg"
                        || ext_str == "png"
                    {
                        if let Some(file_name) = entry_path.file_name() {
                            let out_path = dest_dir.join(file_name);
                            let mut out_file = File::create(&out_path)?;
                            std::io::copy(&mut entry, &mut out_file)?;
                            count += 1;
                        }
                    }
                }
            }
        }
    } else if path_str.ends_with(".zip") {
        let mut archive = zip::ZipArchive::new(file)?;
        for i in 0..archive.len() {
            let mut entry = archive.by_index(i)?;
            let entry_str = entry.name().to_string();
            if entry_str.contains("images-540px-webp") {
                let entry_path = std::path::Path::new(&entry_str);
                if let Some(ext) = entry_path.extension() {
                    let ext_str = ext.to_string_lossy().to_lowercase();
                    if ext_str == "webp"
                        || ext_str == "jpg"
                        || ext_str == "jpeg"
                        || ext_str == "png"
                    {
                        if let Some(file_name) = entry_path.file_name() {
                            let out_path = dest_dir.join(file_name);
                            let mut out_file = File::create(&out_path)?;
                            std::io::copy(&mut entry, &mut out_file)?;
                            count += 1;
                        }
                    }
                }
            }
        }
    }

    Ok(count)
}

fn copy_images_from_dir(
    src_dir: &std::path::Path,
    dest_dir: &std::path::Path,
) -> Result<usize, Box<dyn std::error::Error>> {
    let mut count = 0;
    if let Ok(entries) = std::fs::read_dir(src_dir) {
        for entry in entries.flatten() {
            let p = entry.path();
            if p.is_dir() {
                count += copy_images_from_dir(&p, dest_dir)?;
            } else if p.is_file() {
                let path_str = p.to_string_lossy();
                let is_in_image_folder = path_str.contains("images-540px-webp")
                    || p.parent().map_or(false, |parent| {
                        parent
                            .file_name()
                            .map_or(false, |n| n == "images-540px-webp")
                    });
                if is_in_image_folder {
                    if let Some(ext) = p.extension() {
                        let ext_str = ext.to_string_lossy().to_lowercase();
                        if ext_str == "webp"
                            || ext_str == "jpg"
                            || ext_str == "jpeg"
                            || ext_str == "png"
                        {
                            if let Some(file_name) = p.file_name() {
                                let out_path = dest_dir.join(file_name);
                                std::fs::copy(&p, &out_path)?;
                                count += 1;
                            }
                        }
                    }
                }
            }
        }
    }
    Ok(count)
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

    #[test]
    fn test_parse_mdd_zip_with_species_syn_current() {
        let temp_dir = std::env::temp_dir();
        let zip_path = temp_dir.join("test_mdd_current_release.zip");

        let file = File::create(&zip_path).unwrap();
        let mut zip = ZipWriter::new(file);
        let options = SimpleFileOptions::default();

        zip.start_file("MDD/MDD_v2.5_6871species.csv", options).unwrap();
        zip.write_all(get_mock_mdd_csv().as_bytes()).unwrap();

        zip.start_file("MDD/Species_Syn_Current_v2.5.csv", options).unwrap();
        zip.write_all(get_mock_syn_csv().as_bytes()).unwrap();

        zip.finish().unwrap();

        let helper = MddHelper::parse_mdd_zip(zip_path.to_str().unwrap().to_string());
        assert_eq!(helper.mdd_data.len(), 1);

        let _ = std::fs::remove_file(zip_path);
    }
}

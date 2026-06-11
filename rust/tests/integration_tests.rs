use rust_lib_mdd::api::parser::{MddHelper, MilHelper};
use rust_lib_mdd::db_generator::generate_db;
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
fn test_database_generation_end_to_end() {
    let temp_dir = std::env::temp_dir();

    // 1. Create a mock MDD zip file
    let zip_path = temp_dir.join("test_integration_mdd.zip");
    let file = File::create(&zip_path).unwrap();
    let mut zip = ZipWriter::new(file);
    let options = SimpleFileOptions::default();

    zip.start_file("MDD/release.toml", options).unwrap();
    zip.write_all(
        br#"[metadata]
name = "The Mammal Diversity Database"
version = "v9.9.9"
release_date = "2099-12-31"
mdd_file = "MDD_v9.9.9.csv"
synonym_file = "Species_Syn_v9.9.9.csv"
 zenodo_citation = "some citation"
remarks = "some remarks"
"#,
    )
    .unwrap();

    zip.start_file("MDD/MDD_v9.9.9.csv", options).unwrap();
    zip.write_all(get_mock_mdd_csv().as_bytes()).unwrap();

    zip.start_file("MDD/Species_Syn_v9.9.9.csv", options)
        .unwrap();
    zip.write_all(get_mock_syn_csv().as_bytes()).unwrap();
    zip.finish().unwrap();

    // 2. Create a mock MIL json file
    let mil_json_path = temp_dir.join("test_integration_mil.json");
    let mil_content = r#"[
        {
            "milId": "MIL1001",
            "mddId": 100,
            "orientation": "landscape",
            "isUncertainIdentification": false
        }
    ]"#;
    let mut mil_file = File::create(&mil_json_path).unwrap();
    mil_file.write_all(mil_content.as_bytes()).unwrap();

    // 3. Parse data using Helpers
    let mdd_helper = MddHelper::parse_mdd_zip(zip_path.to_str().unwrap().to_string());
    let mil_helper =
        MilHelper::parse_mil_data(mil_json_path.to_str().unwrap().to_string(), String::new());

    // 4. Generate SQLite DB
    let db_path = temp_dir.join("test_integration_mdd.db");
    let db_path_str = db_path.to_str().unwrap();
    let drift_path = "../lib/services/database/tables.drift";

    let gen_res = generate_db(&mdd_helper, &mil_helper, db_path_str, drift_path);
    assert!(
        gen_res.is_ok(),
        "Database generation failed: {:?}",
        gen_res.err()
    );

    // 5. Verify database contents
    let conn = rusqlite::Connection::open(&db_path).unwrap();

    // Check mddInfo
    let mut stmt = conn
        .prepare("SELECT version, releaseDate FROM mddInfo")
        .unwrap();
    let mut rows = stmt.query([]).unwrap();
    let row = rows.next().unwrap().unwrap();
    let version: String = row.get(0).unwrap();
    let release_date: String = row.get(1).unwrap();
    assert_eq!(version, "v9.9.9");
    assert_eq!(release_date, "2099-12-31");

    // Check taxonomy
    let mut stmt = conn
        .prepare("SELECT id, genus, specificEpithet, sciName FROM taxonomy")
        .unwrap();
    let mut rows = stmt.query([]).unwrap();
    let row = rows.next().unwrap().unwrap();
    let id: i64 = row.get(0).unwrap();
    let genus: String = row.get(1).unwrap();
    let epithet: String = row.get(2).unwrap();
    let sci_name: String = row.get(3).unwrap();
    assert_eq!(id, 100);
    assert_eq!(genus, "Mus");
    assert_eq!(epithet, "musculus");
    assert_eq!(sci_name, "Mus musculus");

    // Check milData
    let mut stmt = conn
        .prepare("SELECT milId, mddId, orientation, isUncertainIdentification FROM milData")
        .unwrap();
    let mut rows = stmt.query([]).unwrap();
    let row = rows.next().unwrap().unwrap();
    let mil_id: String = row.get(0).unwrap();
    let mdd_id: i64 = row.get(1).unwrap();
    let orientation: String = row.get(2).unwrap();
    let uncertain: i64 = row.get(3).unwrap();
    assert_eq!(mil_id, "MIL1001");
    assert_eq!(mdd_id, 100);
    assert_eq!(orientation, "landscape");
    assert_eq!(uncertain, 0);

    // Clean up
    let _ = std::fs::remove_file(zip_path);
    let _ = std::fs::remove_file(mil_json_path);
    let _ = std::fs::remove_file(db_path);
}

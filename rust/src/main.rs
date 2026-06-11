use mdd_api::mil::prep::MilParser;
use rust_lib_mdd::api::parser::{MddHelper, MilHelper};
use rust_lib_mdd::db_generator;
use std::env;
use std::path::Path;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().collect();

    let mdd_zip_path = if args.len() > 1 {
        &args[1]
    } else {
        "data/MDD.zip"
    };
    let mil_tar_path = if args.len() > 2 {
        &args[2]
    } else {
        "data/MIL.tar.gz"
    };

    println!("Parsing MDD from {}", mdd_zip_path);
    let mdd_helper = MddHelper::parse_mdd_zip(mdd_zip_path.to_string());

    println!("Parsing MIL from {}", mil_tar_path);
    let mil_helper = if mil_tar_path.ends_with(".json") {
        MilHelper::parse_mil_data(mil_tar_path.to_string(), String::new())
    } else {
        let temp_dir = tempdir::TempDir::new("mil_main").expect("Failed to create temp dir");
        let temp_csv_path = temp_dir.path().join("mdd.csv");
        let temp_json_path = temp_dir.path().join("mil.json");

        // Extract mdd.csv from mdd_zip_path
        let file = std::fs::File::open(&mdd_zip_path).expect("Failed to open MDD zip");
        let mut archive = zip::ZipArchive::new(file).expect("Failed to read MDD zip");
        let mut extracted = false;
        for i in 0..archive.len() {
            let mut file = archive.by_index(i).expect("Failed to read zip entry");
            let file_name = file.name().to_string();
            if file_name.contains("MDD_v")
                && file_name.ends_with(".csv")
                && !file_name.contains("__MACOSX")
            {
                let mut out =
                    std::fs::File::create(&temp_csv_path).expect("Failed to create temp CSV");
                std::io::copy(&mut file, &mut out).expect("Failed to copy CSV file");
                extracted = true;
                break;
            }
        }
        assert!(extracted, "Could not find MDD species CSV file in MDD.zip");

        // Call prepare_metadata
        let mil_parser = MilParser::new(
            Path::new(mil_tar_path),
            &temp_csv_path,
            None,
            &temp_json_path,
        );
        mil_parser
            .prepare_metadata()
            .expect("Failed to prepare MIL metadata");

        let mut json_content = String::new();
        let mut json_file =
            std::fs::File::open(&temp_json_path).expect("Failed to open prepared MIL JSON");
        use std::io::Read;
        json_file
            .read_to_string(&mut json_content)
            .expect("Failed to read prepared MIL JSON");

        MilHelper {
            mil_data: json_content,
        }
    };

    println!("Generating database dynamically from tables.drift...");
    let db_path = "assets/data/mdd.db";
    let drift_path = "lib/services/database/tables.drift";

    if let Err(e) = db_generator::generate_db(&mdd_helper, &mil_helper, db_path, drift_path) {
        eprintln!("Database generation failed: {}", e);
        exit(1);
    }

    println!("Database generation complete!");
}

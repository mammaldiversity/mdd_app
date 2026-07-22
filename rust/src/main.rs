use clap::Parser;
use mdd_api::mil::prep::MilParser;
use rust_lib_mdd::api::parser::{copy_mil_images, MddHelper, MilHelper};
use rust_lib_mdd::db_generator;
use std::path::Path;
use std::process::exit;

/// MDD & MIL Prefilled Database Generator
#[derive(Parser, Debug)]
#[command(author, version, about = "Generate prefilled mdd.db SQLite database from MDD zip and MIL tar.gz/json", long_about = None)]
pub struct Cli {
    /// Path to MDD zip file (e.g. data/MDD.zip)
    #[arg(short = 'm', long = "mdd", value_name = "MDD_ZIP")]
    pub mdd: Option<String>,

    /// Path to MIL tar.gz/json file (e.g. data/mil-v2026-05-31.tar.gz)
    #[arg(short = 'i', long = "mil", value_name = "MIL_PATH")]
    pub mil: Option<String>,

    /// Output database file path
    #[arg(short = 'd', long = "db", default_value = "assets/data/mdd.db")]
    pub db: String,

    /// Path to Drift table definition file
    #[arg(short = 't', long = "drift", default_value = "lib/services/database/tables.drift")]
    pub drift: String,

    /// Positional fallback for MDD zip path
    #[arg(index = 1)]
    pub pos_mdd: Option<String>,

    /// Positional fallback for MIL tar path
    #[arg(index = 2)]
    pub pos_mil: Option<String>,
}

fn main() {
    let cli = Cli::parse();

    let mdd_zip_path = cli
        .mdd
        .or(cli.pos_mdd)
        .unwrap_or_else(|| "data/MDD.zip".to_string());
    let mil_tar_path = cli
        .mil
        .or(cli.pos_mil)
        .unwrap_or_else(|| "data/MIL.tar.gz".to_string());
    let db_path = cli.db;
    let drift_path = cli.drift;

    println!("Parsing MDD from {}", mdd_zip_path);
    let mdd_helper = MddHelper::parse_mdd_zip(mdd_zip_path.clone());

    let temp_dir = tempdir::TempDir::new("mil_main").expect("Failed to create temp dir");

    println!("Parsing MIL from {}", mil_tar_path);
    let mil_helper = if mil_tar_path.ends_with(".json") {
        MilHelper::parse_mil_data(mil_tar_path.clone(), String::new())
    } else {
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
            Path::new(&mil_tar_path),
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
            mil_version: MilHelper::extract_mil_version(&mil_tar_path),
            mil_data: json_content,
        }
    };

    println!("Generating database dynamically from {}...", drift_path);

    if let Err(e) = db_generator::generate_db(&mdd_helper, &mil_helper, &db_path, &drift_path) {
        eprintln!("Database generation failed: {}", e);
        exit(1);
    }

    println!("Copying MIL images to assets/mil-images...");
    let target_img_dir = Path::new("assets/mil-images");
    match copy_mil_images(Path::new(&mil_tar_path), target_img_dir) {
        Ok(count) => println!("Successfully copied {} MIL images to assets/mil-images", count),
        Err(e) => eprintln!("Warning: Failed to copy MIL images: {}", e),
    }

    println!("Database and MIL image update complete!");
}

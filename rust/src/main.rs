use rust_lib_mdd::api::parser::{MddHelper, MilHelper};
use std::env;
use std::process::exit;

mod db_generator;

fn main() {
    let args: Vec<String> = env::args().collect();
    
    let mdd_zip_path = if args.len() > 1 { &args[1] } else { "data/MDD.zip" };
    let mil_tar_path = if args.len() > 2 { &args[2] } else { "data/MIL.tar.gz" };

    println!("Parsing MDD from {}", mdd_zip_path);
    let mdd_helper = MddHelper::parse_mdd_zip(mdd_zip_path.to_string());
    
    println!("Parsing MIL from {}", mil_tar_path);
    let mil_helper = MilHelper::parse_mil_data(mil_tar_path.to_string());

    println!("Generating database dynamically from tables.drift...");
    let db_path = "assets/data/mdd.db";
    let drift_path = "lib/services/database/tables.drift";
    
    if let Err(e) = db_generator::generate_db(&mdd_helper, &mil_helper, db_path, drift_path) {
        eprintln!("Database generation failed: {}", e);
        exit(1);
    }

    println!("Database generation complete!");
}

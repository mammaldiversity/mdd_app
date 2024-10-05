use std::path::PathBuf;

use clap::{crate_authors, crate_description, crate_name, crate_version, Args, Parser};

#[derive(Parser)]
#[command(name = crate_name!(), version = crate_version!(), about = crate_description!(), author = crate_authors!())]
pub enum Cli {
    #[command(name = "json", about = "Parse and export MDD data to JSON")]
    ToJson(JsonArgs),
}

#[derive(Args)]
pub struct JsonArgs {
    #[arg(long, short, default_value = "data.csv", help = "Input MDD CSV file")]
    pub input: PathBuf,
    #[arg(
        long,
        short,
        default_value = "synonyms.csv",
        help = "Input synonyms CSV file"
    )]
    pub synonym: PathBuf,
    #[arg(
        long,
        short,
        default_value = "../assets/data",
        help = "Output directory"
    )]
    pub output: PathBuf,
    #[arg(long, short, help = "Export plain text data")]
    pub plain_text: bool,
    #[arg(long = "mdd", help = "MDD data version", require_equals = true)]
    pub mdd_version: String,
    #[arg(long = "date", help = "MDD release date", require_equals = true)]
    pub release_date: String,
}

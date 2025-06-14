use std::path::PathBuf;

use clap::{crate_authors, crate_description, crate_name, crate_version, Args, Parser};

#[derive(Parser)]
#[command(name = crate_name!(), version = crate_version!(), about = crate_description!(), author = crate_authors!())]
pub enum Cli {
    #[command(name = "json", about = "Parse and export MDD data to JSON")]
    ToJson(JsonArgs),
    #[command(name = "db", about = "Parse and export MDD data to SQLite database")]
    ToDb(DbArgs),
    #[command(name = "toml", about = "Parse and export MDD data from TOML file")]
    FromToml(FromTomlArgs),
    #[command(name = "zip", about = "Display help information")]
    FromZip(FromZipArgs),
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
    pub mdd_version: Option<String>,
    #[arg(long = "date", help = "MDD release date")]
    pub release_date: Option<String>,
    #[arg(long = "limit", help = "Limit number of records")]
    pub limit: Option<usize>,
    #[arg(long, help = "Add prefix to output files")]
    pub prefix: Option<String>,
}

#[derive(Args)]
pub struct DbArgs {
    #[arg(long, short, default_value = "data.json", help = "Input MDD CSV file")]
    pub input: PathBuf,
}

#[derive(Args)]
pub struct FromTomlArgs {
    #[arg(long, short, default_value = "data.toml", help = "Input MDD TOML file")]
    pub input: PathBuf,
    #[arg(long, short, default_value = ".", help = "Output directory")]
    pub output: PathBuf,
    #[arg(long, short, help = "Export plain text data")]
    pub plain_text: bool,
}

#[derive(Args)]
pub struct FromZipArgs {
    #[arg(long, short, default_value = "MDD.zip", help = "Input MDD ZIP file")]
    pub input: PathBuf,
    #[arg(
        long,
        short,
        default_value = "../assets/data",
        help = "Output directory"
    )]
    pub output: PathBuf,
}

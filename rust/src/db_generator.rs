use rusqlite::{params_from_iter, Connection, Result};
use std::fs;
use std::path::Path;
use regex::Regex;
use serde_json::Value;
use rust_lib_mdd::api::parser::{MddHelper, MilHelper};

pub fn generate_db(mdd_helper: &MddHelper, mil_helper: &MilHelper, db_path: &str, drift_path: &str) -> Result<()> {
    if Path::new(db_path).exists() {
        fs::remove_file(db_path).unwrap();
    }
    
    if let Some(parent) = Path::new(db_path).parent() {
        fs::create_dir_all(parent).unwrap();
    }

    let mut conn = Connection::open(db_path)?;
    let drift_content = fs::read_to_string(drift_path).expect("Failed to read tables.drift");

    // Parse CREATE TABLE statements
    let table_re = Regex::new(r"(?i)CREATE\s+TABLE\s+(\w+)\s*\(([^;]+)\);").unwrap();
    
    let mut table_queries = Vec::new();
    let mut table_columns = std::collections::HashMap::new();

    for cap in table_re.captures_iter(&drift_content) {
        let table_name = cap[1].to_string();
        let columns_block = cap[2].to_string();
        
        let full_query = format!("CREATE TABLE {} ({})", table_name, columns_block);
        table_queries.push(full_query);

        let mut cols = Vec::new();
        for line in columns_block.lines() {
            let line = line.trim();
            if line.is_empty() { continue; }
            let parts: Vec<&str> = line.split_whitespace().collect();
            if !parts.is_empty() {
                let col_name = parts[0];
                cols.push(col_name.to_string());
            }
        }
        table_columns.insert(table_name, cols);
    }

    // Execute CREATE TABLE
    for query in table_queries {
        conn.execute(&query, [])?;
    }

    let tx = conn.transaction()?;

    // Insert mddInfo
    tx.execute(
        "INSERT INTO mddInfo (version, releaseDate) VALUES (?1, ?2)",
        [&mdd_helper.version, &mdd_helper.release_date],
    )?;

    // Prepare taxonomy and synonym statements
    let mut tax_stmt = tx.prepare(&format!(
        "INSERT INTO taxonomy ({}) VALUES ({})",
        table_columns["taxonomy"].join(", "),
        vec!["?"; table_columns["taxonomy"].len()].join(", ")
    ))?;

    let mut syn_stmt = tx.prepare(&format!(
        "INSERT INTO synonym ({}) VALUES ({})",
        table_columns["synonym"].join(", "),
        vec!["?"; table_columns["synonym"].len()].join(", ")
    ))?;

    // Insert taxonomy and its synonyms
    for item_str in &mdd_helper.mdd_data {
        let v: Value = serde_json::from_str(item_str).unwrap_or(Value::Null);
        if let Some(species_data) = v.get("speciesData") {
            let mut params = Vec::new();
            for col in &table_columns["taxonomy"] {
                params.push(extract_value(species_data, col));
            }
            tax_stmt.execute(params_from_iter(params))?;
        }

        if let Some(syns) = v.get("synonyms").and_then(|s| s.as_array()) {
            for syn in syns {
                let mut params = Vec::new();
                for col in &table_columns["synonym"] {
                    params.push(extract_value(syn, col));
                }
                syn_stmt.execute(params_from_iter(params))?;
            }
        }
    }

    // Insert extra synonyms
    for syn_str in &mdd_helper.syn_data {
        let v: Value = serde_json::from_str(syn_str).unwrap_or(Value::Null);
        let mut params = Vec::new();
        for col in &table_columns["synonym"] {
            params.push(extract_value(&v, col));
        }
        syn_stmt.execute(params_from_iter(params))?;
    }

    // Insert milData
    if let Ok(Value::Array(mil_arr)) = serde_json::from_str(&mil_helper.mil_data) {
        if let Some(mil_cols) = table_columns.get("milData") {
            let mut mil_stmt = tx.prepare(&format!(
                "INSERT INTO milData ({}) VALUES ({})",
                mil_cols.join(", "),
                vec!["?"; mil_cols.len()].join(", ")
            ))?;
            
            for item in mil_arr {
                let mut params = Vec::new();
                for col in mil_cols {
                    params.push(extract_value(&item, col));
                }
                mil_stmt.execute(params_from_iter(params))?;
            }
            mil_stmt.finalize()?;
        }
    }

    tax_stmt.finalize()?;
    syn_stmt.finalize()?;
    tx.commit()?;

    Ok(())
}

fn extract_value<'a>(val: &'a Value, col: &str) -> rusqlite::types::ToSqlOutput<'a> {
    use rusqlite::types::{ToSqlOutput, Value as SqlValue};
    
    if let Some(v) = val.get(col) {
        match v {
            Value::Null => {
                if col == "mddId" || col == "id" || col == "isUncertainIdentification" {
                    ToSqlOutput::Owned(SqlValue::Integer(0))
                } else if col == "milId" {
                    ToSqlOutput::Owned(SqlValue::Text(String::new()))
                } else {
                    ToSqlOutput::Owned(SqlValue::Null)
                }
            },
            Value::Bool(b) => ToSqlOutput::Owned(SqlValue::Integer(if *b { 1 } else { 0 })),
            Value::Number(n) => {
                if let Some(i) = n.as_i64() {
                    ToSqlOutput::Owned(SqlValue::Integer(i))
                } else if let Some(f) = n.as_f64() {
                    ToSqlOutput::Owned(SqlValue::Real(f))
                } else {
                    ToSqlOutput::Owned(SqlValue::Null)
                }
            },
            Value::String(s) => {
                if col == "mddId" || col == "id" {
                    if let Ok(i) = s.parse::<i64>() {
                        return ToSqlOutput::Owned(SqlValue::Integer(i));
                    }
                    return ToSqlOutput::Owned(SqlValue::Integer(0));
                }
                ToSqlOutput::Owned(SqlValue::Text(s.clone()))
            },
            _ => {
                // Object or array fallback to string
                ToSqlOutput::Owned(SqlValue::Text(v.to_string()))
            }
        }
    } else {
        if col == "mddId" || col == "id" || col == "isUncertainIdentification" {
            ToSqlOutput::Owned(SqlValue::Integer(0))
        } else if col == "milId" {
            ToSqlOutput::Owned(SqlValue::Text(String::new()))
        } else {
            ToSqlOutput::Owned(SqlValue::Null)
        }
    }
}

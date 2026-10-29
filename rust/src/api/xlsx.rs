//! Module for writing Excel (.xlsx) workbooks.

use mdd_api::mdd::species::SpeciesData;
use rust_xlsxwriter::{Format, Workbook, Worksheet, XlsxError};
use serde_json::{Map, Value};

/// Excel's limit on characters in one cell.
const MAX_CELL_CHARS: usize = 32_767;
/// Excel's limit on characters in a sheet name.
const MAX_SHEET_NAME_CHARS: usize = 31;
/// Caps autofit so long notes don't make columns screen-wide.
const MAX_COLUMN_WIDTH_PX: u32 = 400;

/// One worksheet. `json_rows` is a JSON array of objects; each cell is
/// looked up by its header, so keys missing from a row leave the cell empty.
pub struct XlsxSheet {
    pub name: String,
    pub headers: Vec<String>,
    pub json_rows: String,
}

/// Writes `sheets` to a workbook at `output_path` and returns the path.
pub fn write_xlsx(output_path: String, sheets: Vec<XlsxSheet>) -> Result<String, String> {
    let mut workbook = Workbook::new();
    let header_format = Format::new().set_bold();
    for sheet in &sheets {
        let rows: Vec<Map<String, Value>> = serde_json::from_str(&sheet.json_rows)
            .map_err(|e| format!("Invalid rows for sheet {}: {e}", sheet.name))?;
        let worksheet = workbook.add_worksheet();
        write_sheet(worksheet, sheet, &rows, &header_format).map_err(|e| e.to_string())?;
    }
    workbook.save(&output_path).map_err(|e| e.to_string())?;
    Ok(output_path)
}

/// Builds the species sheet from the app's taxonomy JSON, with the same
/// columns as the species CSV written by `MddWriter`.
pub fn species_xlsx_sheet(json_data: String) -> Result<XlsxSheet, String> {
    let records: Vec<SpeciesData> =
        serde_json::from_str(&json_data).map_err(|e| format!("Invalid species data: {e}"))?;
    let rows = records
        .iter()
        .map(serde_json::to_value)
        .collect::<Result<Vec<Value>, _>>()
        .map_err(|e| e.to_string())?;
    let headers = match serde_json::to_value(SpeciesData::default()) {
        Ok(Value::Object(map)) => map.keys().cloned().collect(),
        _ => Vec::new(),
    };
    Ok(XlsxSheet {
        name: String::from("Species"),
        headers,
        json_rows: Value::Array(rows).to_string(),
    })
}

fn write_sheet(
    worksheet: &mut Worksheet,
    sheet: &XlsxSheet,
    rows: &[Map<String, Value>],
    header_format: &Format,
) -> Result<(), XlsxError> {
    worksheet.set_name(sheet_name(&sheet.name))?;
    for (col, header) in sheet.headers.iter().enumerate() {
        worksheet.write_string_with_format(0, col as u16, header, header_format)?;
    }
    for (i, row) in rows.iter().enumerate() {
        let row_idx = i as u32 + 1;
        for (col, header) in sheet.headers.iter().enumerate() {
            let col = col as u16;
            match row.get(header) {
                Some(Value::Number(n)) => match n.as_f64() {
                    Some(n) => worksheet.write_number(row_idx, col, n)?,
                    None => worksheet.write_string(row_idx, col, n.to_string())?,
                },
                Some(Value::Bool(b)) => worksheet.write_boolean(row_idx, col, *b)?,
                Some(Value::String(s)) if !s.is_empty() => {
                    worksheet.write_string(row_idx, col, truncate(s))?
                }
                Some(v @ (Value::Array(_) | Value::Object(_))) => {
                    worksheet.write_string(row_idx, col, truncate(&v.to_string()))?
                }
                _ => worksheet,
            };
        }
    }
    worksheet.set_freeze_panes(1, 0)?;
    worksheet.set_autofit_max_width(MAX_COLUMN_WIDTH_PX);
    worksheet.autofit();
    Ok(())
}

/// Removes characters Excel forbids in sheet names and caps the length.
fn sheet_name(name: &str) -> String {
    let cleaned: String = name
        .chars()
        .filter(|c| !matches!(c, '[' | ']' | ':' | '*' | '?' | '/' | '\\'))
        .take(MAX_SHEET_NAME_CHARS)
        .collect();
    let cleaned = cleaned.trim_matches('\'').trim();
    if cleaned.is_empty() {
        String::from("Sheet1")
    } else {
        cleaned.to_string()
    }
}

fn truncate(text: &str) -> &str {
    match text.char_indices().nth(MAX_CELL_CHARS) {
        Some((idx, _)) => &text[..idx],
        None => text,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use calamine::{Data, Reader, Xlsx, open_workbook};

    fn read(path: &std::path::Path, sheet: &str) -> Vec<Vec<Data>> {
        let mut workbook: Xlsx<_> = open_workbook(path).expect("open workbook");
        let range = workbook.worksheet_range(sheet).expect("read sheet");
        range.rows().map(|r| r.to_vec()).collect()
    }

    #[test]
    fn writes_typed_cells_and_empty_sheets() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("out.xlsx");
        let long_text = "x".repeat(MAX_CELL_CHARS + 10);
        let rows = serde_json::json!([
            {"Order": "Rodentia", "Count": 2600, "Extinct": false, "Note": long_text},
            {"Order": "Chiroptera, \"bats\"", "Count": 1500.5, "Note": null},
        ]);
        let result = write_xlsx(
            path.to_string_lossy().to_string(),
            vec![
                XlsxSheet {
                    name: String::from("Data"),
                    headers: ["Order", "Count", "Extinct", "Note"]
                        .map(String::from)
                        .to_vec(),
                    json_rows: rows.to_string(),
                },
                XlsxSheet {
                    name: String::from("Syn/onyms"),
                    headers: vec![String::from("synId")],
                    json_rows: String::from("[]"),
                },
            ],
        );
        assert_eq!(result, Ok(path.to_string_lossy().to_string()));

        let data = read(&path, "Data");
        assert_eq!(data[0][1], Data::String(String::from("Count")));
        assert_eq!(data[1][0], Data::String(String::from("Rodentia")));
        assert_eq!(data[1][1], Data::Float(2600.0));
        assert_eq!(data[1][2], Data::Bool(false));
        assert_eq!(data[1][3].to_string().chars().count(), MAX_CELL_CHARS);
        assert_eq!(
            data[2][0],
            Data::String(String::from("Chiroptera, \"bats\""))
        );
        assert_eq!(data[2][1], Data::Float(1500.5));
        assert_eq!(data[2][3], Data::Empty);

        let synonyms = read(&path, "Synonyms");
        assert_eq!(synonyms, vec![vec![Data::String(String::from("synId"))]]);
    }

    #[test]
    fn rejects_invalid_rows() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("bad.xlsx");
        let result = write_xlsx(
            path.to_string_lossy().to_string(),
            vec![XlsxSheet {
                name: String::from("Data"),
                headers: vec![],
                json_rows: String::from("not json"),
            }],
        );
        assert!(result.is_err());
    }

    #[test]
    fn species_sheet_uses_csv_columns() {
        let mut species = serde_json::to_value(SpeciesData::default()).unwrap();
        let map = species.as_object_mut().unwrap();
        map.insert(String::from("id"), Value::from(1));
        map.insert(String::from("sciName"), Value::from("Mus_musculus"));
        // The app's taxonomy JSON names the order column `taxonOrder`.
        map.insert(String::from("taxonOrder"), Value::from("Rodentia"));
        let json = Value::Array(vec![species]).to_string();

        let sheet = species_xlsx_sheet(json).unwrap();
        assert_eq!(sheet.name, "Species");
        assert_eq!(sheet.headers[0], "id");
        assert!(sheet.headers.contains(&String::from("taxonOrder")));
        let rows: Vec<Map<String, Value>> = serde_json::from_str(&sheet.json_rows).unwrap();
        assert_eq!(rows[0]["taxonOrder"], "Rodentia");
        assert_eq!(rows[0]["sciName"], "Mus_musculus");
    }

    #[test]
    fn cleans_sheet_names() {
        assert_eq!(sheet_name("a[b]:c*d?e/f\\g"), "abcdefg");
        assert_eq!(sheet_name(&"s".repeat(40)).len(), MAX_SHEET_NAME_CHARS);
        assert_eq!(sheet_name("[]"), "Sheet1");
    }
}

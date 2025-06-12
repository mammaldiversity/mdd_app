/// List of countries with their respective alpha-2 codes.
/// This list is based on the ISO 3166-1 alpha-2 standard.
use std::collections::HashMap;

use serde::{Deserialize, Serialize};

/// List of (alpha-2 code, country name) tuples based on ISO 3166-1 alpha-2.
pub const COUNTRY_AND_CODES: [(&str, &str); 249] = [
    ("AF", "Afghanistan"),
    ("AX", "Åland Islands"),
    ("AL", "Albania"),
    ("DZ", "Algeria"),
    ("AS", "American Samoa"),
    ("AD", "Andorra"),
    ("AO", "Angola"),
    ("AI", "Anguilla"),
    ("AQ", "Antarctica"),
    ("AG", "Antigua and Barbuda"),
    ("AR", "Argentina"),
    ("AM", "Armenia"),
    ("AW", "Aruba"),
    ("AU", "Australia"),
    ("AT", "Austria"),
    ("AZ", "Azerbaijan"),
    ("BS", "Bahamas"),
    ("BH", "Bahrain"),
    ("BD", "Bangladesh"),
    ("BB", "Barbados"),
    ("BY", "Belarus"),
    ("BE", "Belgium"),
    ("BZ", "Belize"),
    ("BJ", "Benin"),
    ("BM", "Bermuda"),
    ("BT", "Bhutan"),
    ("BO", "Bolivia (Plurinational State of)"),
    ("BQ", "Bonaire, Sint Eustatius and Saba"),
    ("BA", "Bosnia and Herzegovina"),
    ("BW", "Botswana"),
    ("BV", "Bouvet Island"),
    ("BR", "Brazil"),
    ("IO", "British Indian Ocean Territory"),
    ("BN", "Brunei Darussalam"),
    ("BG", "Bulgaria"),
    ("BF", "Burkina Faso"),
    ("BI", "Burundi"),
    ("CV", "Cabo Verde"),
    ("KH", "Cambodia"),
    ("CM", "Cameroon"),
    ("CA", "Canada"),
    ("KY", "Cayman Islands"),
    ("CF", "Central African Republic"),
    ("TD", "Chad"),
    ("CL", "Chile"),
    ("CN", "China"),
    ("CX", "Christmas Island"),
    ("CC", "Cocos (Keeling) Islands"),
    ("CO", "Colombia"),
    ("KM", "Comoros"),
    ("CG", "Congo"),
    ("CD", "Congo, Democratic Republic of the"),
    ("CK", "Cook Islands"),
    ("CR", "Costa Rica"),
    ("CI", "Côte d'Ivoire"),
    ("HR", "Croatia"),
    ("CU", "Cuba"),
    ("CW", "Curaçao"),
    ("CY", "Cyprus"),
    ("CZ", "Czechia"),
    ("DK", "Denmark"),
    ("DJ", "Djibouti"),
    ("DM", "Dominica"),
    ("DO", "Dominican Republic"),
    ("EC", "Ecuador"),
    ("EG", "Egypt"),
    ("SV", "El Salvador"),
    ("GQ", "Equatorial Guinea"),
    ("ER", "Eritrea"),
    ("EE", "Estonia"),
    ("SZ", "Eswatini"),
    ("ET", "Ethiopia"),
    ("FK", "Falkland Islands (Malvinas)"),
    ("FO", "Faroe Islands"),
    ("FJ", "Fiji"),
    ("FI", "Finland"),
    ("FR", "France"),
    ("GF", "French Guiana"),
    ("PF", "French Polynesia"),
    ("TF", "French Southern Territories"),
    ("GA", "Gabon"),
    ("GM", "Gambia"),
    ("GE", "Georgia"),
    ("DE", "Germany"),
    ("GH", "Ghana"),
    ("GI", "Gibraltar"),
    ("GR", "Greece"),
    ("GL", "Greenland"),
    ("GD", "Grenada"),
    ("GP", "Guadeloupe"),
    ("GU", "Guam"),
    ("GT", "Guatemala"),
    ("GG", "Guernsey"),
    ("GN", "Guinea"),
    ("GW", "Guinea-Bissau"),
    ("GY", "Guyana"),
    ("HT", "Haiti"),
    ("HM", "Heard Island and McDonald Islands"),
    ("VA", "Holy See"),
    ("HN", "Honduras"),
    ("HK", "Hong Kong"),
    ("HU", "Hungary"),
    ("IS", "Iceland"),
    ("IN", "India"),
    ("ID", "Indonesia"),
    ("IR", "Iran (Islamic Republic of)"),
    ("IQ", "Iraq"),
    ("IE", "Ireland"),
    ("IM", "Isle of Man"),
    ("IL", "Israel"),
    ("IT", "Italy"),
    ("JM", "Jamaica"),
    ("JP", "Japan"),
    ("JE", "Jersey"),
    ("JO", "Jordan"),
    ("KZ", "Kazakhstan"),
    ("KE", "Kenya"),
    ("KI", "Kiribati"),
    ("KP", "Korea (Democratic People's Republic of)"),
    ("KR", "Korea, Republic of"),
    ("KW", "Kuwait"),
    ("KG", "Kyrgyzstan"),
    ("LA", "Lao People's Democratic Republic"),
    ("LV", "Latvia"),
    ("LB", "Lebanon"),
    ("LS", "Lesotho"),
    ("LR", "Liberia"),
    ("LY", "Libya"),
    ("LI", "Liechtenstein"),
    ("LT", "Lithuania"),
    ("LU", "Luxembourg"),
    ("MO", "Macao"),
    ("MG", "Madagascar"),
    ("MW", "Malawi"),
    ("MY", "Malaysia"),
    ("MV", "Maldives"),
    ("ML", "Mali"),
    ("MT", "Malta"),
    ("MH", "Marshall Islands"),
    ("MQ", "Martinique"),
    ("MR", "Mauritania"),
    ("MU", "Mauritius"),
    ("YT", "Mayotte"),
    ("MX", "Mexico"),
    ("FM", "Micronesia (Federated States of)"),
    ("MD", "Moldova, Republic of"),
    ("MC", "Monaco"),
    ("MN", "Mongolia"),
    ("ME", "Montenegro"),
    ("MS", "Montserrat"),
    ("MA", "Morocco"),
    ("MZ", "Mozambique"),
    ("MM", "Myanmar"),
    ("NA", "Namibia"),
    ("NR", "Nauru"),
    ("NP", "Nepal"),
    ("NL", "Netherlands"),
    ("NC", "New Caledonia"),
    ("NZ", "New Zealand"),
    ("NI", "Nicaragua"),
    ("NE", "Niger"),
    ("NG", "Nigeria"),
    ("NU", "Niue"),
    ("NF", "Norfolk Island"),
    ("MK", "North Macedonia"),
    ("MP", "Northern Mariana Islands"),
    ("NO", "Norway"),
    ("OM", "Oman"),
    ("PK", "Pakistan"),
    ("PW", "Palau"),
    ("PS", "Palestine, State of"),
    ("PA", "Panama"),
    ("PG", "Papua New Guinea"),
    ("PY", "Paraguay"),
    ("PE", "Peru"),
    ("PH", "Philippines"),
    ("PN", "Pitcairn"),
    ("PL", "Poland"),
    ("PT", "Portugal"),
    ("PR", "Puerto Rico"),
    ("QA", "Qatar"),
    ("RE", "Réunion"),
    ("RO", "Romania"),
    ("RU", "Russian Federation"),
    ("RW", "Rwanda"),
    ("BL", "Saint Barthélemy"),
    ("SH", "Saint Helena, Ascension and Tristan da Cunha"),
    ("KN", "Saint Kitts and Nevis"),
    ("LC", "Saint Lucia"),
    ("MF", "Saint Martin (French part)"),
    ("PM", "Saint Pierre and Miquelon"),
    ("VC", "Saint Vincent and the Grenadines"),
    ("WS", "Samoa"),
    ("SM", "San Marino"),
    ("ST", "Sao Tome and Principe"),
    ("SA", "Saudi Arabia"),
    ("SN", "Senegal"),
    ("RS", "Serbia"),
    ("SC", "Seychelles"),
    ("SL", "Sierra Leone"),
    ("SG", "Singapore"),
    ("SX", "Sint Maarten (Dutch part)"),
    ("SK", "Slovakia"),
    ("SI", "Slovenia"),
    ("SB", "Solomon Islands"),
    ("SO", "Somalia"),
    ("ZA", "South Africa"),
    ("GS", "South Georgia and the South Sandwich Islands"),
    ("SS", "South Sudan"),
    ("ES", "Spain"),
    ("LK", "Sri Lanka"),
    ("SD", "Sudan"),
    ("SR", "Suriname"),
    ("SJ", "Svalbard and Jan Mayen"),
    ("SE", "Sweden"),
    ("CH", "Switzerland"),
    ("SY", "Syrian Arab Republic"),
    ("TW", "Taiwan, Province of China"),
    ("TJ", "Tajikistan"),
    ("TZ", "Tanzania, United Republic of"),
    ("TH", "Thailand"),
    ("TL", "Timor-Leste"),
    ("TG", "Togo"),
    ("TK", "Tokelau"),
    ("TO", "Tonga"),
    ("TT", "Trinidad and Tobago"),
    ("TN", "Tunisia"),
    ("TR", "Turkey"),
    ("TM", "Turkmenistan"),
    ("TC", "Turks and Caicos Islands"),
    ("TV", "Tuvalu"),
    ("UG", "Uganda"),
    ("UA", "Ukraine"),
    ("AE", "United Arab Emirates"),
    ("GB", "United Kingdom"),
    ("UM", "United States Minor Outlying Islands"),
    ("US", "United States of America"),
    ("UY", "Uruguay"),
    ("UZ", "Uzbekistan"),
    ("VU", "Vanuatu"),
    ("VE", "Venezuela (Bolivarian Republic of)"),
    ("VN", "Viet Nam"),
    ("VG", "Virgin Islands (British)"),
    ("VI", "Virgin Islands (U.S.)"),
    ("WF", "Wallis and Futuna"),
    ("EH", "Western Sahara"),
    ("YE", "Yemen"),
    ("ZM", "Zambia"),
    ("ZW", "Zimbabwe"),
];

// Country names found in the MDD data that are not in the ISO list.
pub const NON_STANDARD_COUNTRY_CODES: [(&str, &str); 50] = [
    ("IN", "Andaman and Nicobar Islands"),
    ("IN", "Andaman Islands"),
    ("IR", "Iran"),
    ("PT", "Azores"),
    ("PT", "Madeira"),
    ("EC", "Galápagos Islands"),
    ("FK", "Falkland Islands"),
    ("TF", "French Southern and Antarctic Lands"),
    ("CV", "Cape Verde"),
    ("CI", "Cote d'Ivoire"),
    ("CI", "Côte d'Ivoire"),
    ("ST", "São Tomé and Príncipe"),
    ("ST", "São Tomé & Príncipe"),
    ("SX", "Sint Maarten"),
    ("MP", "Northern Marianas"),
    ("AG", "Antigua & Barbuda"),
    ("BO", "Bolivia"),
    ("BA", "Bosnia & Herzegovina"),
    ("VG", "British Virgin Islands"),
    ("BN", "Brunei"),
    ("CZ", "Czech Republic"),
    ("CD", "Democratic Republic of the Congo"),
    ("TL", "East Timor"),
    ("XK", "Kosovo"),
    ("LA", "Laos"),
    ("FM", "Micronesia"),
    ("MD", "Moldova"),
    ("KP", "North Korea"),
    ("PS", "Palestine"),
    ("CG", "Republic of the Congo"),
    ("RU", "Russia"),
    ("SH", "Saint Helena"),
    ("KN", "Saint Kitts & Nevis"),
    ("MF", "Saint Martin"),
    ("VC", "Saint Vincent & the Grenadines"),
    ("KR", "South Korea"),
    ("SY", "Syria"),
    ("TW", "Taiwan"),
    ("TZ", "Tanzania"),
    ("TT", "Trinidad & Tobago"),
    ("TC", "Turks & Caicos Islands"),
    ("US", "United States"),
    ("VI", "United States Virgin Islands"),
    ("VE", "Venezuela"),
    ("VN", "Vietnam"),
    ("FO", "Faroe"),
    ("AC", "Ascension"),
    ("RE", "Reunion"),
    ("GS", "South Georgia & the South Sandwich Islands"),
    ("WF", "Wallis & Futuna"),
];

/// List of non-country region names that were commented out above.
pub const KNOWN_REGION_NAMES: [(&str, &str); 16] = [
    ("ALS", "Alaska"),
    ("AND", "Andaman Islands"),
    ("AZO", "Azores"),
    ("BON", "Bonaire"),
    ("CNY", "Canary Islands"),
    ("COC", "Cocos Islands"),
    ("GAL", "Galapagos"),
    ("KER", "Kerguelen Islands"),
    ("MAD", "Madeira"),
    ("NIC", "Nicobar Islands"),
    ("PEI", "Prince Edward Islands"),
    ("REU", "Reunion"),
    ("SAB", "Saba"),
    ("STE", "Sint Eustatius"),
    ("SGS", "South Georgia & the South Sandwich Islands"),
    ("WAF", "Wallis & Futuna"),
];

pub const US_STATE_NAMES: [&str; 50] = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawai'i",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming",
];

lazy_static::lazy_static! {
    /// A static map that maps country names to their respective alpha-2 codes.
    static ref COUNTRY_MAP: HashMap<String, String> = {
        COUNTRY_AND_CODES.iter()
            .map(|&(code, name)| (name.to_string(), code.to_string()))
            .collect()
    };

    /// A static map that maps non-standard country names to their respective alpha-2 codes.
    static ref NON_STANDARD_COUNTRY_MAP: HashMap<String, String> = {
        NON_STANDARD_COUNTRY_CODES.iter()
            .map(|&(code, name)| (name.to_string(), code.to_string()))
            .collect()
    };

    /// A static map that maps known region names to their respective alpha-2 codes.
    static ref KNOWN_REGION_MAP: HashMap<String, String> = {
        KNOWN_REGION_NAMES.iter()
            .map(|&(code, name)| (name.to_string(), code.to_string()))
            .collect()
    };

    /// A static map that combines both standard and non-standard country names.
    static ref ALL_COUNTRY_REGION_MAP: HashMap<String, String> = {
        let mut map = COUNTRY_MAP.clone();
        map.extend(NON_STANDARD_COUNTRY_MAP.clone());
        map.extend(KNOWN_REGION_MAP.clone());
        map
    };
}

/// Gets the alpha-2 country code for a given country name.
/// If the country name is not found in the standard or non-standard maps,
/// it returns the country name as a fallback.
pub fn get_country_code(country_name: &str) -> String {
    // If not found, check the non-standard country map
    if let Some(code) = ALL_COUNTRY_REGION_MAP.get(country_name) {
        return code.to_string();
    } else {
        // If still not found, return the country name as is
        // This is useful for cases where the country name is not in the list
        // and we want to keep it as a fallback.
        return country_name.to_string();
    }
}

/// Utility function to check if a country name is in the standard list.
/// Match U.S states to United States for consistency.
pub fn is_known_country_region(country_name: &str) -> bool {
    let country_name = if US_STATE_NAMES.contains(&country_name) {
        "United States"
    } else {
        country_name
    };
    ALL_COUNTRY_REGION_MAP.contains_key(country_name)
}

fn get_country_region_map() -> &'static HashMap<String, String> {
    &ALL_COUNTRY_REGION_MAP
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CountryRegionCode {
    pub region_to_code: HashMap<String, String>,
    pub code_to_region: HashMap<String, String>,
}

impl CountryRegionCode {
    pub fn new() -> Self {
        let region_to_code = get_country_region_map().clone();
        let code_to_region = region_to_code
            .iter()
            .map(|(k, v)| (v.clone(), k.clone()))
            .collect();
        Self {
            region_to_code,
            code_to_region,
        }
    }

    pub fn get_code(&self, region: &str) -> Option<&String> {
        self.region_to_code.get(region)
    }

    pub fn get_region(&self, code: &str) -> Option<&String> {
        self.code_to_region.get(code)
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string(self).expect("Failed to serialize CountryRegionCode")
    }

    pub fn write_to_file<P: AsRef<std::path::Path>>(&self, path: P) {
        let json = self.to_json();
        std::fs::write(path, json).expect("Failed to write CountryRegionCode to file");
    }
}

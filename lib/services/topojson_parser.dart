import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TopoJsonParser {
  static final Map<String, String> mddToIsoMap = {
    'Ascension': 'AC',
    'United Arab Emirates': 'AE',
    'Afghanistan': 'AF',
    'Antigua and Barbuda': 'AG',
    'Anguilla': 'AI',
    'Albania': 'AL',
    'Armenia': 'AM',
    'Angola': 'AO',
    'Antarctica': 'AQ',
    'Argentina': 'AR',
    'American Samoa': 'US',
    'Austria': 'AT',
    'Australia': 'AU',
    'Aruba': 'AW',
    'Azerbaijan': 'AZ',
    'Azores': 'PT',
    'Bosnia and Herzegovina': 'BA',
    'Barbados': 'BB',
    'Bangladesh': 'BD',
    'Belgium': 'BE',
    'Burkina Faso': 'BF',
    'Bulgaria': 'BG',
    'Bahrain': 'BH',
    'Burundi': 'BI',
    'Benin': 'BJ',
    'Saint Barthélemy': 'FR',
    'Bermuda': 'BM',
    'Brunei': 'BN',
    'Bolivia': 'BO',
    'Bonaire': 'BON',
    'Brazil': 'BR',
    'Bahamas': 'BS',
    'Bhutan': 'BT',
    'Bouvet Island': 'NO',
    'Botswana': 'BW',
    'Belarus': 'BY',
    'Belize': 'BZ',
    'Canada': 'CA',
    'Democratic Republic of the Congo': 'CD',
    'Central African Republic': 'CF',
    'Republic of the Congo': 'CG',
    'Switzerland': 'CH',
    'Cote d\'Ivoire': 'CI',
    'Cook Islands': 'NZ',
    'Chile': 'CL',
    'Cameroon': 'CM',
    'China': 'CN',
    'Canary Islands': 'ES',
    'Colombia': 'CO',
    'Cocos Islands': 'AU',
    'Costa Rica': 'CR',
    'Cuba': 'CU',
    'Cape Verde': 'CV',
    'Curaçao': 'CW',
    'Christmas Island': 'AU',
    'Cyprus': 'CY',
    'Czech Republic': 'CZ',
    'Germany': 'DE',
    'Djibouti': 'DJ',
    'Denmark': 'DK',
    'Dominica': 'DM',
    'Dominican Republic': 'DO',
    'Algeria': 'DZ',
    'Ecuador': 'EC',
    'Estonia': 'EE',
    'Egypt': 'EG',
    'Eritrea': 'ER',
    'Spain': 'ES',
    'Ethiopia': 'ET',
    'Finland': 'FI',
    'Fiji': 'FJ',
    'Falkland Islands': 'FK',
    'Micronesia': 'FM',
    'Faroe': 'FO',
    'France': 'FR',
    'Gabon': 'GA',
    'United Kingdom': 'GB',
    'Grenada': 'GD',
    'Georgia': 'GE',
    'French Guiana': 'FR',
    'Ghana': 'GH',
    'Greenland': 'GL',
    'Gambia': 'GM',
    'Guinea': 'GN',
    'Guadeloupe': 'FR',
    'Equatorial Guinea': 'GQ',
    'Greece': 'GR',
    'South Georgia and the South Sandwich Islands': 'GS',
    'Guatemala': 'GT',
    'Guam': 'US',
    'Guinea-Bissau': 'GW',
    'Guyana': 'GY',
    'Honduras': 'HN',
    'Croatia': 'HR',
    'Haiti': 'HT',
    'Hungary': 'HU',
    'Indonesia': 'ID',
    'Ireland': 'IE',
    'Israel': 'IL',
    'India': 'IN',
    'Iraq': 'IQ',
    'Iran': 'IR',
    'Iceland': 'IS',
    'Italy': 'IT',
    'Jamaica': 'JM',
    'Jordan': 'JO',
    'Japan': 'JP',
    'Kenya': 'KE',
    'Kyrgyzstan': 'KG',
    'Cambodia': 'KH',
    'Kiribati': 'KI',
    'Comoros': 'KM',
    'Saint Kitts and Nevis': 'KN',
    'North Korea': 'KP',
    'South Korea': 'KR',
    'Kuwait': 'KW',
    'Cayman Islands': 'KY',
    'Kazakhstan': 'KZ',
    'Laos': 'LA',
    'Lebanon': 'LB',
    'Saint Lucia': 'LC',
    'Liechtenstein': 'LI',
    'Sri Lanka': 'LK',
    'Liberia': 'LR',
    'Lesotho': 'LS',
    'Lithuania': 'LT',
    'Luxembourg': 'LU',
    'Latvia': 'LV',
    'Libya': 'LY',
    'Morocco': 'MA',
    'Madeira': 'PT',
    'Moldova': 'MD',
    'Montenegro': 'ME',
    'Madagascar': 'MG',
    'Marshall Islands': 'MH',
    'North Macedonia': 'MK',
    'Mali': 'ML',
    'Myanmar': 'MM',
    'Mongolia': 'MN',
    'Northern Marianas': 'US',
    'Martinique': 'FR',
    'Mauritania': 'MR',
    'Montserrat': 'MS',
    'Malta': 'MT',
    'Mauritius': 'MU',
    'Maldives': 'MV',
    'Malawi': 'MW',
    'Mexico': 'MX',
    'Malaysia': 'MY',
    'Mozambique': 'MZ',
    'Namibia': 'NA',
    'New Caledonia': 'NC',
    'Niger': 'NE',
    'Norfolk Island': 'AU',
    'Nigeria': 'NG',
    'Nicaragua': 'NI',
    'Netherlands': 'NL',
    'Norway': 'NO',
    'Nepal': 'NP',
    'Nauru': 'NR',
    'Niue': 'NZ',
    'New Zealand': 'NZ',
    'Oman': 'OM',
    'Panama': 'PA',
    'Peru': 'PE',
    'Prince Edward Islands': 'ZA',
    'French Polynesia': 'FR',
    'Papua New Guinea': 'PG',
    'Philippines': 'PH',
    'Pakistan': 'PK',
    'Poland': 'PL',
    'Pitcairn': 'PN',
    'Puerto Rico': 'PR',
    'Palestine': 'PS',
    'Portugal': 'PT',
    'Palau': 'PW',
    'Paraguay': 'PY',
    'Qatar': 'QA',
    'Réunion': 'FR',
    'Romania': 'RO',
    'Serbia': 'RS',
    'Russia': 'RU',
    'Rwanda': 'RW',
    'Saudi Arabia': 'SA',
    'Saba': 'SAB',
    'Solomon Islands': 'SB',
    'Seychelles': 'SC',
    'Sudan': 'SD',
    'Sweden': 'SE',
    'Singapore': 'SG',
    'Saint Helena': 'SH',
    'Slovenia': 'SI',
    'Slovakia': 'SK',
    'Sierra Leone': 'SL',
    'Senegal': 'SN',
    'Somalia': 'SO',
    'Suriname': 'SR',
    'South Sudan': 'SS',
    'São Tomé and Príncipe': 'ST',
    'Sint Eustatius': 'STE',
    'El Salvador': 'SV',
    'Sint Maarten': 'SX',
    'Syria': 'SY',
    'Eswatini': 'SZ',
    'Turks and Caicos Islands': 'TC',
    'Chad': 'TD',
    'French Southern and Antarctic Lands': 'TF',
    'Togo': 'TG',
    'Thailand': 'TH',
    'Tajikistan': 'TJ',
    'Tokelau': 'NZ',
    'East Timor': 'TL',
    'Turkmenistan': 'TM',
    'Tunisia': 'TN',
    'Tonga': 'TO',
    'Turkey': 'TR',
    'Trinidad and Tobago': 'TT',
    'Tuvalu': 'TV',
    'Taiwan': 'TW',
    'Tanzania': 'TZ',
    'Ukraine': 'UA',
    'Uganda': 'UG',
    'United States': 'US',
    'Uruguay': 'UY',
    'Uzbekistan': 'UZ',
    'Saint Vincent and the Grenadines': 'VC',
    'Venezuela': 'VE',
    'British Virgin Islands': 'VG',
    'United States Virgin Islands': 'VI',
    'Vietnam': 'VN',
    'Vanuatu': 'VU',
    'Wallis and Futuna': 'FR',
    'Samoa': 'WS',
    'Kosovo': 'XK',
    'Yemen': 'YE',
    'Mayotte': 'FR',
    'South Africa': 'ZA',
    'Zambia': 'ZM',
    'Zimbabwe': 'ZW',
  };

  static String? normalizeToIso(String mddName) {
    return mddToIsoMap[mddName];
  }

  static List<Polygon> parsePolygons(Map<String, dynamic> json, Set<String> knownCountries, Set<String> predictedCountries) {
    if (json['type'] != 'Topology') {
      return [];
    }

    final objects = json['objects'];
    if (objects == null || objects['countries_mdd'] == null) {
      return [];
    }

    final geometries = objects['countries_mdd']['geometries'] as List;
    final topoArcs = json['arcs'] as List;

    List<LatLng> decodeArc(int arcIndex) {
      final isReversed = arcIndex < 0;
      final actualIndex = isReversed ? ~arcIndex : arcIndex;
      final arc = topoArcs[actualIndex] as List;
      List<LatLng> points = [];
      for (var coord in arc) {
        final lon = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        points.add(LatLng(lat, lon));
      }
      return isReversed ? points.reversed.toList() : points;
    }

    List<Polygon> loadedPolygons = [];

    for (var feature in geometries) {
      final properties = feature['properties'] ?? {};
      final isoA2 = properties['ISO_A2'] as String?;
      if (isoA2 == null) continue;

      bool isKnown = knownCountries.contains(isoA2);
      bool isPredicted = predictedCountries.contains(isoA2);

      if (isKnown || isPredicted) {
        final type = feature['type'];
        final color = isKnown
            ? const Color(0xFF117554).withValues(alpha: 0.5) // Known green
            : const Color(0xFFFFEB00).withValues(alpha: 0.5); // Predicted yellow
        final borderColor = isKnown
            ? const Color(0xFF117554)
            : const Color(0xFFB5A600); // Darker border for predicted for accessibility

        if (type == 'Polygon') {
          final arcs = feature['arcs'] as List;
          if (arcs.isNotEmpty) {
            List<LatLng> ring = [];
            for (int arcIndex in arcs[0]) {
              ring.addAll(decodeArc(arcIndex));
            }
            if (ring.isNotEmpty) {
              loadedPolygons.add(_createPolygon(ring, color, borderColor));
            }
          }
        } else if (type == 'MultiPolygon') {
          final arcs = feature['arcs'] as List;
          for (var polyArcs in arcs) {
            if ((polyArcs as List).isNotEmpty) {
              List<LatLng> ring = [];
              for (int arcIndex in polyArcs[0]) {
                ring.addAll(decodeArc(arcIndex));
              }
              if (ring.isNotEmpty) {
                loadedPolygons.add(_createPolygon(ring, color, borderColor));
              }
            }
          }
        }
      }
    }

    return loadedPolygons;
  }

  static Polygon _createPolygon(List<LatLng> points, Color color, Color borderColor) {
    return Polygon(
      points: points,
      color: color,
      borderColor: borderColor,
      borderStrokeWidth: 1,
    );
  }
}

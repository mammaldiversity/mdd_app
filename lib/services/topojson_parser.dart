enum DistributionStatus { known, predicted }

class MapCoordinate {
  const MapCoordinate(this.longitude, this.latitude);

  final double longitude;
  final double latitude;

  List<double> toGeoJson() => [longitude, latitude];
}

class DistributionPolygon {
  const DistributionPolygon({required this.rings, required this.status});

  final List<List<MapCoordinate>> rings;
  final DistributionStatus status;
}

class DistributionBounds {
  const DistributionBounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  final double west;
  final double south;
  final double east;
  final double north;
}

class DistributionMapData {
  const DistributionMapData({required this.polygons, required this.bounds});

  final List<DistributionPolygon> polygons;
  final DistributionBounds? bounds;

  Map<String, dynamic> get featureCollection => {
    'type': 'FeatureCollection',
    'features': [
      for (var index = 0; index < polygons.length; index++)
        {
          'type': 'Feature',
          'id': index,
          'properties': {'distributionStatus': polygons[index].status.name},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              for (final ring in polygons[index].rings)
                [for (final point in ring) point.toGeoJson()],
            ],
          },
        },
    ],
  };
}

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

  static DistributionMapData parseDistribution(
    Map<String, dynamic> json,
    String countryDistribution,
  ) {
    final knownCountries = <String>{};
    final predictedCountries = <String>{};
    for (final value in countryDistribution.split(RegExp(r'[|,]'))) {
      final country = value.trim();
      if (country.isEmpty) continue;
      final isPredicted = country.endsWith('?');
      final rawName = isPredicted
          ? country.substring(0, country.length - 1).trim()
          : country;
      final isoCode = normalizeToIso(rawName);
      if (isoCode == null) continue;
      if (isPredicted) {
        predictedCountries.add(isoCode);
      } else {
        knownCountries.add(isoCode);
      }
    }
    predictedCountries.removeAll(knownCountries);

    if (json['type'] != 'Topology') {
      return const DistributionMapData(polygons: [], bounds: null);
    }

    final objects = json['objects'];
    if (objects is! Map || objects['countries_mdd'] is! Map) {
      return const DistributionMapData(polygons: [], bounds: null);
    }

    final topologyObject = objects['countries_mdd'] as Map;
    final geometries = topologyObject['geometries'];
    final topoArcs = json['arcs'];
    if (geometries is! List || topoArcs is! List) {
      return const DistributionMapData(polygons: [], bounds: null);
    }
    final transformValue = json['transform'];
    final transform = transformValue is Map
        ? Map<String, dynamic>.from(transformValue)
        : null;

    List<MapCoordinate> decodeArc(int arcIndex) {
      final isReversed = arcIndex < 0;
      final actualIndex = isReversed ? ~arcIndex : arcIndex;
      if (actualIndex < 0 || actualIndex >= topoArcs.length) return const [];
      final arc = topoArcs[actualIndex];
      if (arc is! List) return const [];
      final points = <MapCoordinate>[];
      var x = 0.0;
      var y = 0.0;
      for (var coord in arc) {
        if (coord is! List ||
            coord.length < 2 ||
            coord[0] is! num ||
            coord[1] is! num) {
          continue;
        }
        if (transform == null) {
          x = (coord[0] as num).toDouble();
          y = (coord[1] as num).toDouble();
        } else {
          x += (coord[0] as num).toDouble();
          y += (coord[1] as num).toDouble();
        }
        points.add(_applyTransform(x, y, transform));
      }
      return isReversed ? points.reversed.toList() : points;
    }

    List<MapCoordinate> decodeRing(Object? arcIndexes) {
      if (arcIndexes is! List) return const [];
      final ring = <MapCoordinate>[];
      for (final value in arcIndexes) {
        if (value is! int) continue;
        final arc = decodeArc(value);
        if (arc.isEmpty) continue;
        final startsAtPreviousEnd =
            ring.isNotEmpty && _samePoint(ring.last, arc.first);
        ring.addAll(startsAtPreviousEnd ? arc.skip(1) : arc);
      }
      if (ring.length >= 3 && !_samePoint(ring.first, ring.last)) {
        ring.add(ring.first);
      }
      return ring;
    }

    DistributionPolygon? decodePolygon(
      Object? polygonArcs,
      DistributionStatus status,
    ) {
      if (polygonArcs is! List) return null;
      final rings = polygonArcs
          .map(decodeRing)
          .where((ring) => ring.length >= 4)
          .toList(growable: false);
      if (rings.isEmpty) return null;
      return DistributionPolygon(rings: rings, status: status);
    }

    final loadedPolygons = <DistributionPolygon>[];

    for (var feature in geometries) {
      if (feature is! Map) continue;
      final properties = feature['properties'] as Map? ?? const {};
      final isoA2Value = properties['ISO_A2'];
      if (isoA2Value is! String) continue;
      final isoA2 = isoA2Value;

      final status = knownCountries.contains(isoA2)
          ? DistributionStatus.known
          : predictedCountries.contains(isoA2)
          ? DistributionStatus.predicted
          : null;
      if (status == null) continue;

      final arcs = feature['arcs'];
      if (feature['type'] == 'Polygon') {
        final polygon = decodePolygon(arcs, status);
        if (polygon != null) loadedPolygons.add(polygon);
      } else if (feature['type'] == 'MultiPolygon' && arcs is List) {
        for (final polygonArcs in arcs) {
          final polygon = decodePolygon(polygonArcs, status);
          if (polygon != null) loadedPolygons.add(polygon);
        }
      }
    }

    return DistributionMapData(
      polygons: loadedPolygons,
      bounds: _boundsFor(loadedPolygons),
    );
  }

  static MapCoordinate _applyTransform(
    double x,
    double y,
    Map<String, dynamic>? transform,
  ) {
    if (transform == null) return MapCoordinate(x, y);
    final scale = transform['scale'];
    final translate = transform['translate'];
    if (scale is! List ||
        scale.length < 2 ||
        scale[0] is! num ||
        scale[1] is! num ||
        translate is! List ||
        translate.length < 2 ||
        translate[0] is! num ||
        translate[1] is! num) {
      return MapCoordinate(x, y);
    }
    return MapCoordinate(
      x * (scale[0] as num).toDouble() + (translate[0] as num).toDouble(),
      y * (scale[1] as num).toDouble() + (translate[1] as num).toDouble(),
    );
  }

  static bool _samePoint(MapCoordinate first, MapCoordinate second) =>
      first.longitude == second.longitude && first.latitude == second.latitude;

  static DistributionBounds? _boundsFor(List<DistributionPolygon> polygons) {
    final points = polygons.expand((polygon) => polygon.rings.expand((e) => e));
    final iterator = points.iterator;
    if (!iterator.moveNext()) return null;
    var west = iterator.current.longitude;
    var east = west;
    var south = iterator.current.latitude;
    var north = south;
    while (iterator.moveNext()) {
      final point = iterator.current;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
    }
    return DistributionBounds(
      west: west,
      south: south,
      east: east,
      north: north,
    );
  }
}

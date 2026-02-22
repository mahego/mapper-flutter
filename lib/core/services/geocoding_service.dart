import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Resultado de búsqueda de dirección
class GeocodeSearchResult {
  final String address;
  final double lat;
  final double lng;
  final String ciudad;
  final String estado;

  const GeocodeSearchResult({
    required this.address,
    required this.lat,
    required this.lng,
    required this.ciudad,
    required this.estado,
  });
}

/// Resultado de reverse geocode con componentes para rellenar formularios
class ReverseGeocodeResult {
  final String address;
  final String displayName;
  final double lat;
  final double lng;
  final String ciudad;
  final String estado;
  final String? codigoPostal;
  final String? addressLine;

  const ReverseGeocodeResult({
    required this.address,
    required this.displayName,
    required this.lat,
    required this.lng,
    required this.ciudad,
    required this.estado,
    this.codigoPostal,
    this.addressLine,
  });

  /// Factory para crear fallback cuando geocoding falla
  factory ReverseGeocodeResult.fallback(double lat, double lng) {
    return ReverseGeocodeResult(
      address: 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
      displayName: 'Ubicación seleccionada',
      lat: lat,
      lng: lng,
      ciudad: 'Desconocida',
      estado: 'Desconocida',
    );
  }
}

/// Servicio para geocoding usando Mapbox API (similar a Angular)
class GeocodingServiceImpl {
  final Dio _dio;
  final Logger _logger;
  final String _mapboxToken;

  static const String _mapboxBaseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  GeocodingServiceImpl({
    required Dio dio,
    required String mapboxToken,
    Logger? logger,
  })  : _dio = dio,
        _mapboxToken = mapboxToken,
        _logger = logger ?? Logger();

  /// Valida que las coordenadas sean válidas
  bool _isValidCoord(double lat, double lng) {
    if (lat.isNaN || lng.isNaN) return false;
    if (lat == 0 && lng == 0) return false;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return false;
    return true;
  }

  /// Reverse geocode: convierte coordenadas a dirección legible
  Future<ReverseGeocodeResult> reverseGeocode(double lat, double lng) async {
    print('🔎 Reverse geocode: $lat, $lng');

    // Validar coordenadas
    if (!_isValidCoord(lat, lng)) {
      print('⚠️ Coordenadas inválidas');
      return ReverseGeocodeResult.fallback(lat, lng);
    }

    // Validar token
    if (_mapboxToken.isEmpty) {
      print('⚠️ Mapbox token no configurado');
      return ReverseGeocodeResult.fallback(lat, lng);
    }

    try {
      final url = '$_mapboxBaseUrl/$lng,$lat.json';
      print('📡 Llamando a Mapbox reverse: $url');
      print('🔑 Token: ${_mapboxToken.substring(0, 10)}...');

      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'access_token': _mapboxToken,
          'types': 'address,place,postcode,locality',
          'language': 'es',
        },
      );

      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ Error HTTP: ${response.statusCode}');
        print('📄 Response: ${response.data}');
        return ReverseGeocodeResult.fallback(lat, lng);
      }

      final data = response.data;
      if (data == null) {
        print('❌ Respuesta nula');
        return ReverseGeocodeResult.fallback(lat, lng);
      }

      print('📦 Datos recibidos: $data');

      final features = data['features'] as List?;
      if (features == null || features.isEmpty) {
        print('⚠️ No hay features en la respuesta');
        print('📋 Claves en respuesta: ${data.keys.toList()}');
        return ReverseGeocodeResult.fallback(lat, lng);
      }

      print('✅ Features encontrados: ${features.length}');
      final feature = features.first as Map<String, dynamic>;
      final result = _parseMapboxFeature(feature, lat, lng);
      print('✅ Dirección obtenida: ${result.displayName}');
      return result;
    } catch (e) {
      print('❌ Error en reverse geocode: $e');
      print('Type: ${e.runtimeType}');
      return ReverseGeocodeResult.fallback(lat, lng);
    }
  }

  /// Búsqueda de dirección (forward geocoding): dirección text → coordenadas
  Future<List<GeocodeSearchResult>> searchAddress(String query) async {
    print('🔍 Buscando dirección: "$query"');

    if (query.trim().isEmpty) {
      print('⚠️ Búsqueda vacía');
      return [];
    }

    // Validar token
    if (_mapboxToken.isEmpty) {
      print('⚠️ Mapbox token no configurado');
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent('$query, Mexico');
      final url = '$_mapboxBaseUrl/$encodedQuery.json';
      print('📡 Llamando a Mapbox: $url');

      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'access_token': _mapboxToken,
          'limit': '5',
          'country': 'mx',
          'language': 'es',
        },
      );

      if (response.statusCode != 200) {
        print('❌ Error: ${response.statusCode}');
        return [];
      }

      final data = response.data;
      if (data == null) {
        print('❌ Respuesta nula');
        return [];
      }

      final features = data['features'] as List?;
      if (features == null || features.isEmpty) {
        print('⚠️ No hay features en la respuesta');
        return [];
      }

      final results = <GeocodeSearchResult>[];
      for (final feature in features) {
        final featureMap = feature as Map<String, dynamic>;
        try {
          final result = _parseMapboxSearchFeature(featureMap);
          results.add(result);
          print('✅ Resultado: ${result.address}');
        } catch (e) {
          print('⚠️ Error parseando feature: $e');
        }
      }

      return results;
    } catch (e) {
      print('❌ Error en búsqueda de dirección: $e');
      return [];
    }
  }

  /// Parsea un feature de búsqueda de Mapbox
  GeocodeSearchResult _parseMapboxSearchFeature(Map<String, dynamic> feature) {
    String ciudad = 'Desconocida';
    String estado = 'Desconocida';

    // Extraer información del contexto
    final context = (feature['context'] as List?) ?? [];
    for (final ctx in context) {
      final ctxMap = ctx as Map<String, dynamic>;
      final id = ctxMap['id'] as String?;
      final text = ctxMap['text'] as String?;

      if (id == null || text == null) continue;

      if (id.startsWith('place.') || id.startsWith('locality.')) {
        ciudad = text;
      } else if (id.startsWith('region.')) {
        estado = _normalizeStateName(text);
      }
    }

    final placeName = feature['place_name'] as String? ?? '';
    final geoCoords = feature['geometry']?['coordinates'] as List?;

    final coords = geoCoords != null && geoCoords.length >= 2
        ? {
            'lng': geoCoords[0] as num,
            'lat': geoCoords[1] as num,
          }
        : null;

    return GeocodeSearchResult(
      address: placeName.isNotEmpty ? placeName : 'Ubicación',
      lat: coords?['lat']?.toDouble() ?? 0.0,
      lng: coords?['lng']?.toDouble() ?? 0.0,
      ciudad: ciudad,
      estado: estado,
    );
  }

  /// Parsea un feature de Mapbox para extraer información útil
  ReverseGeocodeResult _parseMapboxFeature(
    Map<String, dynamic> feature,
    double fallbackLat,
    double fallbackLng,
  ) {
    try {
      String ciudad = 'Desconocida';
      String estado = 'Desconocida';
      String? codigoPostal;

      // Extraer información del contexto
      final context = (feature['context'] as List?) ?? [];
      for (final ctx in context) {
        final ctxMap = ctx as Map<String, dynamic>;
        final id = ctxMap['id'] as String?;
        final text = ctxMap['text'] as String?;

        if (id == null || text == null) continue;

        if (id.startsWith('place.') || id.startsWith('locality.')) {
          ciudad = text;
        } else if (id.startsWith('region.')) {
          estado = _normalizeStateName(text);
        } else if (id.startsWith('postcode.')) {
          codigoPostal = text;
        }
      }

      // Alternativa: si no hay city en context, extraer del place_name
      if (ciudad == 'Desconocida') {
        final placeName = feature['place_name'] as String?;
        if (placeName != null && placeName.isNotEmpty) {
          final parts = placeName.split(',').map((p) => p.trim()).toList();
          if (parts.length >= 2) {
            ciudad = parts[parts.length - 2]; // Generalmente la ciudad está penúltima
          }
        }
      }

      final placeName = feature['place_name'] as String? ?? '';
      final geoCoords = feature['geometry']?['coordinates'] as List?;

      String? addressLine;
      if (placeName.isNotEmpty) {
        final parts = placeName.split(',');
        final firstPart = parts[0].trim();
        if (firstPart != ciudad && firstPart.isNotEmpty) {
          addressLine = firstPart;
        }
      }

      final coords = geoCoords != null && geoCoords.length >= 2
          ? {
              'lng': geoCoords[0] as num,
              'lat': geoCoords[1] as num,
            }
          : null;

      return ReverseGeocodeResult(
        address: placeName.isNotEmpty ? placeName : 'Ubicación seleccionada',
        displayName: placeName.isNotEmpty ? placeName : 'Ubicación seleccionada',
        lat: coords?['lat']?.toDouble() ?? fallbackLat,
        lng: coords?['lng']?.toDouble() ?? fallbackLng,
        ciudad: ciudad,
        estado: estado,
        codigoPostal: codigoPostal,
        addressLine: addressLine,
      );
    } catch (e) {
      print('❌ Error parseando feature Mapbox: $e');
      return ReverseGeocodeResult.fallback(fallbackLat, fallbackLng);
    }
  }

  /// Normaliza nombres de estados mexicanos
  String _normalizeStateName(String state) {
    const stateMap = {
      'Nuevo León': 'Nuevo León',
      'Jalisco': 'Jalisco',
      'Veracruz': 'Veracruz',
      'Mexico': 'Estado de México',
      'Ciudad de México': 'CDMX',
      'Guanajuato': 'Guanajuato',
      'Puebla': 'Puebla',
      'Baja California': 'Baja California',
      'Coahuila': 'Coahuila',
      'Chiapas': 'Chiapas',
    };

    return stateMap[state] ?? state;
  }
}

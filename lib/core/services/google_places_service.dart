import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Resultado de búsqueda de direcciones con Google Places
class GeoPlacesResult {
  final String address;
  final double lat;
  final double lng;
  final String? ciudad;
  final String? estado;
  final String? codigoPostal;

  GeoPlacesResult({
    required this.address,
    required this.lat,
    required this.lng,
    this.ciudad,
    this.estado,
    this.codigoPostal,
  });

  factory GeoPlacesResult.fallback(double lat, double lng) {
    return GeoPlacesResult(
      address: 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
      lat: lat,
      lng: lng,
      ciudad: null,
      estado: null,
      codigoPostal: null,
    );
  }

  @override
  String toString() => 'Address: $address, Lat: $lat, Lng: $lng, City: $ciudad, State: $estado';
}

/// Servicio de Google Places para geocoding
/// Usa Google Geocoding API (v1) para reverse geocoding confiable
class GooglePlacesService {
  final Dio _dio;
  final String _apiKey;
  final Logger _logger = Logger();

  static const String _geocodingApiUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  GooglePlacesService({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  /// Reverse geocode: convierte coordenadas a dirección legible con Google Geocoding API
  Future<GeoPlacesResult> reverseGeocode(double lat, double lng) async {
    _logger.i('🔎 Google Reverse geocode: $lat, $lng');

    // Validar coordenadas
    if (!_isValidCoord(lat, lng)) {
      _logger.w('⚠️ Coordenadas inválidas');
      return GeoPlacesResult.fallback(lat, lng);
    }

    // Validar API key
    if (_apiKey.isEmpty) {
      _logger.w('⚠️ Google API key no configurada');
      return GeoPlacesResult.fallback(lat, lng);
    }

    try {
      _logger.d('📡 Llamando a Google Geocoding API: $lat,$lng');

      final response = await _dio.get<Map<String, dynamic>>(
        _geocodingApiUrl,
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _apiKey,
          'language': 'es',
          'region': 'mx', // Priorizar resultados de México
        },
      );

      _logger.d('📊 Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        _logger.e('❌ Error HTTP: ${response.statusCode}');
        return GeoPlacesResult.fallback(lat, lng);
      }

      final data = response.data;
      if (data == null) {
        _logger.e('❌ Respuesta nula de Google');
        return GeoPlacesResult.fallback(lat, lng);
      }

      final status = data['status'] as String?;
      _logger.d('🔍 Google API Status: $status');

      // Google devuelve status al lugar de statusCode
      if (status != 'OK') {
        _logger.w('⚠️ Google API Error: $status');
        _logger.d('📋 Error message: ${data['error_message']}');
        return GeoPlacesResult.fallback(lat, lng);
      }

      final results = data['results'] as List?;
      if (results == null || results.isEmpty) {
        _logger.w('⚠️ Google no encontró resultados');
        return GeoPlacesResult.fallback(lat, lng);
      }

      _logger.d('✅ Google encontró ${results.length} resultados');

      // Usar el primer resultado (más preciso)
      final firstResult = results.first as Map<String, dynamic>;
      final result = _parseGoogleGeocodeResult(firstResult, lat, lng);

      _logger.i('✅ Dirección obtenida: ${result.address}');
      return result;
    } on DioException catch (e) {
      _logger.e('❌ Error DIO en reverse geocode: ${e.message}');
      _logger.e('Response: ${e.response?.data}');
      return GeoPlacesResult.fallback(lat, lng);
    } catch (e) {
      _logger.e('❌ Error en reverse geocode: $e');
      return GeoPlacesResult.fallback(lat, lng);
    }
  }

  /// Forward geocode: busca dirección y devuelve coordenadas
  Future<GeoPlacesResult> searchAddress(String query) async {
    _logger.i('🔍 Google Search address: $query');

    if (query.trim().isEmpty) {
      _logger.w('⚠️ Query de búsqueda vacío');
      return GeoPlacesResult.fallback(0, 0);
    }

    if (_apiKey.isEmpty) {
      _logger.w('⚠️ Google API key no configurada');
      return GeoPlacesResult.fallback(0, 0);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _geocodingApiUrl,
        queryParameters: {
          'address': query,
          'key': _apiKey,
          'language': 'es',
          'region': 'mx',
          'components': 'country:mx', // Limitar a México
        },
      );

      if (response.statusCode != 200) {
        _logger.e('❌ Error HTTP: ${response.statusCode}');
        return GeoPlacesResult.fallback(0, 0);
      }

      final data = response.data;
      if (data == null) {
        return GeoPlacesResult.fallback(0, 0);
      }

      final status = data['status'] as String?;
      if (status != 'OK') {
        _logger.w('⚠️ Google API Error: $status');
        return GeoPlacesResult.fallback(0, 0);
      }

      final results = data['results'] as List?;
      if (results == null || results.isEmpty) {
        _logger.w('⚠️ No se encontraron resultados para: $query');
        return GeoPlacesResult.fallback(0, 0);
      }

      final firstResult = results.first as Map<String, dynamic>;
      final result = _parseGoogleGeocodeResult(firstResult, 0, 0);

      _logger.i('✅ Dirección encontrada: ${result.address}');
      return result;
    } on DioException catch (e) {
      _logger.e('❌ Error DIO en búsqueda: ${e.message}');
      return GeoPlacesResult.fallback(0, 0);
    } catch (e) {
      _logger.e('❌ Error en búsqueda: $e');
      return GeoPlacesResult.fallback(0, 0);
    }
  }

  /// Parsea un resultado de Google Geocoding API
  GeoPlacesResult _parseGoogleGeocodeResult(
    Map<String, dynamic> result,
    double fallbackLat,
    double fallbackLng,
  ) {
    try {
      // Dirección formateada
      final address = result['formatted_address'] as String? ?? 'Ubicación desconocida';

      // Coordenadas
      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble() ?? fallbackLat;
      final lng = (location?['lng'] as num?)?.toDouble() ?? fallbackLng;

      // Componentes de dirección
      String? ciudad;
      String? estado;
      String? codigoPostal;
      String? addressLine;

      final addressComponents = result['address_components'] as List?;
      if (addressComponents != null) {
        for (final component in addressComponents) {
          final comp = component as Map<String, dynamic>;
          final types = comp['types'] as List?;
          final longName = comp['long_name'] as String?;
          final shortName = comp['short_name'] as String?;

          if (types != null && longName != null) {
            if (types.contains('locality')) {
              ciudad = longName;
            } else if (types.contains('administrative_area_level_1')) {
              estado = shortName ?? longName;
            } else if (types.contains('postal_code')) {
              codigoPostal = longName;
            } else if (types.contains('route') && addressLine == null) {
              // Primera línea de dirección (calle)
              addressLine = longName;
            }
          }
        }
      }

      return GeoPlacesResult(
        address: address,
        lat: lat,
        lng: lng,
        ciudad: ciudad ?? 'México',
        estado: estado ?? 'México',
        codigoPostal: codigoPostal,
      );
    } catch (e) {
      _logger.e('❌ Error parseando resultado: $e');
      return GeoPlacesResult.fallback(fallbackLat, fallbackLng);
    }
  }

  /// Valida coordenadas
  bool _isValidCoord(double lat, double lng) {
    if (lat == 0 && lng == 0) return false;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return false;
    return true;
  }
}

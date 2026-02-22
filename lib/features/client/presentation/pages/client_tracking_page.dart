import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/client_bottom_nav.dart';
import '../../../../core/widgets/tropical_map_widget.dart';
import '../../../../core/services/geolocation_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/entities/location_coordinates.dart';
import 'dart:async';

class ClientTrackingPage extends StatefulWidget {
  const ClientTrackingPage({super.key});

  @override
  State<ClientTrackingPage> createState() => _ClientTrackingPageState();
}

class _ClientTrackingPageState extends State<ClientTrackingPage> {
  final _geolocationService = GeolocationService();
  final _socketService = SocketService();
  final _mapController = MapController();
  
  LocationCoordinates? _myLocation;
  LocationCoordinates? _providerLocation;
  StreamSubscription<dynamic>? _locationSubscription;
  bool _isLoading = true;
  double? _distance;
  double? _providerBearing;
  final int _mockRequestId = 1; // TODO: Replace with actual request ID

  @override
  void initState() {
    super.initState();
    _initializeTracking();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _socketService.removeTrackingListeners();
    _socketService.leaveTrackingRoom(_mockRequestId);
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    // Get initial location
    final position = await _geolocationService.getCurrentPosition();
    
    if (position != null) {
      setState(() {
        _myLocation = LocationCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
        
        // Simulate provider location (will be replaced by real socket data)
        _providerLocation = LocationCoordinates(
          latitude: position.latitude + 0.0045,
          longitude: position.longitude + 0.0045,
          timestamp: DateTime.now(),
        );
        
        _calculateDistance();
        _isLoading = false;
      });

      // Center map on user location
      _mapController.move(
        LatLng(_myLocation!.latitude, _myLocation!.longitude),
        15.0,
      );

      // Start listening to position updates
      final positionStream = _geolocationService.getPositionStream(
        distanceFilter: 10, // Update every 10 meters
      );
      
      if (positionStream != null) {
        _locationSubscription = positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _myLocation = LocationCoordinates(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: position.accuracy,
                timestamp: position.timestamp,
              );
              _calculateDistance();
            });
          }
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupSocketListeners() {
    // Connect to socket if not connected
    if (!_socketService.isConnected) {
      _socketService.connect();
    }

    // Join tracking room
    _socketService.joinTrackingRoom(_mockRequestId);

    // Listen to tracking updates (provider location)
    _socketService.onLocationUpdate((data) {
      if (mounted) {
        setState(() {
          _providerLocation = LocationCoordinates(
            latitude: data['latitude'] ?? 0.0,
            longitude: data['longitude'] ?? 0.0,
            timestamp: DateTime.tryParse(data['timestamp'] ?? ''),
          );
          _providerBearing = data['bearing']?.toDouble();
          _calculateDistance();
        });
      }
    });
  }

  void _calculateDistance() {
    if (_myLocation != null && _providerLocation != null) {
      _distance = _geolocationService.calculateDistance(
        startLatitude: _myLocation!.latitude,
        startLongitude: _myLocation!.longitude,
        endLatitude: _providerLocation!.latitude,
        endLongitude: _providerLocation!.longitude,
      );
    }
  }

  void _centerOnMyLocation() {
    if (_myLocation != null) {
      _mapController.move(
        LatLng(_myLocation!.latitude, _myLocation!.longitude),
        15.0,
      );
    }
  }

  void _fitBothLocations() {
    if (_myLocation != null && _providerLocation != null) {
      final bounds = LatLngBounds(
        LatLng(_myLocation!.latitude, _myLocation!.longitude),
        LatLng(_providerLocation!.latitude, _providerLocation!.longitude),
      );
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      appBar: AppBar(
        title: const Text('Tracking en Vivo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Center on my location
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnMyLocation,
            tooltip: 'Mi ubicación',
          ),
          // Fit both locations
          if (_providerLocation != null)
            IconButton(
              icon: const Icon(Icons.fit_screen),
              onPressed: _fitBothLocations,
              tooltip: 'Ver todo',
            ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeTracking,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 2),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
              ),
            )
          : _myLocation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudo obtener tu ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _geolocationService.openAppSettings();
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Abrir Configuración'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06b6d4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Map
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TropicalMapWidget(
                          center: LatLng(
                            _myLocation!.latitude,
                            _myLocation!.longitude,
                          ),
                          zoom: 15,
                          controller: _mapController,
                          markers: [
                            // My location marker
                            MapMarkerBuilder.userLocationMarker(
                              position: LatLng(
                                _myLocation!.latitude,
                                _myLocation!.longitude,
                              ),
                              label: 'Tú',
                            ),
                            // Provider location marker
                            if (_providerLocation != null)
                              MapMarkerBuilder.providerLocationMarker(
                                position: LatLng(
                                  _providerLocation!.latitude,
                                  _providerLocation!.longitude,
                                ),
                                label: 'Prestador',
                                bearing: _providerBearing,
                              ),
                          ],
                          polylines: _myLocation != null && _providerLocation != null
                              ? [
                                  MapMarkerBuilder.routePolyline(
                                    points: [
                                      LatLng(
                                        _myLocation!.latitude,
                                        _myLocation!.longitude,
                                      ),
                                      LatLng(
                                        _providerLocation!.latitude,
                                        _providerLocation!.longitude,
                                      ),
                                    ],
                                  ),
                                ]
                              : null,
                          circles: _myLocation?.accuracy != null
                              ? [
                                  MapMarkerBuilder.accuracyCircle(
                                    center: LatLng(
                                      _myLocation!.latitude,
                                      _myLocation!.longitude,
                                    ),
                                    radiusInMeters: _myLocation!.accuracy!,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),

                    // Info panels
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Distance indicator
                            if (_distance != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF10b981).withOpacity(0.2),
                                      const Color(0xFF059669).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF10b981).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10b981).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.near_me,
                                        color: Color(0xFF10b981),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Distancia',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _distance! < 1000
                                                ? '${_distance!.toStringAsFixed(0)}m'
                                                : '${(_distance! / 1000).toStringAsFixed(2)}km',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Socket connection indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _socketService.isConnected
                                            ? const Color(0xFF10b981)
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _socketService.isConnected
                                                ? Icons.wifi
                                                : Icons.wifi_off,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _socketService.isConnected ? 'En vivo' : 'Offline',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Info banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06b6d4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF06b6d4).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF06b6d4),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'El tracking se actualiza en tiempo real vía WebSocket',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

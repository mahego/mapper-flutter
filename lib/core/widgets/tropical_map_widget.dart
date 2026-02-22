import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TropicalMapWidget extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final List<CircleMarker>? circles;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final MapController? controller;
  final double? minZoom;
  final double? maxZoom;
  final bool showCurrentLocation;

  const TropicalMapWidget({
    super.key,
    required this.center,
    this.zoom = 15.0,
    this.markers,
    this.polylines,
    this.circles,
    this.onTap,
    this.onLongPress,
    this.controller,
    this.minZoom = 3.0,
    this.maxZoom = 18.0,
    this.showCurrentLocation = false,
  });

  @override
  State<TropicalMapWidget> createState() => _TropicalMapWidgetState();
}

class _TropicalMapWidgetState extends State<TropicalMapWidget> {
  late final MapController _mapController;

  // Mapbox access token
  static const String _mapboxAccessToken = 
      'pk.eyJ1IjoibWFoZWdvdHMiLCJhIjoiY21rdml0ejNrMDZuMDNlb3d1YXE1eTJiciJ9.Q9oV0srILSJaKR2qXPuDXQ';

  @override
  void initState() {
    super.initState();
    _mapController = widget.controller ?? MapController();
  }

  String get _mapboxStyleUrl {
    // Dark style for tropical theme
    return 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?access_token=$_mapboxAccessToken';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.center,
          initialZoom: widget.zoom,
          minZoom: widget.minZoom,
          maxZoom: widget.maxZoom,
          onTap: (tapPosition, point) {
            if (widget.onTap != null) {
              widget.onTap!(point);
            }
          },
          onLongPress: (tapPosition, point) {
            if (widget.onLongPress != null) {
              widget.onLongPress!(point);
            }
          },
        ),
        children: [
          // Mapbox tile layer
          TileLayer(
            urlTemplate: _mapboxStyleUrl,
            userAgentPackageName: 'com.mapper.app',
            maxZoom: widget.maxZoom ?? 18,
            minZoom: widget.minZoom ?? 3,
          ),

          // Polylines (routes)
          if (widget.polylines != null && widget.polylines!.isNotEmpty)
            PolylineLayer(
              polylines: widget.polylines!,
            ),

          // Circles
          if (widget.circles != null && widget.circles!.isNotEmpty)
            CircleLayer(
              circles: widget.circles!,
            ),

          // Markers
          if (widget.markers != null && widget.markers!.isNotEmpty)
            MarkerLayer(
              markers: widget.markers!,
            ),

          // Attribution
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'Mapbox',
                onTap: () {},
              ),
              TextSourceAttribution(
                'OpenStreetMap',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper class to create common marker types
class MapMarkerBuilder {
  /// Create a marker for user location (blue)
  static Marker userLocationMarker({
    required LatLng position,
    String? label,
  }) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF06b6d4),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06b6d4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Create a marker for provider location (green)
  static Marker providerLocationMarker({
    required LatLng position,
    String? label,
    double? bearing, // Rotation in degrees
  }) {
    return Marker(
      point: position,
      width: 80,
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Transform.rotate(
            angle: (bearing ?? 0) * (3.14159 / 180), // Convert to radians
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF10b981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Create a marker for destination (red)
  static Marker destinationMarker({
    required LatLng position,
    String? label,
  }) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFef4444),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFef4444),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Create a route polyline
  static Polyline routePolyline({
    required List<LatLng> points,
    Color color = const Color(0xFF06b6d4),
    double strokeWidth = 4.0,
  }) {
    return Polyline(
      points: points,
      color: color,
      strokeWidth: strokeWidth,
      borderColor: Colors.white,
      borderStrokeWidth: 1.5,
    );
  }

  /// Create an accuracy circle
  static CircleMarker accuracyCircle({
    required LatLng center,
    required double radiusInMeters,
    Color color = const Color(0xFF06b6d4),
  }) {
    return CircleMarker(
      point: center,
      radius: radiusInMeters,
      useRadiusInMeter: true,
      color: color.withOpacity(0.2),
      borderColor: color.withOpacity(0.5),
      borderStrokeWidth: 2,
    );
  }
}

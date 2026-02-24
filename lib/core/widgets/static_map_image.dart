import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Muestra un mapa estático obtenido del backend (proxy Mapbox).
/// La clave de Mapbox nunca se expone en el cliente.
class StaticMapImage extends StatefulWidget {
  final double lat;
  final double lng;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const StaticMapImage({
    super.key,
    required this.lat,
    required this.lng,
    this.width = 400,
    this.height = 200,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<StaticMapImage> createState() => _StaticMapImageState();
}

class _StaticMapImageState extends State<StaticMapImage> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchStaticMap();
  }

  @override
  void didUpdateWidget(StaticMapImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      _imageFuture = _fetchStaticMap();
    }
  }

  Future<Uint8List?> _fetchStaticMap() async {
    try {
      final w = widget.width.toInt().clamp(100, 1280);
      final h = widget.height.toInt().clamp(100, 1280);
      final response = await ApiClient().client.get<Uint8List>(
        '/static-map',
        queryParameters: {
          'lat': widget.lat,
          'lng': widget.lng,
          'w': w,
          'h': h,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
              ),
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, color: Colors.white38, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa no disponible',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }
        Widget image = Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
        if (widget.borderRadius != null) {
          image = ClipRRect(
            borderRadius: widget.borderRadius!,
            child: image,
          );
        }
        return image;
      },
    );
  }
}

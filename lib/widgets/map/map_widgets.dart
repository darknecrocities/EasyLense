import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Base class for mapping to allow easy switching between OSM and Google Maps.
abstract class AppMapWidget extends StatelessWidget {
  final LatLng? center;
  final List<LatLng> markers;
  final List<LatLng> polylinePoints; // New
  final Function(LatLng)? onMarkerTap;

  const AppMapWidget({
    super.key,
    this.center,
    this.markers = const [],
    this.polylinePoints = const [],
    this.onMarkerTap,
  });
}

/// OpenStreetMap implementation using flutter_map.
class OSMMapWidget extends AppMapWidget {
  const OSMMapWidget({
    super.key,
    super.center,
    super.markers,
    super.polylinePoints,
    super.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center ?? const LatLng(15.1450, 120.5944),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.company.easylense',
        ),
        if (polylinePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                color: const Color(0xFF08209A),
                strokeWidth: 6,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            // Target Markers
            ...markers.map((point) => Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                )),
            // Current Position Marker (Plane Icon)
            if (center != null)
              Marker(
                point: center!,
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/icons/navigation-icons/plane-icon.png',
                  // Ensure it points the right way or just use it as is
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Stub for future Google Maps implementation.
class GoogleMapWidget extends AppMapWidget {
  const GoogleMapWidget({
    super.key,
    super.center,
    super.markers,
    super.polylinePoints = const [],
    super.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Google Maps Placeholder'));
  }
}

/// Factory widget to decide which map to show.
class SmartMapWidget extends StatelessWidget {
  final bool useGoogleMaps;
  final LatLng? center;
  final List<LatLng> markers;
  final List<LatLng> polylinePoints;

  const SmartMapWidget({
    super.key,
    this.useGoogleMaps = false,
    this.center,
    this.markers = const [],
    this.polylinePoints = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (useGoogleMaps) {
      return GoogleMapWidget(
        center: center,
        markers: markers,
        polylinePoints: polylinePoints,
      );
    }
    return OSMMapWidget(
      center: center,
      markers: markers,
      polylinePoints: polylinePoints,
    );
  }
}

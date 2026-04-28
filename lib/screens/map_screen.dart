import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ngo_service.dart';

class MapScreen extends StatefulWidget {
  final Position initialPosition;
  const MapScreen({super.key, required this.initialPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final _ngoService = NGOService();

  @override
  void initState() {
    super.initState();
    _circles.add(
      Circle(
        circleId: const CircleId('search_radius'),
        center: LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude),
        radius: 10000, // 10km in meters
        fillColor: Colors.green.withValues(alpha: 0.1),
        strokeColor: Colors.green.withValues(alpha: 0.3),
        strokeWidth: 1,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _listenToNearbyNGOs();
  }

  void _listenToNearbyNGOs() {
    _ngoService.getNearbyNGOs(
      centerLat: widget.initialPosition.latitude,
      centerLng: widget.initialPosition.longitude,
      radiusInKm: 15.0, // Increased radius for testing
    ).listen((docs) {
      if (!mounted) return;
      setState(() {
        _markers.clear();
        for (var doc in docs) {
          final data = doc.data()!;
          final Map<String, dynamic> locationData = data['location'];
          final GeoPoint geoPoint = locationData['geopoint'];

          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geoPoint.latitude, geoPoint.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title: data['name'] ?? 'NGO',
                snippet: data['address'] ?? '',
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude),
          zoom: 12,
        ),
        markers: _markers,
        circles: _circles,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class NGOService {
  final _collection = FirebaseFirestore.instance.collection('ngos');

  /// Saves a new NGO to Firestore with GeoHash for proximity searches
  Future<void> registerNGO({
    required String name,
    required String taxId,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final GeoFirePoint point = GeoFirePoint(GeoPoint(lat, lng));

    await _collection.add({
      'name': name,
      'taxId': taxId,
      'address': address,
      'location': point.data, // Stores geohash and geopoint
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams NGOs within a specific radius (in KM) from a center point
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getNearbyNGOs({
    required double centerLat,
    required double centerLng,
    double radiusInKm = 5.0,
  }) {
    final center = GeoFirePoint(GeoPoint(centerLat, centerLng));

    return GeoCollectionReference(_collection).subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: 'location',
      geopointFrom: (data) => (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      strictMode: true,
    );
  }

  /// Populates sample NGOs near the user's location
  Future<void> seedData(double lat, double lng) async {
    final samples = [
      {'name': 'Green Relief Foundation', 'address': '2 km from you', 'offsetLat': 0.01, 'offsetLng': 0.01},
      {'name': 'Community Food Bank', 'address': '1.5 km from you', 'offsetLat': -0.005, 'offsetLng': 0.012},
      {'name': 'Hope Kitchen', 'address': '3.2 km from you', 'offsetLat': 0.015, 'offsetLng': -0.01},
    ];

    for (var ngo in samples) {
      await registerNGO(
        name: ngo['name'] as String,
        taxId: 'TEST-TAX-${DateTime.now().millisecond}',
        address: ngo['address'] as String,
        lat: lat + (ngo['offsetLat'] as double),
        lng: lng + (ngo['offsetLng'] as double),
      );
    }
  }
}

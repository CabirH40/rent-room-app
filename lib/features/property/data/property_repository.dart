import '../../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyRepository {
  final _firestore = FirestoreService.instance;

  Future<void> addProperty({
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerNight,
    required String ownerId,
  }) async {
    await _firestore.collection('properties').add({
      'title': title,
      'description': description,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'pricePerNight': pricePerNight,
      'ownerId': ownerId,
      'images': [],
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

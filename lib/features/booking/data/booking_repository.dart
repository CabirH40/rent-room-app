import '../../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  final _firestore = FirestoreService.instance;

  Future<void> addBooking({
    required String propertyId,
    required String userId,
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _firestore.collection('bookings').add({
      'propertyId': propertyId,
      'userId': userId,
      'ownerId': ownerId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

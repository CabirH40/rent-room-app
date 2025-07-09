import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class BookingRepository {
  final pb = authRepo.pbInstance;

  Future<void> addBooking({
    required String propertyId,
    required String userId,
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final body = {
      'propertyId': propertyId,
      'userId': userId,
      'ownerId': ownerId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    await pb.collection('bookings').create(body: body);
  }
}

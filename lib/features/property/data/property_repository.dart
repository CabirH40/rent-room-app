import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class PropertyRepository {
  final pb = authRepo.pbInstance;

  Future<void> addProperty({
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerNight,
    required String ownerId,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'pricePerNight': pricePerNight,
      'ownerId': ownerId,
      'images': [], // مبدئيًا فارغ، يمكنك تعديلها لاحقًا
      'isAvailable': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await pb.collection('properties').create(body: body);
  }
}

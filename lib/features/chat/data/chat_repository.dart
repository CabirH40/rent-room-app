import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class ChatRepository {
  final pb = authRepo.pbInstance;

  Future<void> createChat({
    required String propertyId,
    required String senderId,
    required String message,
  }) async {
    final body = {
      'propertyId': propertyId,
      'messages': [
        {
          'senderId': senderId,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ],
    };

    await pb.collection('chats').create(body: body);
  }
}

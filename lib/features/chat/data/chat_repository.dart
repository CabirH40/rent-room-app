import '../../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _firestore = FirestoreService.instance;

  Future<void> createChat({
    required String chatId,
    required String propertyId,
    required String senderId,
    required String message,
  }) async {
    await _firestore.collection('chats').doc(chatId).set({
      'propertyId': propertyId,
      'messages': [
        {
          'senderId': senderId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        },
      ],
    });
  }
}

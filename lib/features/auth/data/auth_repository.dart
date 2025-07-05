import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';

class AuthRepository {
  final _firestore = FirestoreService.instance;

  Future<void> addAdmin({
    required String id,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('admins').doc(id).set({
      'name': name,
      'email': email,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addUser({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'favoriteProperties': [],
    });
  }

  Future<void> addOwner({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) async {
    await _firestore.collection('owners').doc(id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'owner',
      'createdAt': FieldValue.serverTimestamp(),
      'propertiesCount': 0,
    });
  }
}

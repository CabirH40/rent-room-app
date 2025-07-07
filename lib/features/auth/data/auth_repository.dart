import 'package:pocketbase/pocketbase.dart';
import '../../../core/services/pb_service.dart';

class AuthRepository {
  PocketBase get pbInstance => pb;

  Future<RecordModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final body = {
      'username': email,
      'email': email,
      'emailVisibility': true,
      'password': password,
      'passwordConfirm': password,
      'name': name,
      'phone': phone,
      'role': role,
      'favoriteProperties': [],
    };
    final record = await pb.collection('users').create(body: body);
    return record;
  }

  Future<RecordAuth?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await pb.collection('users').authWithPassword(email, password);
    return result;
  }

  Future<void> signOut() async {
    pb.authStore.clear();
  }

  RecordModel? get currentUser => pb.authStore.model;

  Future<RecordModel?> getUserById(String id) async {
    final user = await pb.collection('users').getOne(id);
    return user;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await pb.collection('users').update(id, body: data);
  }
}

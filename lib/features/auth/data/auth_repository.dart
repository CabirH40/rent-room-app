import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_room/core/services/firestore_service.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirestoreService.instance;

  // إنشاء حساب جديد مع تخزين بيانات المستخدم ورول
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,   // أضفنا هذا الباراميتر
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;

    if (user != null) {
      await addUser(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,  // نمرر الرول هنا
      );
    }

    return user;
  }

  // تسجيل دخول
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return cred.user;
  }

  // تسجيل خروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // إضافة مستخدم إلى Firestore (تُستخدم بعد التسجيل)
  Future<void> addUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,  // أضفنا role
  }) async {
    await _firestore.collection('users').doc(id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,  // تخزين الرول المختار
      'createdAt': FieldValue.serverTimestamp(),
      'favoriteProperties': [],
    });
  }

  // إضافة أدمن (عند الحاجة)
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

  // إضافة مالك (عند الحاجة)
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

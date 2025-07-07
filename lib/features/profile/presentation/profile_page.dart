import 'package:flutter/material.dart';
import '../../auth/data/auth_repository.dart';
import 'package:pocketbase/pocketbase.dart';

final authRepo = AuthRepository();

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<RecordModel?> fetchUser() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    // جلب بيانات المستخدم الحقيقية من السيرفر لضمان الحصول على كل الحقول
    return await authRepo.getUserById(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: FutureBuilder<RecordModel?>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('الرجاء تسجيل الدخول لرؤية الملف الشخصي'));
          }
          final data = user.data;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الاسم: ${data['name'] ?? 'غير متوفر'}'),
                const SizedBox(height: 8),
                Text('الإيميل: ${data['email'] ?? 'غير متوفر'}'),
                const SizedBox(height: 8),
                Text('رقم الهاتف: ${data['phone'] ?? 'غير متوفر'}'),
                const SizedBox(height: 8),
                Text('الدور: ${data['role'] ?? 'غير محدد'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await authRepo.signOut();
                    Navigator.pop(context);
                  },
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

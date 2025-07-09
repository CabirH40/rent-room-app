import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<RecordModel?> fetchUser() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    return await authRepo.getUserById(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('ملفي في BaytnBeyond'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<RecordModel?>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text('يرجى تسجيل الدخول لرؤية ملفك الشخصي', style: TextStyle(fontSize: 16)),
            );
          }
          final data = user.data;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 20),
                    Text('👤 الاسم: ${data['name'] ?? 'غير متوفر'}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('📧 البريد الإلكتروني: ${data['email'] ?? 'غير متوفر'}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('📱 رقم الهاتف: ${data['phone'] ?? 'غير متوفر'}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('🎯 الدور: ${data['role'] ?? 'غير محدد'}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          await authRepo.signOut();
                          Navigator.pop(context);
                        },
                        child: const Text('تسجيل الخروج', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
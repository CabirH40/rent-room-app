import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: user == null
          ? const Center(child: Text('الرجاء تسجيل الدخول لرؤية الملف الشخصي'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ${user.displayName ?? 'غير متوفر'}'),
            const SizedBox(height: 8),
            Text('الإيميل: ${user.email}'),
            const SizedBox(height: 8),
            Text('رقم الهاتف: ${user.phoneNumber ?? 'غير متوفر'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

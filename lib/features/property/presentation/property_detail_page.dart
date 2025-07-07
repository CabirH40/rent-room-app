import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/pages/auth_page.dart';

final authRepo = AuthRepository();

class PropertyDetailPage extends StatelessWidget {
  final String propertyId;
  const PropertyDetailPage({super.key, required this.propertyId});

  // جلب دور المستخدم الحالي
  Future<String?> getUserRole() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    final record = await authRepo.pbInstance.collection('users').getOne(user.id);
    return record.data['role'] as String?;
  }

  // جلب بيانات العقار من PocketBase
  Future<RecordModel?> getProperty() async {
    final prop = await authRepo.pbInstance.collection('properties').getOne(propertyId);
    return prop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العقار')),
      body: FutureBuilder<RecordModel?>(
        future: getProperty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('العقار غير موجود'));
          }
          final data = snapshot.data!.data;
          final images = (data['images'] as List?)?.cast<String>() ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // صور العقار
              if (images.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, idx) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        'http://152.53.84.199:8090/api/files/${snapshot.data!.collectionId}/${snapshot.data!.id}/${images[idx]}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.home, size: 80, color: Colors.grey)),
                ),
              const SizedBox(height: 14),

              Text(
                data['title'] ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text(
                data['address'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              Text(
                'السعر لليلة: ${data['pricePerNight']?.toString() ?? ''} ل.س',
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
              const SizedBox(height: 14),

              Text(
                data['description'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 18),

              // زر الحجز: يظهر فقط إذا المستخدم tenant أو غير مسجل دخول
              FutureBuilder<String?>(
                future: getUserRole(),
                builder: (context, roleSnap) {
                  final user = authRepo.currentUser;
                  final isTenant = roleSnap.data == 'tenant';

                  if (user == null) {
                    return ElevatedButton(
                      child: const Text('احجز الآن'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                        );
                      },
                    );
                  } else if (isTenant) {
                    return ElevatedButton(
                      child: const Text('احجز الآن'),
                      onPressed: () {
                        // استدعاء صفحة الحجز هنا لاحقًا
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(propertyId: propertyId)));
                      },
                    );
                  } else {
                    return const SizedBox(); // لا تظهر زر الحجز
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../profile/presentation/profile_page.dart';
import '../../property/presentation/add_property_page.dart';
import '../../property/presentation/property_detail_page.dart';
import '../../booking/presentation/owner_bookings_page.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // جلب دور المستخدم الحالي
  Future<String?> getUserRole() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    final record = await authRepo.pbInstance.collection('users').getOne(user.id);
    return record.data['role'];
  }

  // جلب جميع العقارات من PocketBase
  Future<List<RecordModel>> getProperties() async {
    final result = await authRepo.pbInstance.collection('properties').getFullList(
      sort: '-created',
      expand: 'ownerId',
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, roleSnapshot) {
        final userRole = roleSnapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('العقارات'),
            actions: [
              if (userRole == 'owner')
                IconButton(
                  icon: const Icon(Icons.book_online_rounded),
                  tooltip: 'حجوزاتي',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerBookingsPage(),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              // قائمة العقارات
              FutureBuilder<List<RecordModel>>(
                future: getProperties(),
                builder: (context, propSnapshot) {
                  if (propSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (propSnapshot.hasError) {
                    return const Center(child: Text('حدث خطأ أثناء جلب العقارات'));
                  }
                  final properties = propSnapshot.data ?? [];
                  if (properties.isEmpty) {
                    return const Center(child: Text('لا يوجد عقارات متاحة حالياً'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final prop = properties[index];
                      final data = prop.data;

                      final images = prop.getListValue('images');
                      final title = data['title'] ?? 'بدون عنوان';
                      final address = data['address'] ?? '';
                      final price = data['pricePerNight']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: images.isNotEmpty
                              ? Image.network(
                            'http://152.53.84.199:8090/api/files/${prop.collectionId}/${prop.id}/${images[0]}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.home),
                          ),
                          title: Text(title),
                          subtitle: Text('$address\n$price ليرة/ليلة'),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyDetailPage(propertyId: prop.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              // أزرار البروفايل والإضافة
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userRole == 'owner')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FloatingActionButton(
                          heroTag: 'add_property',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddPropertyPage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                    FloatingActionButton(
                      heroTag: 'profile_btn',
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                      child: const Icon(Icons.person),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

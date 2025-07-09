import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../profile/presentation/profile_page.dart';
import '../../auth/presentation/pages/auth_page.dart';
import '../../property/presentation/add_property_page.dart';
import '../../property/presentation/property_detail_page.dart';
import '../../booking/presentation/owner_bookings_page.dart';
import '../../auth/data/auth_repository.dart';

final authRepo = AuthRepository();

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> getUserRole() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    final record = await authRepo.pbInstance.collection('users').getOne(user.id);
    return record.data['role'];
  }

  Future<List<RecordModel>> getProperties({String? query}) async {
    final filter = query != null && query.isNotEmpty
        ? 'address ~ "$query"' // يمكنك تغييره إلى 'title ~ "$query"' حسب الحاجة
        : null;

    final result = await authRepo.pbInstance.collection('properties').getFullList(
      sort: '-created',
      expand: 'ownerId',
      filter: filter,
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
            title: const Text('البحث عن عقار'),
            centerTitle: true,
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مدينة، مكان، الخ',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text('العقارات الموصى بها',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<RecordModel>>(
                    future: getProperties(query: _searchController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('حدث خطأ أثناء جلب البيانات'));
                      }
                      final properties = snapshot.data ?? [];
                      if (properties.isEmpty) {
                        return const Center(child: Text('لا توجد عقارات متاحة حالياً'));
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final prop = properties[index];
                          final data = prop.data;
                          final images = prop.getListValue('images');
                          final title = data['title'] ?? 'بدون عنوان';
                          final address = data['address'] ?? '';
                          final price = data['pricePerNight']?.toString() ?? '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailPage(propertyId: prop.id),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: images.isNotEmpty
                                        ? Image.network(
                                      'http://152.53.84.199:8090/api/files/${prop.collectionId}/${prop.id}/${images[0]}',
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.home, size: 40),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(address,
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text('$price ل.س / ليلة',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) async {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 2) {
                if (authRepo.currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthPage(),
                    ),
                  );
                }
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
            ],
          ),
          floatingActionButton: userRole == 'owner'
              ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddPropertyPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          )
              : null,
        );
      },
    );
  }
}

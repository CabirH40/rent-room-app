import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/pages/auth_page.dart';
import '../../booking/presentation/BookingPage.dart';

final authRepo = AuthRepository();

class PropertyDetailPage extends StatelessWidget {
  final String propertyId;
  const PropertyDetailPage({super.key, required this.propertyId});

  Future<String?> getUserRole() async {
    final user = authRepo.currentUser;
    if (user == null) return null;
    final record = await authRepo.pbInstance.collection('users').getOne(user.id);
    return record.data['role'] as String?;
  }

  Future<RecordModel?> getProperty() async {
    final prop = await authRepo.pbInstance.collection('properties').getOne(propertyId);
    return prop;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // صور العقار في PageView
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, idx) => Image.network(
                          'http://152.53.84.199:8090/api/files/${snapshot.data!.collectionId}/${snapshot.data!.id}/${images[idx]}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.home, size: 80, color: Colors.grey)),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    transform: Matrix4.translationValues(0, -24, 0),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['address'] ?? '',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'السعر لليلة: ${data['pricePerNight']?.toString() ?? ''} ل.س',
                          style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['description'] ?? '',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        FutureBuilder<String?>(
                          future: getUserRole(),
                          builder: (context, roleSnap) {
                            final user = authRepo.currentUser;
                            final isTenant = roleSnap.data == 'tenant';

                            if (user == null) {
                              return SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text('سجل الدخول للحجز'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AuthPage()),
                                    );
                                  },
                                ),
                              );
                            } else if (isTenant) {
                              return SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.calendar_month),
                                  label: const Text('احجز الآن'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingPage(propertyId: propertyId),
                                      ),
                                    );
                                  },

                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_room/features//profile/presentation/profile_page.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  final List<String> products = const [
    'غرفة 1',
    'شقة 2',
    'فيلا 3',
    'شقة 4',
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(products[index]),
              subtitle: const Text('تفاصيل العقار'),
            ),
          );
        },
      ),
    );
  }
}

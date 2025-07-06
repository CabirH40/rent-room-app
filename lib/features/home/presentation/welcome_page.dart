import 'package:flutter/material.dart';
import '../../auth/presentation/pages/auth_page.dart';
import 'package:rent_room/features/home/presentation/product_page.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('ابدأ'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
    );
  }
}

// شاشة رئيسية تجمع المنتجات وزاوية تسجيل الدخول
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ProductPage(),  // عرض المنتجات في الخلفية

          // زر صغير في الزاوية لتسجيل الدخول
          Positioned(
            top: 40,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              },
              child: const Text('تسجيل الدخول'),
            ),
          ),
        ],
      ),
    );
  }
}

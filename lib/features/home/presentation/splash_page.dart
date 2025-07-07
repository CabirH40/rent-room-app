import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/presentation/welcome_page.dart';
final authRepo = AuthRepository();
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // يمكنك استخدام صورة شعار أو Lottie animation هنا
            // Image.asset('assets/logo.png', width: 120),
            Icon(Icons.meeting_room, size: 80, color: Colors.blue[700]),
            const SizedBox(height: 24),
            Text(
              'أهلاً بك في',
              style: TextStyle(
                fontSize: 26,
                color: isDark ? Colors.white : Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rent Room',
              style: TextStyle(
                fontSize: 32,
                color: Colors.blue,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '...جاري التحميل',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

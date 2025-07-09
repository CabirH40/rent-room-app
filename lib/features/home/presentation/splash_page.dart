import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rent_room/features/home/presentation/welcome_page.dart';

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
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_rounded, size: 90, color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              'مرحبًا بك في',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.blueGrey[900],
              ),
            ),
            Text(
              'BaytnBeyond',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.blueAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(
              '...جاري التحميل',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

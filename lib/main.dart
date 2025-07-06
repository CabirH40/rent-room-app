import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'features/home/presentation/welcome_page.dart';
import 'features/home/presentation/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Room',
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

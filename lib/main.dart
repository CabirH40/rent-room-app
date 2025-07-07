import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/presentation/splash_page.dart';
import 'core/services/pb_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة SharedPreferences لتحميل الجلسة المحفوظة
  final prefs = await SharedPreferences.getInstance();
  final initialAuth = prefs.getString('pb_auth');

  // إنشاء كائن PocketBase مع تخزين الجلسة تلقائيًا
  pb = PocketBase(
    'http://152.53.84.199:8090',
    authStore: AsyncAuthStore(
      save: (String data) async {
        await prefs.setString('pb_auth', data);
      },
      initial: initialAuth,
      clear: () async {
        await prefs.remove('pb_auth');
      },
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Room',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // إذا كنت تستخدم Material 3
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: ThemeMode.system, // يدعم الوضع الليلي والنهاري تلقائيًا
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}

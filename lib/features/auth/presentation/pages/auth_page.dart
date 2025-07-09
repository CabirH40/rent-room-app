import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _repo = AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isLogin = true;
  String message = '';

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      message = '';
    });
  }

  Future<void> _submit() async {
    try {
      if (isLogin) {
        await _repo.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => message = 'تم تسجيل الدخول بنجاح');
      } else {
        await _repo.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        setState(() => message = 'تم إنشاء الحساب بنجاح');
      }
    } catch (e) {
      setState(() => message = 'حدث خطأ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'تسجيل دخول' : 'إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'الاسم'),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            if (!isLogin)
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب'),
            ),
            TextButton(
              onPressed: _toggleForm,
              child: Text(
                isLogin ? 'إنشاء حساب جديد؟' : 'لديك حساب؟ تسجيل دخول',
              ),
            ),
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

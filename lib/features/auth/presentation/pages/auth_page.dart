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

  String? _selectedRole; // الرول: 'owner' أو 'tenant'

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      message = '';
      _selectedRole = null;
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
        if (_selectedRole == null) {
          setState(() => message = 'يرجى اختيار نوع المستخدم');
          return;
        }
        await _repo.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole!,  // نمرر الرول
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'الاسم'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: Text('اختر نوع المستخدم'),
                  items: [
                    DropdownMenuItem(value: 'owner', child: Text('موجر')),
                    DropdownMenuItem(value: 'tenant', child: Text('مستأجر')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                SizedBox(height: 10),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              if (!isLogin) ...[
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'رقم الهاتف'),
                ),
              ],
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
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(message, style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

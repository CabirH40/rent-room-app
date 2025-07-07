import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';

final authRepo = AuthRepository();

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isLogin = true;
  String message = '';
  String? _selectedRole;

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      message = '';
      _selectedRole = null;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => message = '');
    try {
      if (isLogin) {
        final result = await authRepo.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (result != null && authRepo.currentUser != null) {
          setState(() => message = 'تم تسجيل الدخول بنجاح');
        } else {
          setState(() => message = 'فشل تسجيل الدخول، تحقق من البيانات.');
        }
      } else {
        if (_selectedRole == null) {
          setState(() => message = 'يرجى اختيار نوع المستخدم');
          return;
        }
        if (_passwordController.text.trim().length < 8) {
          setState(() => message = 'كلمة المرور يجب أن تكون 8 محارف أو أكثر');
          return;
        }

        final record = await authRepo.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole!,
        );
        if (record != null) {
          setState(() => message = 'تم إنشاء الحساب بنجاح');
        } else {
          setState(() => message = 'تعذر إنشاء الحساب!');
        }
      }
    } catch (e) {
      String errorMsg = 'حدث خطأ: $e';
      if (e.runtimeType.toString().contains('ClientException')) {
        try {
          final dynamic err = e;
          final res = err.message ?? e.toString();
          errorMsg = res.toString();
        } catch (_) {
          errorMsg = e.toString();
        }
      }
      setState(() => message = errorMsg.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.blueGrey[800] : Colors.blue,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLogin ? Icons.login : Icons.person_add,
                      size: 54,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 16),
                    if (!isLogin) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        hint: const Text('اختر نوع المستخدم'),
                        items: const [
                          DropdownMenuItem(value: 'owner', child: Text('مؤجر')),
                          DropdownMenuItem(value: 'tenant', child: Text('مستأجر')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value);
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_circle_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    if (!isLogin) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submit,
                        child: Text(
                          isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(
                        isLogin ? 'إنشاء حساب جديد؟' : 'لديك حساب؟ تسجيل دخول',
                        style: TextStyle(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: message.contains('نجاح') ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

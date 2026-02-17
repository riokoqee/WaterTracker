import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../api/token_storage.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _visible = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiClient();
      final auth = AuthApi(api, TokenStorage());
      await auth.register(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _email.text.trim()),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'MinecraftRus'),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Регистрация',
          style: TextStyle(
            fontFamily: 'MinecraftRus',
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: _first,
              decoration: _dec('Имя'),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _last,
              decoration: _dec('Фамилия'),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email'),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: !_visible,
              decoration: _dec(
                'Пароль',
                suffix: IconButton(
                  icon: Icon(
                    _visible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textGray,
                  ),
                  onPressed: () => setState(() => _visible = !_visible),
                ),
              ),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: _dec('Подтвердите пароль'),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: 'MinecraftRus',
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          fontFamily: 'MinecraftRus',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


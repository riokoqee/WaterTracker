import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../api/token_storage.dart';
import '../../widgets/animated_wave.dart';
import 'register_screen.dart';
import '../main_navigation.dart';
import 'dart:convert';
import '../admin_panel_screen.dart';
import '../../services/steps_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _visible = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final api = ApiClient();
      final auth = AuthApi(api, TokenStorage());
      await auth.login(_email.text.trim(), _pass.text);

      final profile = await api.get('/api/profile');
      final data = jsonDecode(profile.body);

      // ✅ Безопасно достаем roles
      final roles = (data['roles'] ?? []) as List;
      print("👤 Logged in, roles: $roles");

      if (!mounted) return;

      if (roles.contains('ADMIN') || roles.contains('ROLE_ADMIN')) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString(), style: const TextStyle(fontFamily: 'MinecraftRus')),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPasswordDialog() async {
    final c = TextEditingController();
    bool sending = false;
    String? err;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Забыли пароль?',
            style: TextStyle(fontFamily: 'MinecraftRus', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Введите email, мы пришлём инструкцию для сброса.',
                style: TextStyle(fontFamily: 'MinecraftRus', fontSize: 13, color: AppColors.textGray),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'MinecraftRus'),
                decoration: InputDecoration(
                  hintText: 'example@mail.com',
                  hintStyle: const TextStyle(fontFamily: 'MinecraftRus'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (err != null)
                Text(err!, style: const TextStyle(fontFamily: 'MinecraftRus', color: Colors.red, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(ctx),
              child: const Text('Отмена', style: TextStyle(fontFamily: 'MinecraftRus')),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (c.text.trim().isEmpty) return;
                      setState(() { sending = true; err = null; });
                      try {
                        final api = ApiClient();
                        final auth = AuthApi(api, TokenStorage());
                        await auth.startPasswordReset(c.text.trim());
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: AppColors.primary,
                            content: Text('Письмо отправлено', style: TextStyle(fontFamily: 'MinecraftRus')),
                          ));
                        }
                      } catch (e) {
                        setState(() => err = e.toString());
                      } finally {
                        setState(() => sending = false);
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Отправить', style: TextStyle(fontFamily: 'MinecraftRus', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) => InputDecoration(
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
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AnimatedWave(color: AppColors.accent, height: 90, offset: 0),
                AnimatedWave(color: AppColors.primary, height: 100, offset: 1),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  const Text('Вход', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'MinecraftRus', fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textDark)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _email,
                    style: const TextStyle(fontFamily: 'MinecraftRus'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Ваш email'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pass,
                    obscureText: !_visible,
                    style: const TextStyle(fontFamily: 'MinecraftRus'),
                    decoration: _inputDecoration(
                      'Пароль',
                      suffix: IconButton(
                        icon: Icon(_visible ? Icons.visibility_off : Icons.visibility, color: AppColors.textGray),
                        onPressed: () => setState(() => _visible = !_visible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _forgotPasswordDialog,
                    child: const Text('Забыли пароль?', style: TextStyle(fontFamily: 'MinecraftRus', color: AppColors.primary)),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _loading ? 'Входим…' : 'Войти',
                        style: const TextStyle(fontFamily: 'MinecraftRus', color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Нет аккаунта? Зарегистрироваться', style: TextStyle(fontFamily: 'MinecraftRus', color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


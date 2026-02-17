import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../api/api_client.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialToken;
  const ResetPasswordScreen({super.key, this.initialToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _token = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Для Web токен может прийти из URL (?token=...)
    final qp = Uri.base.queryParameters['token'];
    _token.text = widget.initialToken ?? qp ?? '';
  }

  @override
  void dispose() {
    _token.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }
    if (_token.text.isEmpty) {
      setState(() => _error = 'Токен не найден');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiClient();
      final r = await api.post('/api/auth/reset-password', body: {
        'token': _token.text.trim(),
        'newPassword': _pass.text,
      });
      if (r.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Пароль успешно изменён', style: TextStyle(fontFamily: 'MinecraftRus')),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() => _error = 'Ошибка: ${r.body}');
      }
    } catch (e) {
      setState(() => _error = 'Ошибка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'MinecraftRus'),
        filled: true,
        fillColor: Colors.white,
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
        title: const Text('Сброс пароля', style: TextStyle(fontFamily: 'MinecraftRus', color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _token, decoration: _dec('Токен из письма')),
            const SizedBox(height: 12),
            TextField(controller: _pass, obscureText: true, decoration: _dec('Новый пароль')),
            const SizedBox(height: 12),
            TextField(controller: _confirm, obscureText: true, decoration: _dec('Подтвердите пароль')),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(fontFamily: 'MinecraftRus', color: Colors.red, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Сохранить', style: TextStyle(fontFamily: 'MinecraftRus', color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}


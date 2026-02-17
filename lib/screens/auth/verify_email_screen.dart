import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../api/api_client.dart';
import '../../api/verification_api.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  String? _error;
  late final VerificationApi _verify = VerificationApi(ApiClient());

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await _verify.sendCode(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Код отправлен на почту', style: TextStyle(fontFamily: 'MinecraftRus')),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirm() async {
    if (_codeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Введите код');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await _verify.confirm(widget.email, _codeCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Email подтверждён', style: TextStyle(fontFamily: 'MinecraftRus')),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Подтверждение почты',
          style: TextStyle(
            fontFamily: 'MinecraftRus',
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Мы отправили код на ${widget.email}',
              style: const TextStyle(fontFamily: 'MinecraftRus', color: AppColors.textGray),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Введите код',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: const TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(fontFamily: 'MinecraftRus', color: Colors.red, fontSize: 13),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _verifying ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _verifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Подтвердить', style: TextStyle(fontFamily: 'MinecraftRus', color: Colors.white)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _sending ? null : _sendCode,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Отправить код снова', style: TextStyle(fontFamily: 'MinecraftRus', color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}


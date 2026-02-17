import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/profile_api.dart';
import '../api/api_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _api = ApiClient();
  late final ProfileApi _profile = ProfileApi(_api);

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _wakeTime = TextEditingController();
  final _sleepTime = TextEditingController();

  String gender = "MALE";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await _profile.me();
      setState(() {
        _firstName.text = me['firstName'] ?? '';
        _lastName.text = me['lastName'] ?? '';
        _email.text = me['email'] ?? '';
        _age.text = (me['age'] ?? '').toString();
        _weight.text = (me['weightKg'] ?? '').toString();
        _height.text = (me['heightCm'] ?? '').toString();
        _wakeTime.text = me['wakeTime'] ?? '';
        _sleepTime.text = me['sleepTime'] ?? '';
        gender = me['gender'] ?? "OTHER";
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      print({
        'firstName': _firstName.text,
        'lastName': _lastName.text,
        'email': _email.text,
        'gender': gender,
        'age': int.tryParse(_age.text),
        'weightKg': double.tryParse(_weight.text),
        'heightCm': double.tryParse(_height.text),
      });
      await _profile.updateProfile(
        context: context,
        firstName: _firstName.text,
        lastName: _lastName.text,
        email: _email.text,
        gender: gender,
        age: int.tryParse(_age.text),
        weightKg: double.tryParse(_weight.text),
        heightCm: double.tryParse(_height.text),
        wakeTime: _normalizeTime(_wakeTime.text),
        sleepTime: _normalizeTime(_sleepTime.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль сохранён ✅")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при сохранении: $e")),
      );
    }
  }

  String? _normalizeTime(String? t) {
    if (t == null || t.isEmpty) return null;
    // Если пользователь ввёл HH:mm — добавляем секунды
    if (t.length == 5) return "$t:00";
    // Если случайно вышло HH:mm:ss:00 — отрезаем последние 3 символа
    if (t.length > 8) return t.substring(0, 8);
    return t;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Редактировать профиль",
          style: TextStyle(
            fontFamily: "MinecraftRus",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _input("Имя", _firstName),
              _input("Фамилия", _lastName),
              _input("Email", _email),
              _input("Возраст", _age),
              _input("Вес (кг)", _weight),
              _input("Рост (см)", _height),

              // Время сна и пробуждения
              _timeField("Время пробуждения", _wakeTime),
              _timeField("Время сна", _sleepTime),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _radio("MALE", "Мужской"),
                  _radio("FEMALE", "Женский"),
                ],
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Сохранить",
                    style: TextStyle(
                      fontFamily: "MinecraftRus",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController control) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: control,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: "MinecraftRus", color: AppColors.textGray),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontFamily: "MinecraftRus"),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _pickTime(controller),
      child: AbsorbPointer(
        child: _input(label, controller),
      ),
    );
  }

  Widget _radio(String value, String label) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: gender,
          activeColor: AppColors.primary,
          onChanged: (val) => setState(() => gender = val!),
        ),
        Text(label, style: const TextStyle(fontFamily: "MinecraftRus", fontSize: 13)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/profile_api.dart';
import 'edit_profile_screen.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _api = ApiClient();
  late final ProfileApi _profile = ProfileApi(_api);
  bool _loading = true;
  Map<String, dynamic>? data;

  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await _profile.me();
      if (!mounted) return;
      setState(() {
        data = me;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final user = data ?? {};
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final age = user['age'] ?? 0;
    final gender = (user['gender'] ?? 'OTHER').toString();
    final weight = (user['weightKg'] ?? 0).toDouble();
    final height = (user['heightCm'] ?? 0).toDouble();
    final wake = user['wakeTime'] ?? '';
    final sleep = user['sleepTime'] ?? '';
    final goal = user['goalTargetMl'] ?? 2000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontFamily: 'MinecraftRus',
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab, 
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'Инфо'),
            Tab(text: 'Рекомендации'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildInfoTab(firstName, lastName, age, gender, weight, height, wake, sleep, goal),
          _buildRecommendations(age, gender, weight, height, wake, sleep, goal),
        ],
      ),
    );
  }

  Widget _buildInfoTab(String firstName, String lastName, int age, String gender,
      double weight, double height, String wake, String sleep, int goal) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ✅ Аватар по центру, как в старом профиле
        Center(
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            backgroundImage: const AssetImage('assets/images/default_avatar.png'),
          ),
        ),
        const SizedBox(height: 20),

        _info('Имя', '$firstName $lastName'),
        _info('Возраст', '$age лет'),
        _info('Пол', gender),
        _info('Вес', '$weight кг'),
        _info('Рост', '$height см'),
        _info('Цель воды', '$goal мл'),
        _info('Время сна', '$sleep'),
        _info('Подъем', '$wake'),
      ],
    );
  }

  Widget _info(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontFamily: 'MinecraftRus', color: AppColors.textGray)),
          Text(value,
              style: const TextStyle(fontFamily: 'MinecraftRus', color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildRecommendations(int age, String gender, double weight, double height,
      String wake, String sleep, int goal) {
    final waterNorm = (weight * 30).toInt(); // мл
    final baseCalories = gender == 'FEMALE'
        ? (10 * weight + 6.25 * height - 5 * age - 161).toInt()
        : (10 * weight + 6.25 * height - 5 * age + 5).toInt();
    final sleepHours = _calcSleepHours(wake, sleep);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _recCard('💧 Вода',
            'Рекомендуется: $waterNorm мл/день.\nСейчас цель: $goal мл.\n${goal < waterNorm ? 'Пей больше!' : 'Отличный баланс!'}'),
        _recCard('🔥 Калории',
            'Норма: $baseCalories ккал/день.\n${age < 20 ? 'Растущий организм — добавь 200–300 ккал.' : ''}'),
        _recCard('🛌 Сон',
            'Вы спите примерно $sleepHours часов.\nДля вашего возраста желательно 8–10 часов сна.'),
        _recCard('🚶 Активность', 'Рекомендуется: 8000–10000 шагов в день.'),
      ],
    );
  }

  double _calcSleepHours(String wake, String sleep) {
    try {
      final wakeParts = wake.split(':').map(int.parse).toList();
      final sleepParts = sleep.split(':').map(int.parse).toList();
      final wakeTime = wakeParts[0] + wakeParts[1] / 60.0;
      final sleepTime = sleepParts[0] + sleepParts[1] / 60.0;
      final diff = (24 - sleepTime + wakeTime) % 24;
      return (8 - (diff - 8).abs()).clamp(0, 12).toDouble();
    } catch (_) {
      return 8;
    }
  }

  Widget _recCard(String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'MinecraftRus', fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(fontFamily: 'MinecraftRus', color: AppColors.textGray)),
      ]),
    );
  }
}

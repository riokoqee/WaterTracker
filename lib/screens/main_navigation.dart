import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart';
import 'settings_tab_screen.dart';
import 'reminder_screen.dart';
import '../api/api_client.dart';
import '../api/goal_api.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int? _initialGlasses; // ← Загружаемая цель из БД
  final GoalApi _goals = GoalApi(ApiClient());

  @override
  void initState() {
    super.initState();
    _loadGoal(); // ← Загружаем с backend
  }

  Future<void> _loadGoal() async {
    try {
      final targetMl = await _goals.getTargetMl(); // например, 2000 мл
      setState(() {
        _initialGlasses = (targetMl / 250).round(); // Переводим в стаканы
      });
    } catch (e) {
      setState(() => _initialGlasses = 8); // если ошибка - ставим дефолт
    }
  }

  @override
  Widget build(BuildContext context) {
    // Пока загружаем - показываем загрузку
    if (_initialGlasses == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      const HomeScreen(),
      const AnalyticsScreen(),
      ReminderScreen(), 
      const SettingsTabScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedLabelStyle: const TextStyle(fontFamily: 'MinecraftRus', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'MinecraftRus', fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Аналитика'),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: 'Напоминания'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

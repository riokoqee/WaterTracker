import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton("История", 0),
            const SizedBox(width: 12),
            _buildTabButton("Настройки", 1),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedTab == 0
            ? const HistoryScreen()
            : const SettingsScreen(),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "MinecraftRus",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}

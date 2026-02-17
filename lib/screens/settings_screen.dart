import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/settings_api.dart';
import '../api/goal_api.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _api = ApiClient();
  late final SettingsApi _settings = SettingsApi(_api);
  late final GoalApi _goals = GoalApi(_api);

  bool _isDarkMode = false;
  String _unit = 'мл';
  int _goal = 2000;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _settings.get();
      final t = await _goals.getTargetMl();
      if (!mounted) return;
      setState(() {
        _isDarkMode = s.darkMode;
        _goal = t;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Настройки',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              children: [
                const Text(
                  'Общие',
                  style: TextStyle(
                    fontFamily: 'MinecraftRus',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  title: 'Тёмная тема',
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (v) async {
                      setState(() => _isDarkMode = v);
                      try { await _settings.update(darkMode: v); } catch (_) {}
                    },
                  ),
                ),
                _buildSettingTile(
                  title: 'Единицы измерения',
                  trailing: DropdownButton<String>(
                    value: _unit,
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    icon: const SizedBox.shrink(),
                    style: const TextStyle(
                      fontFamily: 'MinecraftRus',
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'мл', child: Text('мл')),
                      DropdownMenuItem(value: 'литры', child: Text('литры')),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? _unit),
                  ),
                ),
                _buildSettingTile(
                  title: 'Дневная цель (в мл)',
                  trailing: GestureDetector(
                    onTap: () async {
                      final controller = TextEditingController(text: _goal.toString());
                      final result = await showDialog<int>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Изменить цель (в мл):'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
                              child: const Text('ОК'),
                            ),
                          ],
                        ),
                      );
                      if (result != null) {
                        setState(() => _goal = result);
                        try { await _goals.upsert(targetMl: result); } catch (_) {}
                      }
                    },
                    child: Text(
                      '$_goal мл',
                      style: const TextStyle(
                        fontFamily: 'MinecraftRus',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingTile({required String title, required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'MinecraftRus',
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}


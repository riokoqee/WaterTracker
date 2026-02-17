import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/water_level_indicator.dart';
import '../api/api_client.dart';
import '../api/dashboard_api.dart';
import '../state/water_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiClient();
  late final DashboardApi _dashboard = DashboardApi(_api);

  String lastIntake = '';
  String greeting = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _dashboard.get();
      if (!mounted) return;

      // ✅ Загружаем значения с backend в WaterState
      final waterState = context.read<WaterState>();
      waterState.consumedMl = d.currentMl;
      waterState.goalMl = d.targetMl;
      waterState.glassSize = d.glassSizeMl;

      print('📡 DASHBOARD: goal=${d.targetMl}, current=${d.currentMl}, glass=${d.glassSizeMl}');

      setState(() {
        lastIntake = d.lastIntakeTime;
        greeting = d.greeting;
      });
    } catch (_) {}
  }

  Future<void> addWater(int ml) async {
    await context.read<WaterState>().drink(ml);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final waterState = context.watch<WaterState>();

    final currentWater = waterState.consumedMl;
    final goalWater = waterState.goalMl;
    final percent =
        goalWater == 0 ? 0 : (currentWater / goalWater).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== Приветствие ====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Добрый день,',
                          style: TextStyle(
                            fontFamily: 'MinecraftRus',
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          greeting.isEmpty ? 'Water Tracker' : greeting,
                          style: const TextStyle(
                            fontFamily: 'MinecraftRus',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==== Карточка информации ====
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF56C3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastIntake.isEmpty ? '—' : lastIntake,
                              style: const TextStyle(
                                fontFamily: 'MinecraftRus',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Сегодняшний прогресс',
                              style: TextStyle(
                                fontFamily: 'MinecraftRus',
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/drop_large.png', height: 60),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: WaterLevelIndicator(
                    progress: percent.toDouble(),
                    goalMl: waterState.goalMl, 
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => addWater(waterState.glassSize),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Выпить ${waterState.glassSize} мл',
                      style: const TextStyle(
                        fontFamily: 'MinecraftRus',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    percent >= 1.0
                        ? 'Отлично! Цель выполнена'
                        : 'Выполнено ${(percent * 100).toInt()}% дневной цели',
                    style: const TextStyle(
                      fontFamily: 'MinecraftRus',
                      fontSize: 13,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

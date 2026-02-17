import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/water_api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = ApiClient();
  late final WaterApi _water = WaterApi(_api);
  final Map<String, dynamic> _stats = {
    'weeklyAvg': 0,
    'monthlyAvg': 0,
    'completion': 0,
    'frequency': 0,
  };
  List<bool> _weekProgress = List<bool>.filled(7, false);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _water.stats8Days();
      final totals = s.totalsMl;
      final last7 = totals.length >= 7 ? totals.sublist(totals.length - 7) : totals;
      final weeklyAvg = last7.isEmpty ? 0 : (last7.reduce((a,b)=>a+b) / last7.length).round();
      setState(() {
        _stats['weeklyAvg'] = weeklyAvg;
        _stats['monthlyAvg'] = (totals.reduce((a,b)=>a+b) / totals.length).round();
        _stats['completion'] = ((weeklyAvg / s.targetMl) * 100).clamp(0, 100).round();
        _stats['frequency'] = last7.where((e) => e > 0).length;
        _weekProgress = last7.map((e) => e > 0).toList();
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
          'История',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Отметки за неделю',
                          style: TextStyle(
                            fontFamily: 'MinecraftRus',
                            fontSize: 14,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_weekProgress.length, (index) {
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor: _weekProgress[index]
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              child: Icon(
                                _weekProgress[index]
                                    ? Icons.check
                                    : Icons.circle_outlined,
                                color: _weekProgress[index]
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Итоги',
                    style: TextStyle(
                      fontFamily: 'MinecraftRus',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatRow(
                          'Среднее за неделю',
                          '${_stats['weeklyAvg']} мл / день',
                          Colors.green,
                        ),
                        _buildStatRow(
                          'Среднее за период',
                          '${_stats['monthlyAvg']} мл / день',
                          Colors.blue,
                        ),
                        _buildStatRow(
                          'Среднее выполнение',
                          '${_stats['completion']}%',
                          Colors.orange,
                        ),
                        _buildStatRow(
                          'Дней с отметками',
                          '${_stats['frequency']} дн.',
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String title, String value, Color dotColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: dotColor, size: 10),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'MinecraftRus',
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'MinecraftRus',
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}


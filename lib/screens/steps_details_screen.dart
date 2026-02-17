import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../services/steps_service.dart';

class StepsDetailsScreen extends StatefulWidget {
  const StepsDetailsScreen({super.key});

  @override
  State<StepsDetailsScreen> createState() => _StepsDetailsScreenState();
}

class _StepsDetailsScreenState extends State<StepsDetailsScreen> {
  bool _loading = true;

  List<String> _labels = []; // ["Пн", "Вт", "Ср"...]
  List<int> _values = [];    // [5000, 8200...]
  int todaySteps = 0;

  // Для аналитики:
  int _average = 0;
  String _bestDay = "";
  int _bestValue = 0;
  String _worstDay = "";
  int _worstValue = 0;
  int _completedDays = 0; // Дней, где >= 10 000 шагов

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // 1. Получаем данные с сервера
      final Map<String, int> week = await StepsService.instance.getWeekStats();

      if (week.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      // 2. Сортируем по дате
      final sorted = week.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      final dates = sorted.map((e) => e.key).toList();
      final steps = sorted.map((e) => e.value).toList();

      // 3. Переводим даты в дни недели
      const days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];
      final labels = dates.map((d) {
        final date = DateTime.parse(d);
        return days[date.weekday - 1];
      }).toList();

      todaySteps = steps.last;

      // 4. Аналитика:
      _average = steps.reduce((a, b) => a + b) ~/ steps.length;
      final maxEntry = sorted.reduce((a, b) => a.value > b.value ? a : b);
      final minEntry = sorted.reduce((a, b) => a.value < b.value ? a : b);

      _bestDay = days[DateTime.parse(maxEntry.key).weekday - 1];
      _bestValue = maxEntry.value;
      _worstDay = days[DateTime.parse(minEntry.key).weekday - 1];
      _worstValue = minEntry.value;
      _completedDays = steps.where((v) => v >= 10000).length;

      setState(() {
        _labels = labels;
        _values = steps;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки шагов: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Статистика шагов",
          style: TextStyle(
            fontFamily: "MinecraftRus",
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Сегодня ты прошёл:",
                    style: TextStyle(fontSize: 15, fontFamily: "MinecraftRus"),
                  ),
                  Text(
                    "$todaySteps шагов",
                    style: const TextStyle(
                      fontFamily: "MinecraftRus",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📊 График
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= _labels.length) return const SizedBox();
                                return Text(
                                  _labels[i],
                                  style: const TextStyle(fontSize: 11, fontFamily: "MinecraftRus"),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < _values.length; i++)
                                FlSpot(i.toDouble(), _values[i].toDouble()),
                            ],
                            isCurved: true,
                            barWidth: 3,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📌 Карточки аналитики
                  _StatCard(title: "Среднее за неделю", value: "$_average", unit: "шагов"),
                  const SizedBox(height: 10),
                  _StatCard(title: "Лучший день", value: "$_bestValue", unit: _bestDay),
                  const SizedBox(height: 10),
                  _StatCard(title: "Худший день", value: "$_worstValue", unit: _worstDay),
                  const SizedBox(height: 10),
                  _StatCard(title: "Цель достигнута", value: "$_completedDays / 7", unit: "дней"),
                  const SizedBox(height: 20),

                  // 📋 Список шагов по дням
                  Expanded(
                    child: ListView.builder(
                      itemCount: _labels.length,
                      itemBuilder: (_, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "${_labels[i]} — ${_values[i]} шагов",
                            style: const TextStyle(fontFamily: "MinecraftRus", fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _StatCard({required this.title, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontFamily: "MinecraftRus", fontSize: 14)),
          Text(
            "$value $unit",
            style: const TextStyle(
              fontFamily: "MinecraftRus",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

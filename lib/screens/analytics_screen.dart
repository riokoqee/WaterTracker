import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../services/steps_service.dart';
import '../api/api_client.dart';
import '../api/stats_api.dart';
import 'steps_details_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Future<void> _refresh() async {
    try {
      final steps = StepsService.instance.todaySteps.value;
      final api = ApiClient();
      final stats = StatsApi(api);
      await stats.sendSteps(steps);
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Аналитика",
          style: TextStyle(
            fontFamily: "MinecraftRus",
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: const SizedBox(
            height: 520,
            child: Column(
              children: [
                Expanded(flex: 2, child: _TopRow()),
                SizedBox(height: 10),
                Expanded(flex: 2, child: _BottomRow()),
                SizedBox(height: 10),
                Expanded(flex: 1, child: RandomTipCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 6),
            child: _WaterChartCard(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 6),
            child: _StepsCard(),
          ),
        ),
      ],
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 6),
            child: _AnalyticsCard(
              title: "Калории",
              value: "1320",
              unit: "Ккал",
              icon: Icons.local_fire_department,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 6),
            child: _AnalyticsCard(
              title: "Сон",
              value: "7 ч",
              unit: "вчера",
              icon: Icons.nightlight_round,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterChartCard extends StatefulWidget {
  const _WaterChartCard();

  @override
  State<_WaterChartCard> createState() => _WaterChartCardState();
}

class _WaterChartCardState extends State<_WaterChartCard> {
  final _api = ApiClient();
  late final StatsApi _stats = StatsApi(_api);
  int _todayMl = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _stats.dailyWater();
      if (!mounted) return;
      setState(() {
        _todayMl = d.totalMl;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liters = (_todayMl / 1000.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Вода",
            style: TextStyle(
              fontFamily: "MinecraftRus",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 1.3),
                            FlSpot(1, 1.6),
                            FlSpot(2, 1.4),
                            FlSpot(3, 2.0),
                            FlSpot(4, 1.8),
                            FlSpot(5, 2.4),
                            FlSpot(6, 2.1),
                          ],
                          isCurved: true,
                          barWidth: 3,
                          color: AppColors.primary,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withOpacity(0.4),
                                AppColors.primary.withOpacity(0.15),
                                Colors.white,
                              ],
                            ),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            '${liters.toStringAsFixed(1)} литра',
            style: const TextStyle(
              fontFamily: "MinecraftRus",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatefulWidget {
  const _StepsCard();

  @override
  State<_StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<_StepsCard> {
  static const int goal = 10000;

  @override
  void initState() {
    super.initState();
    StepsService.instance.start();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StepsDetailsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Шаги",
              style: TextStyle(
                fontFamily: "MinecraftRus",
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: StepsService.instance.todaySteps,
                  builder: (_, steps, __) {
                    final progress = (steps / goal).clamp(0.0, 1.0);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primary,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$steps',
                              style: const TextStyle(
                                fontFamily: "MinecraftRus",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              "из 10 000",
                              style: TextStyle(
                                fontFamily: "MinecraftRus",
                                fontSize: 10,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: "MinecraftRus",
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: "MinecraftRus",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontFamily: "MinecraftRus",
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class RandomTipCard extends StatefulWidget {
  const RandomTipCard({super.key});

  @override
  State<RandomTipCard> createState() => _RandomTipCardState();
}

class _RandomTipCardState extends State<RandomTipCard> {
  static final List<String> tips = [
    "Пей воду каждый час, даже если не хочешь",
    "Начинай утро со стакана воды",
    "Вода помогает улучшить пищеварение",
    "Пить воду до еды помогает контролировать аппетит",
    "Обезвоживание может вызвать усталость",
    "Пей больше воды во время жаркой погоды",
    "Вода выводит токсины из организма",
    "Часто головные боли вызваны обезвоживанием",
    "Питьё воды поддерживает эластичность кожи",
    "Добавь лимон в воду для вкуса и витамина C",
    "Холодная вода бодрит и тонизирует",
    "Вода ускоряет метаболизм",
    "Пей воду перед тренировкой и после неё",
    "Чистая вода полезнее любых напитков",
    "Заменяй сладкие напитки водой",
    "Обезвоживание снижает концентрацию",
    "Пей воду при каждом чувстве голода — возможно, ты хочешь пить",
    "Поддерживай водный баланс даже зимой",
    "Вода регулирует температуру тела",
    "Употребление воды важно для почек",
    "Вода помогает снизить давление",
    "Выпей стакан воды, если чувствуешь раздражительность",
    "Регулярное питьё улучшает работу сердца",
    "Пей воду до и после сна",
    "Тёплая вода с утра — хорошая привычка",
    "Пей больше, если употребляешь кофе или чай",
    "Вода важна для суставов",
    "Чистая кожа начинается с чистой воды",
    "Слишком много воды сразу — вредно, пей равномерно",
    "Сделай воду своей основной привычкой",
    "Вода помогает при запоре",
    "Обезвоживание ухудшает настроение",
    "Уменьши кофе — увеличь воду",
    "Носи с собой бутылку воды",
    "Следи за цветом мочи — он показатель гидратации",
    "Вода необходима для роста мышц",
    "Пить воду важно в любом возрасте",
    "При простуде увеличь потребление жидкости",
    "Пей воду перед походом на улицу в жару",
    "Вода снижает риск образования камней в почках",
    "Вода помогает при сухости кожи",
    "Поддерживай водный баланс при занятиях спортом",
    "Не забывай пить воду в поездках",
    "Вода помогает сосредоточиться",
    "Обезвоживание ухудшает память",
    "Следи за уровнем потребления воды ежедневно",
    "Вода снижает уровень сахара в крови",
    "Пей по глотку в течение дня",
    "Создай себе привычку пить воду после каждого приёма пищи",
  ];

  late String currentTip;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    currentTip = tips.first;
  }

  void _changeTip() {
    setState(() {
      currentTip = (tips..shuffle()).first;
    });
  }

  void _animateTap() async {
    setState(() => _scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() {
      _scale = 1.0;
      _changeTip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animateTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/minecraft_sign.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            currentTip,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "MinecraftRus",
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

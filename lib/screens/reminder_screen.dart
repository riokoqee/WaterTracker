import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/api_client.dart';
import '../api/goal_api.dart';
import '../api/water_api.dart';
import 'package:provider/provider.dart';
import '../state/water_state.dart';

// ==== из новой версии (для нижней панели) ====
enum GoalUnit { glass, ml, liter }
enum SortMode { popular, amountAsc, amountDesc, nameAsc }

class GoalTemplate {
  final String title;
  final String category; // для фильтра
  final int glasses;     // храним в «стаканах» (1 стакан = 250 мл)
  final String emoji;

  const GoalTemplate({
    required this.title,
    required this.category,
    required this.glasses,
    required this.emoji,
  });
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiClient();
  late final GoalApi _goals = GoalApi(_api);
  late final WaterApi _water = WaterApi(_api);

  late WaterState waterState;
  
  // Анимация стакана
  late AnimationController _waveController;
  double _animatedProgress = 0.0;

  // --- Состояние нижней панели (новые шаблоны целей) ---
  final TextEditingController _goalController = TextEditingController();
  String _query = '';
  String _category = 'All';
  GoalUnit _unit = GoalUnit.glass;
  SortMode _sortMode = SortMode.popular;

  // Данные для шаблонов
  static const int _glassSizeForTemplates = 250;
  final List<String> _categories = const [
    'All', 'Season', 'Sport', 'Family', 'Health', 'Work', 'Lifestyle'
  ];

  final Map<String, int> _popularity = {
    'Summer Day': 95,
    'Sporty': 90,
    'Gym Day': 88,
    'Office Mode': 80,
    'Lazy Sunday': 72,
    'Snow Day': 70,
    'Child': 68,
    'Ramadan': 60,
    'Sauna Day': 58,
    'Traveler': 55,
    'Detox': 54,
    'Workaholic': 52,
    'Gamer Mode': 50,
    'Focus Day': 49,
    'Study Day': 47,
  };

  late final List<GoalTemplate> _templates = const [
    GoalTemplate(title: 'Summer Day',   category: 'Season',   glasses: 10, emoji: '☀️'),
    GoalTemplate(title: 'Snow Day',     category: 'Season',   glasses: 5,  emoji: '❄️'),
    GoalTemplate(title: 'Sporty',       category: 'Sport',    glasses: 7,  emoji: '🏀'),
    GoalTemplate(title: 'Gym Day',      category: 'Sport',    glasses: 8,  emoji: '💪'),
    GoalTemplate(title: 'Sauna Day',    category: 'Health',   glasses: 12, emoji: '🔥'),
    GoalTemplate(title: 'Detox',        category: 'Health',   glasses: 11, emoji: '🧪'),
    GoalTemplate(title: 'Ramadan',      category: 'Lifestyle',glasses: 3,  emoji: '🌙'),
    GoalTemplate(title: 'Child',        category: 'Family',   glasses: 4,  emoji: '🌈'),
    GoalTemplate(title: 'Office Mode',  category: 'Work',     glasses: 6,  emoji: '💧'),
    GoalTemplate(title: 'Workaholic',   category: 'Work',     glasses: 7,  emoji: '🖥️'),
    GoalTemplate(title: 'Lazy Sunday',  category: 'Lifestyle',glasses: 5,  emoji: '😴'),
    GoalTemplate(title: 'Traveler',     category: 'Lifestyle',glasses: 7,  emoji: '✈️'),
    GoalTemplate(title: 'Gamer Mode',   category: 'Lifestyle',glasses: 6,  emoji: '🎮'),
    GoalTemplate(title: 'Focus Day',    category: 'Health',   glasses: 8,  emoji: '🎯'),
    GoalTemplate(title: 'Study Day',    category: 'Work',     glasses: 7,  emoji: '📚'),
  ];

  double get _progress =>
      waterState.goalMl <= 0 ? 0 : (waterState.consumedMl / waterState.goalMl).clamp(0.0, 1.0);

  @override
    void initState() {
      super.initState();

      // ✅ Получаем ссылку на WaterState (глобальное состояние)
      waterState = context.read<WaterState>();

      // ✅ Настраиваем анимацию
      _waveController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat();

      // ✅ Берём текущий прогресс из WaterState
      _animatedProgress = waterState.goalMl == 0
          ? 0
          : (waterState.consumedMl / waterState.goalMl);

      // ✅ Подгружаем свежие данные с backend и сохраняем в WaterState
      _loadFromBackend();
    }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadFromBackend() async {
    try {
      final goalData = await _goals.getGoal();  
      final (consumed, _) = await _water.today();

      if (!mounted) return;

      waterState.goalMl = goalData.targetMl;
      waterState.consumedMl = consumed;
      waterState.notifyListeners();

      setState(() {
        _animatedProgress = 
          goalData.targetMl == 0 ? 0 : consumed / goalData.targetMl;
      });
    } catch (_) {}
  }

  Future<void> _drinkGlass() async {
    try {
      final (consumed, target) = await _water.drink(amountMl: waterState.glassSize);
      if (!mounted) return;
      setState(() {
        waterState.goalMl = target;
        waterState.consumedMl = consumed;
      });
      _animateWaterLevel();
    } catch (_) {}
  }

  void _animateWaterLevel() async {
    final start = _animatedProgress;
    final target = _progress;
    const duration = Duration(milliseconds: 800);
    final startTime = DateTime.now();
    while (true) {
      final t = (DateTime.now().difference(startTime).inMilliseconds /
              duration.inMilliseconds)
          .clamp(0.0, 1.0);
      if (!mounted) return;
      setState(() {
        _animatedProgress =
            start + (target - start) * Curves.easeOutCubic.transform(t);
      });
      if (t >= 1.0) break;
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<void> _changeGlassSize() async {
    final presets = <int>[150, 200, 250, 300, 330, 350, 400, 500];
    final controller = TextEditingController(text: waterState.glassSize.toString());
    int? selected = waterState.glassSize;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44, height: 4, margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Выберите объём (мл)',
                style: TextStyle(fontFamily: 'MinecraftRus', fontSize: 16),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8, runSpacing: 8,
                children: presets.map((ml) {
                  final isSel = selected == ml;
                  return ChoiceChip(
                    label: Text('${ml}', style: const TextStyle(fontFamily: 'MinecraftRus')),
                    selected: isSel,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) {
                      selected = ml;
                      controller.text = ml.toString();
                      // обновим немедленно визуально
                      (ctx as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Или введите вручную, мл',
                  filled: true,
                  fillColor: Color(0xFFF3F5F8),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0) selected = n;
                },
              ),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final n = int.tryParse(controller.text);
                    if (n == null || n <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Введите число больше нуля')),
                      );
                      return;
                    }
                    Navigator.pop(ctx, n);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(fontFamily: 'MinecraftRus', color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value is int && value > 0) {
        setState(() => waterState.glassSize = value);
        context.read<WaterState>().changeGlassSize(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentGlasses = (waterState.consumedMl / waterState.glassSize).floor();
    final targetGlasses = (waterState.goalMl / waterState.glassSize).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Напоминания',
          style: TextStyle(
            fontFamily: 'MinecraftRus',
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Верх: стакан + текст + кнопки (как раньше)
          RefreshIndicator(
            onRefresh: _loadFromBackend,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 360),
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentGlasses} / ${targetGlasses}',
                      style: const TextStyle(
                        fontFamily: 'MinecraftRus',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'стаканов',
                      style: TextStyle(
                        fontFamily: 'MinecraftRus',
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Стакан с волной
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (_, __) => CustomPaint(
                        painter: _GlassPainter(
                          progress: _animatedProgress,
                          wavePhase: _waveController.value * 2 * pi,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  '${waterState.consumedMl} мл из ${waterState.goalMl} мл',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'MinecraftRus',
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 20),

                // Кнопки
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _drinkGlass,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Выпить ${waterState.glassSize} мл',
                            style: const TextStyle(
                              fontFamily: 'MinecraftRus',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _changeGlassSize,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Объём',
                          style: TextStyle(
                            fontFamily: 'MinecraftRus',
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Нижняя поднимаемая панель с шаблонами целей (новый UI)
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.20,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return _buildGoalBottomSheet(scrollController);
            },
          ),
        ],
      ),
    );
  }

  // === НИЖНЯЯ ПАНЕЛЬ С ЦЕЛЯМИ (WATER GOAL) ===
  Widget _buildGoalBottomSheet(ScrollController controller) {
    final accent = AppColors.primary;

    // Фильтрация
    List<GoalTemplate> visibleTemplates = _templates.where((t) {
      final byCat = _category == 'Все' || t.category == _category;
      final byQuery =
          _query.isEmpty || t.title.toLowerCase().contains(_query.toLowerCase());
      return byCat && byQuery;
    }).toList();

    // Сортировка
    visibleTemplates.sort((a, b) {
      switch (_sortMode) {
        case SortMode.popular:
          final pa = _popularity[a.title] ?? 0;
          final pb = _popularity[b.title] ?? 0;
          return pb.compareTo(pa);
        case SortMode.amountAsc:
          return a.glasses.compareTo(b.glasses);
        case SortMode.amountDesc:
          return b.glasses.compareTo(a.glasses);
        case SortMode.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Хэндл
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 6, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Заголовок
          const Text(
            'Выберите цель',
            style: TextStyle(
              fontFamily: 'MinecraftRus',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Мы подготовили много целей для вас!',
            style: TextStyle(
              fontFamily: 'MinecraftRus',
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 12),

          // Поиск + сортировка
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F5F8),
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск целей',
                    hintStyle: const TextStyle(fontFamily: 'MinecraftRus'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<SortMode>(
                tooltip: 'Сортировка',
                onSelected: (m) => setState(() => _sortMode = m),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: SortMode.popular,
                    child: Text('Популярность'),
                  ),
                  PopupMenuItem(
                    value: SortMode.amountAsc,
                    child: Text('Объем ↑'),
                  ),
                  PopupMenuItem(
                    value: SortMode.amountDesc,
                    child: Text('Объем ↓'),
                  ),
                  PopupMenuItem(
                    value: SortMode.nameAsc,
                    child: Text('Название A → Z'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sort),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Категории
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((c) {
                final selected = _category == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c,
                        style: const TextStyle(fontFamily: 'MinecraftRus')),
                    selected: selected,
                    selectedColor: accent.withOpacity(0.15),
                    onSelected: (_) => setState(() => _category = c),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Сетка шаблонов 2xN
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleTemplates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final t = visibleTemplates[i];
              return _TemplateCard(
                title: t.title,
                subtitle: '${t.glasses} стак. • ${t.glasses * waterState.glassSize} мл',
                emoji: t.emoji,
                onTap: () async {
                  final ml = t.glasses * waterState.glassSize;

                  waterState.goalMl = ml;
                  setState(() => _animatedProgress = waterState.consumedMl / ml);

                  try {
                    await _goals.upsert(
                      targetMl: ml,
                      glassSizeMl: waterState.glassSize,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Не удалось сохранить цель')),
                    );
                  }
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Кнопка «Подтвердить» (сохраняем цель, НЕ закрываем экран)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await _goals.upsert(
                    targetMl: waterState.goalMl,
                    enabled: null,
                    everyMin: null,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Цель сохранена ✅')),
                  );
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при сохранении цели')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Подтвердить',
                style: TextStyle(
                  fontFamily: 'MinecraftRus',
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ==== Стакан с волной ====
class _GlassPainter extends CustomPainter {
  final double progress; // 0..1
  final double wavePhase;
  final Color color;
  _GlassPainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topRadiusX = w * 0.42;
    final topRadiusY = w * 0.16;
    final bottomRadiusX = w * 0.26;
    final bottomRadiusY = w * 0.12;

    final glassPath = Path()
      ..moveTo(w / 2 - topRadiusX, topRadiusY)
      ..quadraticBezierTo(0, 0, w / 2, 0)
      ..quadraticBezierTo(w, 0, w / 2 + topRadiusX, topRadiusY)
      ..lineTo(w / 2 + bottomRadiusX, h - bottomRadiusY)
      ..quadraticBezierTo(w / 2 + bottomRadiusX, h, w / 2, h)
      ..quadraticBezierTo(w / 2 - bottomRadiusX, h, w / 2 - bottomRadiusX, h - bottomRadiusY)
      ..lineTo(w / 2 - topRadiusX, topRadiusY)
      ..close();

    canvas.save();
    canvas.clipPath(glassPath);

    final waterTop = h * (1 - progress);
    final waterGradient = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.9), color.withOpacity(0.5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, waterTop, w, h - waterTop));

    final wavePath = Path();
    for (double x = 0; x <= w; x++) {
      final y = 6 * sin((x / w * 2 * pi) + wavePhase) + waterTop;
      if (x == 0) {
        wavePath.moveTo(x, y);
      } else {
        wavePath.lineTo(x, y);
      }
    }
    wavePath.lineTo(w, h);
    wavePath.lineTo(0, h);
    wavePath.close();
    canvas.drawPath(wavePath, waterGradient);

    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.transparent],
        center: const Alignment(-0.3, 0.2),
        radius: 0.7,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), highlight);

    canvas.restore();

    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, topRadiusY),
        width: topRadiusX * 2,
        height: topRadiusY * 2,
      ),
      rimPaint,
    );

    final sideHighlight = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white70, Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(glassPath, sideHighlight);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// ==== Карточка шаблона (как в новой версии) ====
class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'MinecraftRus',
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'MinecraftRus',
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== Экран ручного изменения цели (из старой версии — НЕ трогаем) ====
class SetGoalScreen extends StatefulWidget {
  final int initialGlasses;
  const SetGoalScreen({super.key, required this.initialGlasses});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  late int _glasses;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _glasses = widget.initialGlasses;
    _controller.text = _glasses.toString();
  }

  void _pick(int v) {
    setState(() {
      _glasses = v;
      _controller.text = v.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая цель',
            style: TextStyle(
              fontFamily: 'MinecraftRus',
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Выберите кол-во стаканов (по 250 мл):',
              style: TextStyle(fontFamily: 'MinecraftRus'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [6, 8, 10, 12].map((e) {
                final selected = _glasses == e;
                return ChoiceChip(
                  label:
                      Text('${e}', style: const TextStyle(fontFamily: 'MinecraftRus')),
                  selected: selected,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (_) => _pick(e),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Или введите вручную',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) _glasses = n;
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop<int>(context, _glasses),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Подтвердить',
                    style: TextStyle(
                      fontFamily: 'MinecraftRus',
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

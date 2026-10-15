import 'dart:math';
import 'package:flutter/material.dart';
class Prize {
  final String name;
  final int weight;
  final String type;
  final int value;

  const Prize({
    required this.name,
    required this.weight,
    this.type = 'none',
    this.value = 0,
  });
}
class WheelPainter extends CustomPainter {
  final List<String> labels;
  final List<Color> colors;
  final int selectedIndex;

  WheelPainter({
    required this.labels,
    required this.colors,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 - 4;
    final double anglePerSector = 2 * pi / labels.length;

    final Rect wheelRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    for (int i = 0; i < labels.length; i++) {
      // Первый сектор располагаем по центру верхней части колеса.
      final double startAngle =
          -pi / 2 - anglePerSector / 2 + i * anglePerSector;
      final double midAngle = startAngle + anglePerSector / 2;

      final Color sectorColor = colors[i % colors.length];

      // Рисуем настоящий сектор круга, а не лепесток.
      canvas.drawArc(
        wheelRect,
        startAngle,
        anglePerSector,
        true,
        Paint()
          ..color = sectorColor
          ..style = PaintingStyle.fill,
      );

      // Разделительная линия между секторами.
      final Offset sectorEdge = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );

      canvas.drawLine(
        center,
        sectorEdge,
        Paint()
          ..color = Colors.white.withOpacity(0.75)
          ..strokeWidth = 2,
      );

      // Выбираем контрастный цвет текста.
      final bool darkSector =
          ThemeData.estimateBrightnessForColor(sectorColor) ==
              Brightness.dark;

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: darkSector ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: darkSector ? Colors.black54 : Colors.white70,
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      );

      textPainter.layout(maxWidth: radius * 0.72);

      // Располагаем и поворачиваем текст внутри сектора.
      final double textRadius = radius * 0.62;
      final Offset textPosition = Offset(
        center.dx + textRadius * cos(midAngle),
        center.dy + textRadius * sin(midAngle),
      );

      canvas.save();
      canvas.translate(textPosition.dx, textPosition.dy);

      double textAngle = midAngle;

      // На левой половине переворачиваем текст,
      // чтобы он не отображался вверх ногами.
      if (cos(midAngle) < 0) {
        textAngle += pi;
      }

      canvas.rotate(textAngle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Внешняя рамка делает колесо визуально цельным.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Центральная декоративная кнопка.
    canvas.drawCircle(
      center,
      15,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      center,
      10,
      Paint()..color = Colors.pinkAccent,
    );
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.colors != colors ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class LuckWheel {
  static final Random _random = Random();

  /// Возвращает приз из списка по взвешенному случайному выбору.
  /// Чем больше weight — тем выше шанс выпадения.
  static Prize spin(List<Prize> prizes) {
    int totalWeight = prizes.fold(0, (sum, p) => sum + p.weight);
    if (totalWeight <= 0) return prizes.first;

    int roll = _random.nextInt(totalWeight);
    int cumulative = 0;

    for (final prize in prizes) {
      cumulative += prize.weight;
      if (roll < cumulative) {
        return prize;
      }
    }

    return prizes.last;
  }
}
// ─────────────────────────────────────────────────────────────
// ДОСТИЖЕНИЯ
// Класс Achievement — это одна ачивка: название, история,
// иконка и награда монетами. Условие разблокировки хранится
// отдельно, в методе checkAchievements().
// ─────────────────────────────────────────────────────────────
class Achievement {
  final String id;        // уникальный код, по которому мы её находим
  final String title;     // название, которое видит игрок
  final String story;     // текст-история для карточки
  final IconData icon;    // иконка из набора Material
  final int rewardCoins;  // сколько монет даёт разблокировка

  const Achievement({
    required this.id,
    required this.title,
    required this.story,
    required this.icon,
    required this.rewardCoins,
  });
}

// Полный список достижений. Порядок важен: в checkAchievements
// мы обращаемся к ним по индексу [0], [1] и так далее.
final List<Achievement> achievements = [
  // ── Сюжетное ──
  const Achievement(
    id: 'jackpot_once',
    title: 'Судьба благосклонна',
    story: 'Колесо закрутилось, мир закружился… И вот оно — ЗОЛОТО!',
    icon: Icons.stars,
    rewardCoins: 25,
  ),
  // ── Хардкорные ──
  const Achievement(
    id: 'steal_streak_10',
    title: 'Тень без права на ошибку',
    story: 'Один промах — и всё кончено. Я крала десять раз подряд, '
        'и каждый раз хозяйка даже не поворачивала головы. '
        'Это не везение. Это мастерство.',
    icon: Icons.security,
    rewardCoins: 80,
  ),
  const Achievement(
    id: 'wheel_curse_5',
    title: 'Проклятие колеса',
    story: 'Я крутила и крутила… и снова „Пусто“. Пять раз подряд. '
        'Мир будто издевался. Но я не сдалась. '
        'И именно поэтому это достижение — моё.',
    icon: Icons.circle_outlined,
    rewardCoins: 60,
  ),
  const Achievement(
    id: 'perfect_balance_3',
    title: 'Абсолютный контроль',
    story: 'Голод, энергия, настроение — всё в зелёной зоне. '
        'Три дня подряд я держала баланс идеально. Ни одной ошибки. '
        'Это был не день — это была операция.',
    icon: Icons.monitor_heart,
    rewardCoins: 90,
  ),
  const Achievement(
    id: 'no_spend_level_7',
    title: 'Без единой монеты',
    story: 'Я не тратила монеты. Вообще. Ни на домик, ни на звание, '
        'ни на сундук. Только то, что зарабатывала и воровала. '
        'Чистый путь выживания.',
    icon: Icons.money_off,
    rewardCoins: 120,
  ),
  const Achievement(
    id: 'promo_master',
    title: 'Мастер промокодов',
    story: 'Три промокода — это легко. Но активировать их все '
        'в течение 24 часов после первого входа? '
        'Это уже проверка на внимательность. Я не упустила момент.',
    icon: Icons.code,
    rewardCoins: 70,
  ),
  const Achievement(
    id: 'jackpot_streak_2',
    title: 'Серийный везунчик',
    story: 'Джекпот один раз — удача. Два раза подряд — судьба. '
        'Я поймала эту волну и не отпустила. '
        'Мир дал мне золото — я его взяла.',
    icon: Icons.star,
    rewardCoins: 100,
  ),
  const Achievement(
    id: 'invisible_threat_5',
    title: 'Невидимая угроза',
    story: 'Меня не видели. Не слышали. Не ловили. Пять дней подряд '
        'я воровала еду, и хозяйка ничего не замечала. '
        'Это не просто удача — это искусство быть незаметной.',
    icon: Icons.visibility_off,
    rewardCoins: 85,
  ),
  const Achievement(
    id: 'marathon_50',
    title: 'Бесконечный марафон',
    story: 'Я не останавливалась. 50 вращений колеса за одну сессию. '
        'Руки устали, глаза устали, но стрелка крутилась. '
        'И я видела каждый её поворот.',
    icon: Icons.timer,
    rewardCoins: 110,
  ),
  const Achievement(
    id: 'perfect_day',
    title: 'Идеальный день',
    story: 'День, когда всё сошлось: я украла еду, выиграла на колесе, '
        'подняла настроение питомцу и не была поймана. '
        'Один такой день стоит десяти обычных.',
    icon: Icons.check_circle,
    rewardCoins: 95,
  ),
  const Achievement(
    id: 'legend_no_title',
    title: 'Легенда без титула',
    story: 'Мне не нужна корона, чтобы быть легендой. '
        'Я достигла 10-го уровня без покупки домика '
        'и без звания „принцесса“. Только мои навыки и моя воля.',
    icon: Icons.emoji_events,
    rewardCoins: 150,
  ),
];

void main() {
  runApp(const PetMoodApp());
}

class PetMoodApp extends StatelessWidget {
  const PetMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const PetHomePage(),
    );
  }
}

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
// ─────────────────────────────────────────────────────────────
// СЧЁТЧИКИ ДЛЯ ДОСТИЖЕНИЙ
// Каждый счётчик обслуживает одну конкретную ачивку.
// Слова "consecutive" = "подряд": как только серия прерывается,
// счётчик обнуляем обратно в 0.
// ─────────────────────────────────────────────────────────────

final Set<String> unlockedAchievements = {}; // id уже открытых ачивок

int consecutiveSuccessfulSteals = 0; // серия успешных краж подряд (ачивка 2)
int consecutiveEmptySpins = 0;       // серия "Пусто" на колесе подряд (ачивка 3)
int perfectBalanceDays = 0;          // дни с идеальным балансом подряд (ачивка 4)
bool everSpentCoins = false;         // тратила ли игрок монеты хоть раз (ачивка 5)
int jackpotStreak = 0;               // серия джекпотов подряд (ачивка 7)
int invisibleDays = 0;               // дни кражи без поимки подряд (ачивка 8)
int totalSpinsSession = 0;           // вращений колеса за сессию (ачивка 9)

// Флаги "идеального дня" (ачивка 10). Каждый сбрасывается
// при нажатии "Новый день", поэтому они не требуют Series-логики.
bool perfectDayStoleFood = false;    // успешная кража была в этот день
bool perfectDayWheelWin = false;     // выигрыш на колесе был в этот день
int perfectDayMoodBoosts = 0;        // сколько раз поднимали настроение
bool perfectDayNotCaught = true;     // не была ли поймана за день

  final Random random = Random();
  bool _isSpinning = false;
  String _lastResult = '';
  final List<Color> wheelColors = [
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.orange,
    Colors.amber,
    Colors.red,
    Colors.purple,
  ];

  List<String> get wheelLabels => wheelPrizes.map((p) => p.name).toList();

  // Сектора колеса с весами (чем больше weight, тем реже выпадает)
  final List<Prize> wheelPrizes = [
    const Prize(name: 'Пусто', weight: 15),
    const Prize(name: '+5 монет', weight: 20, type: 'coins', value: 5),
    const Prize(name: '+10 монет', weight: 12, type: 'coins', value: 10),
    const Prize(name: '-1 Энергия', weight: 10, type: 'energy', value: -1),
    const Prize(name: '+2 Настроение', weight: 15, type: 'mood', value: 2),
    const Prize(name: '+1 Энергия', weight: 12, type: 'energy', value: 1),
    const Prize(name: 'Джекпот! +50 монет', weight: 3, type: 'coins', value: 50),
    const Prize(name: 'Голод +2', weight: 13, type: 'hunger', value: 2),
  ];
void showWheelDialog() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WheelScreen(
        prizes: wheelPrizes,
        colors: wheelColors,
        onSpinResult: (prize) {
          setState(() {
            // Счётчик вращений растёт всегда.
            totalSpinsSession++;

            if (prize.type == 'coins' && prize.value >= 50) {
              // Это джекпот: серия растёт.
              jackpotStreak++;
              perfectDayWheelWin = true;
            } else if (prize.type == 'coins') {
              // Обычный выигрыш монет — не джекпот, но и не "Пусто".
              jackpotStreak = 0;
              consecutiveEmptySpins = 0;
            } else {
              // Любой не-денежный приз обнуляет обе серии.
              jackpotStreak = 0;
              consecutiveEmptySpins = 0;
            }
          });

          // Проверяем ачивки после обработки результата.
          checkAchievements();
        },
      ),
    ),
  );
}

void showAchievementsScreen() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок окна.
                const Text(
                  '🏆 Достижения',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),

                const SizedBox(height: 8),

                // Счётчик прогресса: открыто X из Y.
                Text(
                  'Открыто: ${unlockedAchievements.length} из ${achievements.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                // Генерируем карточку для каждого достижения.
                ...achievements.map((a) {
                  final bool unlocked = unlockedAchievements.contains(a.id);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      // Открытая — золотистая, закрытая — серая.
                      color: unlocked ? Colors.amber.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: unlocked ? Colors.orange : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Иконка: для закрытой показываем замок.
                        Icon(
                          unlocked ? a.icon : Icons.lock,
                          size: 40,
                          color: unlocked ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Название скрыто, пока ачивка не открыта.
                              Text(
                                unlocked ? a.title : '???',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unlocked
                                    ? a.story
                                    : 'Достижение пока скрыто…',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Награда: +${a.rewardCoins} монет',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: unlocked
                                      ? Colors.orange
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  
void spinWheel() {
    if (_isSpinning) return;

    final Prize prize = LuckWheel.spin(wheelPrizes);

    setState(() {
      _isSpinning = true;
      _lastResult = '';
    });

    // Применяем приз после "вращения" (3 секунды)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSpinning = false;
        _lastResult = prize.name;

        switch (prize.type) {
          case 'coins':
            coins += prize.value;
            status = 'Колесо удачи: ${prize.name}!';
            break;
          case 'mood':
            mood = min(10, mood + prize.value);
            status = 'Колесо удачи: ${prize.name}!';
            break;
          case 'energy':
            energy = max(0, min(10, energy + prize.value));
            status = 'Колесо удачи: ${prize.name}!';
            break;
          case 'hunger':
            hunger = max(0, min(10, hunger + prize.value));
            status = 'Колесо удачи: ${prize.name}!';
            break;
          default:
            status = 'Колесо удачи: Пусто! Повезёт в следующий раз.';
        }

        checkLevel();
      });
    });
  }

  final List<Map<String,String>> petImages = [
    {
      'name':'Сайки-кот',
      'image':  'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/Caiki-cat.png',
    },
   {
      'name':'Кирара',
      'image':  'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/Kirara.jpg',
    }, 
     {
      'name':'Выдра',
      'image':  'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/Vidra.webp',
    },
     {
      'name':'Пеббл',
      'image':  'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/pebble.jpg',
    }, 
     {
      'name':'Кокоа',
      'image':  'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/Cocoa.webp',
    }
  ];

  String petName = 'Кирара';
  String petImage =
      'https://raw.githubusercontent.com/Mila-Nov/c-chuvochkamu-/main/Kirara.jpg';
  String status = 'Я только проснулась. Что будем делать?';

  int mood = 6;
  int hunger = 4;
  int energy = 7;
  int coins = 0;
  int level = 1;
  bool rnd = false;
  bool house = false;
  int rewardDay = 1;
bool rewardTaken = false;
final TextEditingController promoController = TextEditingController();
  final Set<String>userUsedPromo = {};
final List<Map<String, dynamic>> rewards = [
  {'title': '+10 монет', 'coins': 10, 'icon': Icons.monetization_on},
  {'title': '+15 монет', 'coins': 15, 'icon': Icons.monetization_on},
  {'title': '+2 настроение', 'mood': 2, 'icon': Icons.favorite},
  {'title': '+20 монет', 'coins': 20, 'icon': Icons.card_giftcard},
  {'title': '+3 энергия', 'energy': 3, 'icon': Icons.bolt},
  {'title': '+30 монет', 'coins': 30, 'icon': Icons.redeem},
  {'title': 'Супер приз', 'coins': 100, 'mood': 5, 'icon': Icons.star},
];
  
  void activatePromo() {
  String code = promoController.text.trim().toUpperCase();

  setState(() {
    // Пустое поле ввода — просто напоминаем и выходим.
    if (code.isEmpty) {
      status = 'Введите промокод';
      return;
    }

    // Промокод уже использован — второй раз награду не даём.
    if (userUsedPromo.contains(code)) {
      status = 'Вы уже использовали этот промокод!';
      return;
    }

    bool promoActivated = false; // сработал ли один из трёх кодов
    String promoStatus = '';     // сообщение об успехе

    if (code == 'COOKIE') {
      coins += 30;
      mood = min(10, mood + 2);
      promoStatus = 'Промокод COOKIE принят! +30 монет и настроение +2.';
      userUsedPromo.add(code);
      promoActivated = true;
    } else if (code == 'STAR') {
      coins += 50;
      energy = min(10, energy + 3);
      promoStatus = 'Промокод STAR принят! +50 монет и энергия +3.';
      userUsedPromo.add(code);
      promoActivated = true;
    } else if (code == 'PRINCESS') {
      mood = 10;
      coins += 100;
      promoStatus = 'Секретный промокод PRINCESS! Настроение максимум и +100 монет.';
      userUsedPromo.add(code);
      promoActivated = true;
    } else {
      // Неизвестный код — ничего не начисляем.
      status = 'Такого промокода нет.';
      return;
    }

    if (promoActivated) {
      // Когда открыты все три промокода — сработает "Мастер промокодов".
      // Сама ачивка выдаётся внутри checkAchievements().
      checkAchievements();

      int oldLevel = level;
      checkLevel();

      if (level > oldLevel) {
        status = '$promoStatus Новый уровень: $level!';
      } else {
        status = promoStatus;
      }
    }

    promoController.clear();
  });
}

  void getReward(){
    setState((){
       if(rewardTaken == true){
      status = 'ВЫ УЖЕ ЗАБРАЛИ НАГРАДУ ГРРРРРРВУАЗЦХФЖВЦСФД!!!!!!🤦‍♀️😶‍🌫️🤯😰😵😡';
 return;
    }
      final reward = rewards[rewardDay -1];

    if (reward['coins'] != null ) {
      coins += reward['coins'] as int;
    }
      if (reward['mood'] != null) {
      mood = min(10, mood + (reward['mood'] as int));
    }

    if (reward['energy'] != null) {
      energy = min(10, energy + (reward['energy'] as int));
    }

    rewardTaken = true;
    status = 'Получена награда: ${reward['title']}';

    checkLevel();
    });
   
  }
 void nextRewardDay() {
  setState(() {
    // ── Проверка дневных условий перед сменой дня ──

    // "Абсолютный контроль": статы в норме → серия растёт, иначе сброс.
    if (hunger <= 3 && energy >= 7 && mood >= 7) {
      perfectBalanceDays++;
    } else {
      perfectBalanceDays = 0;
    }

    // "Невидимая угроза": воровала сегодня и не попалась → серия растёт.
    if (perfectDayStoleFood && perfectDayNotCaught) {
      invisibleDays++;
    } else {
      invisibleDays = 0;
    }

    // "Идеальный день": все четыре условия выполнены → ачивка.
    if (perfectDayStoleFood &&
        perfectDayWheelWin &&
        perfectDayMoodBoosts >= 3 &&
        perfectDayNotCaught) {
      hadPerfectDay = true;
    }

    // ── Смена дня ──
    if (rewardDay >= 7) {
      rewardDay = 1;
      status = 'Новая неделя наград началась!';
    } else {
      rewardDay += 1;
      status = 'Наступил день $rewardDay!';
    }

    rewardTaken = false;

    // Сбрасываем дневные флаги — новый день начинается с чистого листа.
    perfectDayStoleFood = false;
    perfectDayWheelWin = false;
    perfectDayMoodBoosts = 0;
    perfectDayNotCaught = true;
  });

  // Проверяем ачивки уже после сброса — чтобы "Идеальный день"
  // успел отметиться до очистки флагов.
  checkAchievements();
}

  Color get backgroundColor {
    if (mood >= 8) return const Color(0xFFFFE4F1);
    if (mood >= 4) return const Color(0xFFE7F4FF);
    return const Color(0xFFFFE8E1);
  }
  String get showPetName {
    if (rnd == true){
      return 'принцесса $petName';
    }
    return petName;
  }
  String get moodText {
    if (mood >= 9) return 'счастье';
    if (mood >= 6) return 'норм';
    if (mood >= 3) return 'грусть';
    return 'обида';
  }
int get chestPrice {
  return level * 5;
}
  void changePet() {
   final pet = petImages[random.nextInt(petImages.length)];
    setState(() {
      petImage = pet['image']!;
      petName = pet['name']!;
      status = 'Теперь у меня новый питомец!';
    });
  }

 int stealAttempts = 0; // счётчик попыток кражи, сбрасывается после успешной покупки

void feedPet() {
  const int foodPrice = 1; // цена еды

  // ── 1. Есть деньги — покупаем еду честно ──
  if (coins >= foodPrice) {
    setState(() {
      coins -= foodPrice;

      // Покупка еды — это трата монет. Запоминаем навсегда:
      // она закрывает путь к ачивкам "Без единой монеты"
      // и "Легенда без титула".
      everSpentCoins = true;

      // Успешная покупка прерывает серию краж.
      consecutiveSuccessfulSteals = 0;

      hunger = max(0, hunger - 3);
      stealAttempts = 0;
      status = '$petName купил(а) еду в магазине. Приятно поел(а)!';
    });
    checkLevel();
    checkAchievements();
    return;
  }

  // ── 2. Красть больше нельзя — лимит попыток исчерпан ──
  if (stealAttempts >= 3) {
    setState(() {
      status = 'Денег на еду нет, а красть больше нельзя — '
          '$petName был(а) пойман(а) слишком много раз. Нужно заработать!';
    });
    return;
  }

  // ── 3. Попытка кражи ──
  // Шанс успеха: 1-я попытка 70%, 2-я 50%, 3-я 30%.
  double successChance = 0.7 - (stealAttempts * 0.2);
  final random = Random();
  bool isSuccess = random.nextDouble() < successChance;

  setState(() {
    stealAttempts++;

    if (isSuccess) {
      // Кража удалась: серия растёт на 1, день отмечается как "воровской".
      consecutiveSuccessfulSteals++;
      perfectDayStoleFood = true;
      perfectDayNotCaught = true; // поимки не было

      hunger = max(0, hunger - 3);
      mood = min(10, mood + 2);
      perfectDayMoodBoosts++; // настроение выросло — учитываем для "Идеального дня"

      status = '$petName ловко стащил(а) еду и никого не поймали! '
          'Голод утолён, настроение поднялось.';
    } else {
      // Кража провалилась: серия мгновенно обнуляется.
      consecutiveSuccessfulSteals = 0;
      perfectDayNotCaught = false; // день уже не "идеальный"

      energy = max(0, energy - 3);
      mood = max(0, mood - 3);
      hunger = min(10, hunger + 1);

      status = '$petName поймали за воровством! Энергия и настроение упали, '
          'а от стресса есть хочется ещё больше.';
    }
  });

  checkLevel();
  checkAchievements();
}



void openChest() {
  setState(() {
    if (level < 2) {
      status = 'Сундук откроется со 2 уровня!';
      return;
    }

    if (coins < chestPrice) {
      status = 'Нужно $chestPrice монеток на сундук.';
      return;
    }

    coins -= chestPrice;
   everSpentCoins = true;
    final prize = random.nextInt(4);

    if (prize == 0) {
      coins += level * 10;
      status = 'В сундуке монеты! +${level * 10}';
    } else if (prize == 1) {
      mood = min(10, mood + 3);
      status = 'В сундуке волшебная конфета! Настроение +3.';
    } else if (prize == 2) {
      energy = min(10, energy + 4);
      status = 'В сундуке энергетик! Энергия +4.';
    } else {
      hunger = max(0, hunger - 3);
      status = 'В сундуке вкусняшка! Голод -3.';
    }

    checkLevel();
  });
checkAchievements();
}
 void playWithPet() {
  setState(() {
    if (energy <= 1) {
      mood = max(0, mood - 1);
      status = '$petName устала. Сначала дай ей поспать.';
    } else {
      energy = max(0, energy - 2);
      hunger = min(10, hunger + 1);
      mood = min(10, mood + 2);
      coins += 2;
      perfectDayMoodBoosts++; // настроение поднялось — для "Идеального дня"
      status = 'Вы поиграли. Весело! +2 монетки.';
    }
    checkLevel();
  });
}


void buyHouse() {
  setState(() {
    if (house == true) {
      status = 'Домик уже куплен!';
    } else if (coins >= 25) {
      coins -= 25;
      house = true;
      everSpentCoins = true; // ← ДОБАВЬ ЭТУ СТРОКУ
      status = '$petName теперь живет в уютном домике!';
    } else {
      status = 'Нужно 25 монеток на домик.';
    }
  });
  checkAchievements(); // ← ДОБАВЬ И ЭТУ: покупка могла открыть ачивку
}

  void sleepPet() {
    setState(() {
     if (house == true){
       energy = min(10,energy + 5);
       status = 'поспала в домике';
     }
      else{
         energy = min(10, energy + 3);
        status = '$petName поспала и стала бодрее.';
      }
     
      hunger = min(10, hunger + 1);
      mood = min(10, mood + 1);
      
    });
  }

  void surprise() {
    final List<String> events = [
      'Нашла блестящую пуговицу. +3 монетки!',
      'Уронила вазу. Настроение -2.',
      'Увидела смешной мем. Настроение +2!',
      'Съела тайный кекс. Голод -3.',
      'Танцевала 10 минут. Энергия -2, монетки +2.',
    ];

    final String event = events[random.nextInt(events.length)];

    setState(() {
      if (event.contains('+3')) coins += 3;
      if (event.contains('Настроение -2')) mood = max(0, mood - 2);
      if (event.contains('Настроение +2')) mood = min(10, mood + 2);
      if (event.contains('Голод -3')) hunger = max(0, hunger - 3);
      if (event.contains('Танцевала')) {
        energy = max(0, energy - 2);
        coins += 2;
      }
      status = event;
      checkLevel();
    });
  }

  void buyBow() {
    setState(() {
      if (rnd == true){
        status = 'вы уже купили это званиие!';
      }
      else if (coins >= 20) { 
        coins -= 20;
        rnd = true;
        everSpentCoins = true;
        mood = min(10, mood + 2);
        status = 'Купили звание. Теперь стиль +100.';
      } else {
        status = 'Нужно 20 монеток. Пока не хватает.';
      }
    });
  checkAchievements();
  }

  void hugPet() {
  setState(() {
    if (energy <= 0) {
      status = '$petName слишком устала для обнимашек.';
    } else {
      energy = max(0, energy - 1);
      mood = min(10, mood + 3);
      perfectDayMoodBoosts++; // объятие = буст настроения
      status = '$petName обняли. Настроение +3!';
    }
    checkLevel();
  });
}


 void checkLevel() {
  if (coins >= level * 8) {
    level += 1;
    mood = min(10, mood + 1);
    status = 'Ура! Новый уровень: $level.';
  }

  // Проверяем ачивки после каждого изменения статов/уровня.
  // Так они не останутся незамеченными, если игрок что-то сделал
  // вне колеса или кражи.
  checkAchievements();
}
// ─────────────────────────────────────────────────────────────
// ПРОВЕРКА ДОСТИЖЕНИЙ
// Вызывается после важных событий: кража, промокод, вращение
// колеса, "Новый день", покупка, смена статов.
// Логика простая: если ачивка ещё не открыта и её условие
// выполнено — добавляем в список разблокировок и начисляем монеты.
// ─────────────────────────────────────────────────────────────
void checkAchievements() {
  final List<Achievement> toUnlock = []; // что открываем прямо сейчас

  // Проверка "уже открыто?"
  bool has(String id) => unlockedAchievements.contains(id);

  // [0] Судьба благосклонна — выиграть джекпот хотя бы раз.
  if (!has('jackpot_once') && jackpotStreak >= 1) {
    toUnlock.add(achievements[0]);
  }

  // [1] Тень без права на ошибку — 10 краж подряд без поимки.
  if (!has('steal_streak_10') && consecutiveSuccessfulSteals >= 10) {
    toUnlock.add(achievements[1]);
  }

  // [2] Проклятие колеса — 5 вращений подряд "Пусто".
  if (!has('wheel_curse_5') && consecutiveEmptySpins >= 5) {
    toUnlock.add(achievements[2]);
  }

  // [3] Абсолютный контроль — 3 дня подряд идеальные статы.
  if (!has('perfect_balance_3') && perfectBalanceDays >= 3) {
    toUnlock.add(achievements[3]);
  }

  // [4] Без единой монеты — уровень 7, ни одной покупки,
  //     значит ни домика, ни звания, ни сундука не куплено.
  if (!has('no_spend_level_7') && level >= 7 && !everSpentCoins) {
    toUnlock.add(achievements[4]);
  }

  // [5] Мастер промокодов — все 3 промокода активированы.
  if (!has('promo_master') && userUsedPromo.length >= 3) {
    toUnlock.add(achievements[5]);
  }

  // [6] Серийный везунчик — 2 джекпота подряд.
  if (!has('jackpot_streak_2') && jackpotStreak >= 2) {
    toUnlock.add(achievements[6]);
  }

  // [7] Невидимая угроза — 5 дней подряд кража без поимки.
  if (!has('invisible_threat_5') && invisibleDays >= 5) {
    toUnlock.add(achievements[7]);
  }

  // [8] Бесконечный марафон — 50 вращений колеса за сессию.
  if (!has('marathon_50') && totalSpinsSession >= 50) {
    toUnlock.add(achievements[8]);
  }

  // [9] Идеальный день — все условия за один игровой день.
  if (!has('perfect_day') &&
      perfectDayStoleFood &&
      perfectDayWheelWin &&
      perfectDayMoodBoosts >= 3 &&
      perfectDayNotCaught) {
    toUnlock.add(achievements[9]);
  }

  // [10] Легенда без титула — уровень 10 без домика и звания.
  if (!has('legend_no_title') && level >= 10 && !house && !rnd) {
    toUnlock.add(achievements[10]);
  }

  // Нечего открывать — выходим без перерисовки экрана.
  if (toUnlock.isEmpty) return;

  setState(() {
    for (final a in toUnlock) {
      unlockedAchievements.add(a.id); // помечаем как открытую
      coins += a.rewardCoins;         // начисляем награду
    }

    // Собираем сообщение со всеми новыми ачивками разом,
    // чтобы не перезаписывать друг друга.
    final names = toUnlock
        .map((a) => '🏆 ${a.title} (+${a.rewardCoins})')
        .join(', ');
    status = 'Открыты достижения: $names';
  });
}

Widget rewardCard(int index) {
  final reward = rewards[index];
  final day = index + 1;

  final bool isPast = day < rewardDay;
  final bool isToday = day == rewardDay;
  final bool isFuture = day > rewardDay;

  Color color = Colors.grey.shade200;

  if (isPast) color = Colors.green.shade100;
  if (isToday) color = Colors.amber.shade100;
  if (isFuture) color = Colors.grey.shade300;

  return Container(
    width: 90,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isToday ? Colors.orange : Colors.transparent,
        width: 3,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'День $day',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Icon(
          reward['icon'] as IconData,
          size: 36,
          color: isFuture ? Colors.grey : Colors.orange,
        ),
        const SizedBox(height: 8),
        Text(
          isFuture ? 'Скоро' : reward['title'],
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
  void showPromoDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Секретный промокод'),
        content: TextField(
          controller: promoController,
          decoration: const InputDecoration(
            hintText: 'Например: COOKIE',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              activatePromo();
            },
            child: const Text('Активировать'),
          ),
        ],
      );
    },
  );
}
  void showRewardCalendar() {
  // showDialog показывает всплывающее окно поверх приложения.
  showDialog(
    // context нужен Flutter, чтобы понять, где именно открыть окно.
    context: context,

    // builder строит то, что будет внутри всплывающего окна.
    builder: (context) {
      // Dialog - само красивое окно.
      return Dialog(
        // shape отвечает за форму окна.
        // Здесь мы делаем скругленные углы.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
child: ConstrainedBox(
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.85,
  ),
  child: SingleChildScrollView(
        // child - содержимое окна.
        child: Padding(
          // Padding добавляет отступы внутри окна,
          // чтобы текст и кнопки не прилипали к краям.
          padding: const EdgeInsets.all(18),

          child: Column(
            // mainAxisSize.min значит:
            // окно будет по высоте ровно под содержимое,
            // а не растянется на весь экран.
            mainAxisSize: MainAxisSize.min,

            // children - все элементы внутри окна сверху вниз.
            children: [
              // Заголовок окна.
              const Text(
                'Календарь наград',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              // Небольшой отступ между заголовком и днем.
              const SizedBox(height: 8),

              // Показываем текущий день награды.
              Text(
                'День $rewardDay из 7',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 18),

              // Wrap раскладывает карточки наград.
              // Если карточки не помещаются в одну строку,
              // они переходят на следующую.
              Wrap(
                spacing: 10, // расстояние между карточками по горизонтали
                runSpacing: 10, // расстояние между строками карточек
                alignment: WrapAlignment.center,

                // List.generate создает 7 карточек.
                // rewardCard - функция, которая рисует одну карточку.
                children: List.generate(7, rewardCard),
              ),

              const SizedBox(height: 20),

              // Кнопка "Забрать".
              ElevatedButton(
                // Если rewardTaken == true, ставим null.
                // onPressed: null выключает кнопку.
                onPressed: rewardTaken
                    ? null
                    : () {
                        // getReward начисляет награду.
                        getReward();

                        // Navigator.pop закрывает окно.
                        Navigator.pop(context);
                      },

                // Стиль кнопки: цвет, текст, размер.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),

                // Текст на кнопке меняется:
                // если награда забрана - "Уже забрано",
                // иначе - "Забрать".
                child: Text(
                  rewardTaken ? 'Уже забрано' : 'Забрать',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              // Кнопка закрытия без получения награды.
              TextButton(
                onPressed: () {
                  // Закрываем окно.
                  Navigator.pop(context);
                },
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      )));
    },
  );
}
  Widget petPicture() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.network(
        petImage,
        height: 220,
        width: 220,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 220,
            width: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            width: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5B8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Картинка\nне загрузилась',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          );
        },
      ),
    );
  }

  Widget statBar(String title, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('$value/10'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: value / 10,
            color: color,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget actionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
@override
void initState() {
  // super.initState() запускает стандартную настройку экрана.
  // Его почти всегда пишут первым внутри initState.
  super.initState();

  // addPostFrameCallback говорит Flutter:
  // "Сначала нарисуй экран, а потом выполни этот код".
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Открываем окно с календарем наград при входе в игру.
    showRewardCalendar();
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Питомец настроения'),
        centerTitle: true,
        backgroundColor: Colors.white70,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    petPicture(),
                    const SizedBox(height: 12),
                    Text(
                      showPetName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Настроение: $moodText',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5B8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Монетки: $coins',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Уровень: $level',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    statBar('Настроение', mood, Colors.pinkAccent),
                    const SizedBox(height: 14),
                    statBar('Голод', hunger, Colors.orangeAccent),
                    const SizedBox(height: 14),
                    statBar('Энергия', energy, Colors.lightBlueAccent),
                  ],
                ),
              ),
              const SizedBox(height: 18),
                            Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  actionButton(
                    'Колесо удачи',
                    Icons.circle,
                    Colors.cyan,
                    showWheelDialog
                  ),
                  actionButton(
  'Награды',
  Icons.calendar_month,
  Colors.amber,
  showRewardCalendar,
),


actionButton(
  'Новый день',
  Icons.next_plan,
  Colors.green,
  nextRewardDay,
),
                  actionButton(
                    'Покормить',
                    Icons.restaurant,
                    Colors.orange,
                    feedPet,
                  ),
                  actionButton(
                    'Играть',
                    Icons.sports_esports,
                    Colors.pinkAccent,
                    playWithPet,
                  ),
                  actionButton(
                    'Спать',
                    Icons.bedtime,
                    Colors.indigo,
                    sleepPet,
                  ),
                  actionButton(
                    'Сюрприз',
                    Icons.casino,
                    Colors.teal,
                    surprise,
                  ),
                  actionButton(
                    'Сменить',
                    Icons.auto_awesome,
                    Colors.purple,
                    changePet,
                  ),
                
                  actionButton(
                    'Обнять',
                    Icons.favorite,
                    Colors.redAccent,
                    hugPet,
                  ),
                  actionButton(
  'Достижения',
  Icons.emoji_events,
  Colors.orange,
  showAchievementsScreen,
),

                  actionButton(
  'Промокод',
  Icons.lock_open,
  Colors.deepPurple,
  showPromoDialog,
),
                ],
              ),
        const SizedBox(height: 18),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Магазин улучшений',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 12),

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
  actionButton(
                    'повысить до принцессы - 20 монет',
                    Icons.shopping_bag,
                    Colors.deepPurple,
                    buyBow,
                  ),
          actionButton(
                    'купить домик - 25 монет',
                    Icons.home,
                    Color(0xffdea387),
                    buyHouse,
                  ),
          actionButton(
  'Сундук $chestPrice',
  Icons.card_giftcard,
  Colors.amber,
  openChest,
),
        ],
      ),
    ],
  ),
),
            
            ],
          ),
        ),
      ),
    );
  }
}

class WheelScreen extends StatefulWidget {
  final List<Prize> prizes;
  final List<Color> colors;

  // Колбэк: сообщает главному экрану, какой приз выпал.
  // Нужен, чтобы счётчики ачивок работали после закрытия экрана колеса.
  final void Function(Prize prize)? onSpinResult;

  const WheelScreen({
    super.key,
    required this.prizes,
    required this.colors,
    this.onSpinResult,
  });
 

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;
  String _lastResult = '';
  int _selectedIndex = 0;
// Хранит текущее положение колеса в оборотах.
// Нужно, чтобы новое вращение продолжалось
// с места предыдущей остановки.
double _currentTurns = 0;

// Хранит анимацию вращения колеса.
// Значение рассчитывается при каждом нажатии кнопки.
late Animation<double> _turnAnimation;
  @override

void initState() {
  // Вызываем стандартную инициализацию StatefulWidget.
  super.initState();

  // Создаём контроллер вращения колеса.
  _controller = AnimationController(
    // Одно вращение длится три секунды.
    duration: const Duration(seconds: 3),

    // vsync отключает ненужную анимацию,
    // когда экран не отображается.
    vsync: this,
  );

  // Устанавливаем начальное положение колеса.
  // Значение 0 означает, что колесо ещё не поворачивалось.
  _turnAnimation = const AlwaysStoppedAnimation(0);
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 void spinWheel() {
  // Не запускаем новое вращение, пока предыдущее не закончилось.
  if (_isSpinning) return;

  // Случайно выбираем приз с учётом значения weight.
  final Prize prize = LuckWheel.spin(widget.prizes);

  // Получаем номер сектора, соответствующего выбранному призу.
  final int selectedIndex = widget.prizes.indexOf(prize);

  // Получаем общее количество секторов колеса.
  final int sectorsCount = widget.prizes.length;

  // Рассчитываем количество секторов,
  // на которое нужно повернуть колесо до выбранного приза.
  final int steps =
      (sectorsCount - selectedIndex) % sectorsCount;

  // Переводим номер нужного сектора в часть полного оборота.
  // Например, при восьми секторах один сектор равен 1 / 8 оборота.
  final double targetFraction = steps / sectorsCount;

  // Получаем текущее положение колеса без учёта полных оборотов.
  final double currentFraction = _currentTurns % 1;

  // Вычисляем дополнительный поворот до выбранного сектора.
  double additionalFraction =
      targetFraction - currentFraction;

  // Если нужный сектор находится позади текущего положения,
  // добавляем ещё один полный оборот.
  if (additionalFraction < 0) {
    additionalFraction += 1;
  }

  // Добавляем шесть полных оборотов для красивой анимации,
  // а затем доворачиваем колесо до выбранного сектора.
  final double targetTurns =
      _currentTurns + 6 + additionalFraction;

  // Возвращаем контроллер анимации в начальное состояние.
  _controller.reset();

  setState(() {
    // Запоминаем, что колесо сейчас вращается.
    // Пока значение true, кнопку нельзя нажать повторно.
    _isSpinning = true;

    // Убираем текст предыдущего результата.
    _lastResult = '';

    // Сохраняем номер выбранного сектора.
    _selectedIndex = selectedIndex;

    // Создаём анимацию от текущего положения колеса
    // до положения выбранного сектора.
    _turnAnimation = Tween<double>(
      // Положение, с которого начинается вращение.
      begin: _currentTurns,

      // Положение, в котором колесо должно остановиться.
      end: targetTurns,
    ).animate(
      CurvedAnimation(
        // Подключаем созданный AnimationController.
        parent: _controller,

        // В начале колесо вращается быстро,
        // а перед остановкой плавно замедляется.
        curve: Curves.easeOutCubic,
      ),
    );
  });

  // Запускаем вращение колеса.
  _controller.forward().whenComplete(() {
    // Если пользователь уже закрыл экран,
    // не пытаемся обновлять его состояние.
    if (!mounted) return;

    setState(() {
      // Запоминаем конечное положение колеса.
      // Следующее вращение начнётся именно с этого места.
      _currentTurns = targetTurns;

      // Сообщаем, что вращение закончилось.
      // После этого кнопку снова можно нажать.
      _isSpinning = false;

      // Показываем название того приза,
      // на котором остановилась стрелка.
      _lastResult = prize.name;
    });
    // Теперь счётчики ачивок обновятся даже после закрытия окна.
  widget.onSpinResult?.call(prize);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Колесо удачи')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Align(
  alignment: Alignment.center,
  child: SizedBox(
    width: 300,
    height: 300,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // RotationTransition должен оборачивать само колесо.
        RotationTransition(
          // Передаём готовую анимацию вращения в виджет колеса.
// Она рассчитывается внутри метода spinWheel().
turns: _turnAnimation,
          child: SizedBox.expand(
            child: CustomPaint(
              painter: WheelPainter(
                labels: widget.prizes.map((p) => p.name).toList(),
                colors: widget.colors,
                selectedIndex: _selectedIndex,
              ),
            ),
          ),
        ),

        // Стрелка остаётся неподвижной, пока колесо вращается.
        const Positioned(
          top: -13,
          child: Icon(
            Icons.arrow_drop_down,
            size: 48,
            color: Colors.red,
          ),
        ),
      ],
    ),
  ),
),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Крутить колесо'),
            onPressed: _isSpinning ? null : spinWheel,
          ),
          if (_lastResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Выпало: $_lastResult',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

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
    final double radius = size.width / 2;
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double anglePerSector = 2 * pi / labels.length;

    for (int i = 0; i < labels.length; i++) {
      final double startAngle = i * anglePerSector;
      final double endAngle = startAngle + anglePerSector;

      paint.color = colors[i % colors.length];
      final Path path = Path()
        ..moveTo(radius, radius)
        ..arcToPoint(
          Offset(
            radius + radius * cos(endAngle),
            radius + radius * sin(endAngle),
          ),
          radius: Radius.circular(radius),
          largeArc: false,
        )
        ..close();
      canvas.drawPath(path, paint);

      final double midAngle = startAngle + anglePerSector / 2;
      final double textRadius = radius * 0.7;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final double textX = radius + textRadius * cos(midAngle) - tp.width / 2;
      final double textY = radius + textRadius * sin(midAngle) - tp.height / 2;
      tp.paint(canvas, Offset(textX, textY));
    }

    // Стрелка
    final Paint arrowPaint = Paint()..color = Colors.red;
    final Path arrow = Path()
      ..moveTo(radius, radius * 0.1)
      ..lineTo(radius - 15, radius * 0.4)
      ..lineTo(radius, radius * 0.1)
      ..lineTo(radius + 15, radius * 0.4)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Колесо удачи', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSpinning)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else if (_lastResult.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _lastResult,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Нажми "Крутить"!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
              actions: [
                if (!_isSpinning)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Закрыть'),
                  ),
                if (!_isSpinning && _lastResult.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      _lastResult = '';
                      spinWheel();
                      setDialogState(() {});
                      // Обновляем диалог через 3 секунды
                      Future.delayed(const Duration(seconds: 3), () {
                        setDialogState(() {});
                      });
                    },
                    child: const Text('Ещё раз'),
                  ),
                if (!_isSpinning && _lastResult.isEmpty)
                  ElevatedButton(
                    onPressed: () {
                      spinWheel();
                      setDialogState(() {});
                      Future.delayed(const Duration(seconds: 3), () {
                        setDialogState(() {});
                      });
                    },
                    child: const Text('Крутить'),
                  ),
              ],
            );
          },
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
  
  void activatePromo(){
    String code = promoController.text.trim().toUpperCase();
    setState((){
      if(code.isEmpty){
        status = 'введите промокод';
        return;
      }
      if(userUsedPromo.contains(code)){
         status = 'ВЫ УЖЕ ИСПОЛЬЗОВАЛИ ЭТОТ ПРОМОКОД!!! ААААААААААААААААААААААААААААААААААААААААА';
         return;
      }
     bool promoActivated = false;
    String promoStatus = '';

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
      status = 'Такого промокода нет.';
      return;
    }

    if (promoActivated) {
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
    if (rewardDay >=7 ) {
      rewardDay = 1 ;
      status = 'Новая неделя наград началась!';
    } else {
      rewardDay += 1;
      status = 'Наступил день $rewardDay!';
    }

    rewardTaken = false;
  });
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
  const int foodPrice = 1; // стоимость еды в магазине

// ── 1. Есть деньги — просто покупаем еду ──
if (coins >= foodPrice) {
  setState(() {
    // Списываем стоимость еды из баланса монет
    coins -= foodPrice;

    // Уменьшаем уровень голода на 3 единицы, но не допускаем отрицательных значений.
    // Функция max(0, ...) гарантирует, что голод не станет меньше 0 — персонаж не может быть «сытее» полного насыщения.
    hunger = max(0, hunger - 3);
      stealAttempts = 0; // сброс счётчика краж после покупки
      status = '$petName купил(а) еду в магазине. Приятно поел(а)!';
    });
    checkLevel();
    return;
  }

  // ── 2. Денег нет — пытаемся украсть (макс. 3 раза) ──
  if (stealAttempts >= 3) {
    setState(() {
      status = 'Денег на еду нет, а красть больше нельзя — $petName был(а) пойман(а) слишком много раз. Нужно заработать!';
    });
    return;
  }

  // ── 3. Попытка кражи ──
  final random = Random();
  // Шанс успеха уменьшается с каждой попыткой: 1-я — 70%, 2-я — 50%, 3-я — 30%
 // Базовый шанс успеха кражи — 70% (0.7).
// За каждую предыдущую попытку (stealAttempts) шанс уменьшается на 20% (0.2).
// Например: при 0 попытках шанс = 0.7, при 1 попытке = 0.5, при 2 попытках = 0.3 и т.д.
double successChance = 0.7 - (stealAttempts * 0.2);

// random.nextDouble() возвращает случайное число в диапазоне [0.0, 1.0) — то есть от 0 включительно до 1 не включительно.
// Мы сравниваем это случайное значение с рассчитанным шансом успеха.
// Если случайное число меньше successChance — условие истинно (кража удалась).
// Это стандартный способ реализовать вероятностное событие: при successChance = 0.7
// примерно в 70% случаев случайное число окажется меньше 0.7.
bool isSuccess = random.nextDouble() < successChance;


  setState(() {
    stealAttempts++;//+1 попытка к краже

    if (isSuccess) {
      // Успешная кража: голод уменьшается, настроение растёт
      hunger = max(0, hunger - 3);
      mood = min(10, mood + 2);
      status = '$petName ловко стащил(а) еду и никого не поймали! Голод утолён, настроение поднялось.';
    } else {
      // Неудачная кража: энергия и настроение падают, голод растёт
      energy = max(0, energy - 3);
      mood = max(0, mood - 3);
      hunger = min(10, hunger + 1);
      status = '$petName поймали за воровством! Энергия и настроение упали, а от стресса есть хочется ещё больше.';
    }
  });

  checkLevel();
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
      status = '$petName теперь живет в уютном домике!';
    } else {
      status = 'Нужно 25 монеток на домик.';
    }
  });
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
        mood = min(10, mood + 2);
        status = 'Купили звание. Теперь стиль +100.';
      } else {
        status = 'Нужно 20 монеток. Пока не хватает.';
      }
    });
  }

  void hugPet() {
    setState(() {
      if (energy <= 0) {
        status = '$petName слишком устала для обнимашек.';
      } else {
        energy = max(0, energy - 1);
        mood = min(10, mood + 3);
        status = '$petName обняли. Настроение +3!';
      }
    });
  }

  void checkLevel() {
    if (coins >= level * 8) {
      level += 1;
      mood = min(10, mood + 1);
      status = 'Ура! Новый уровень: $level.';
    }
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
  const WheelScreen({super.key, required this.prizes, required this.colors});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;
  String _lastResult = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spinWheel() {
    if (_isSpinning) return;
    _controller.reset();
    _controller.forward();
    setState(() => _isSpinning = true);

    final Prize prize = LuckWheel.spin(widget.prizes);

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSpinning = false;
        _lastResult = prize.name;
        _selectedIndex = widget.prizes.indexOf(prize);
      });
      // Здесь добавь логику применения приза (switch case из прошлого ответа)
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
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: WheelPainter(
                  labels: widget.prizes.map((p) => p.name).toList(),
                  colors: widget.colors,
                  selectedIndex: _selectedIndex,
                ),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0, end: 10 + Random().nextDouble()).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  ),
                  child: const SizedBox.shrink(),
                ),
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
              'Выпало: \$_lastResult',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

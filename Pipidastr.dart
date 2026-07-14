import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const PetMoodApp());
}import 'dart:math';
import 'package:flutter/material.dart';

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

final List<Map<String, dynamic>> rewards = [
  {'title': '+10 монет', 'coins': 10, 'icon': Icons.monetization_on},
  {'title': '+15 монет', 'coins': 15, 'icon': Icons.monetization_on},
  {'title': '+2 настроение', 'mood': 2, 'icon': Icons.favorite},
  {'title': '+20 монет', 'coins': 20, 'icon': Icons.card_giftcard},
  {'title': '+3 энергия', 'energy': 3, 'icon': Icons.bolt},
  {'title': '+30 монет', 'coins': 30, 'icon': Icons.redeem},
  {'title': 'Супер приз', 'coins': 100, 'mood': 5, 'icon': Icons.star},
];
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

  void feedPet() {
    setState(() {
      hunger = max(0, hunger - 2);
      mood = min(10, mood + 1);
      coins += 1;
      status = '$petName вкусно поела и получила +1 монетку.';
      checkLevel();
    });
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

//Название, текст, картинка, имя автора



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

final List<Map<String, dynamic>> rewards = [
  {'title': '+10 монет', 'coins': 10, 'icon': Icons.monetization_on},
  {'title': '+15 монет', 'coins': 15, 'icon': Icons.monetization_on},
  {'title': '+2 настроение', 'mood': 2, 'icon': Icons.favorite},
  {'title': '+20 монет', 'coins': 20, 'icon': Icons.card_giftcard},
  {'title': '+3 энергия', 'energy': 3, 'icon': Icons.bolt},
  {'title': '+30 монет', 'coins': 30, 'icon': Icons.redeem},
  {'title': 'Супер приз', 'coins': 100, 'mood': 5, 'icon': Icons.star},
];
  void getReward(){
    if(rewardTaken == true){
      status = 'ВЫ УЖЕ ЗАБРАЛИ НАГРАДУ ГРРРРРРВУАЗЦХФЖВЦСФД!!!!!!🤦‍♀️😶‍🌫️🤯😰😵😡';
 return;
    }
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

  void feedPet() {
    setState(() {
      hunger = max(0, hunger - 2);
      mood = min(10, mood + 1);
      coins += 1;
      status = '$petName вкусно поела и получила +1 монетку.';
      checkLevel();
    });
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

//Название, текст, картинка, имя автора


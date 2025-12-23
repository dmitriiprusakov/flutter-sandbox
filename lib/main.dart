// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:test/pages/my_home_page.dart';
import 'dart:math';

final dayTasks = [
  'Выбить страйк',
  'Закрыть сплит',
  'Выбить «индейку» (3 страйка подряд)',
  'Набрать более 120 очков',
  'Закрыть спейр в первом фрейме',
  'Бросить шар нерабочей рукой',
  'Ни разу не попасть в желоб за игру',
  'Выбить страйк в последнем броске',
];

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = dayTasks[Random().nextInt(dayTasks.length)];
  var history = <String>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = dayTasks[Random().nextInt(dayTasks.length)];
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite([String? task]) {
    task = task ?? current;
    if (favorites.contains(task)) {
      favorites.remove(task);
    } else {
      favorites.add(task);
    }
    notifyListeners();
  }

  void removeFavorite(String task) {
    favorites.remove(task);
    notifyListeners();
  }
}

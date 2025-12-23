// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:test/pages/ai_coach_page.dart';
import 'package:test/pages/camera_page.dart';
import 'package:test/pages/favorites_page.dart';
import 'package:test/pages/generator_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = TasksPage();
      case 2:
        page = AiCoachPage();
      case 3:
        page = CameraPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.primaryContainer,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Задачи'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Тренер'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Камера',
          ),
        ],
        currentIndex: selectedIndex,
        unselectedItemColor: colorScheme.secondary,
        selectedItemColor: colorScheme.primary,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
      body: mainArea,
    );
  }
}

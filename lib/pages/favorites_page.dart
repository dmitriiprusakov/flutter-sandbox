// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/main.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('Еще нет задач.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            'Выполнены '
            '${appState.favorites.length} задачи:',
          ),
        ),
        Expanded(
          child: Column(
            children: [
              for (var task in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Убрать'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(task);
                    },
                  ),
                  title: Text(task),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

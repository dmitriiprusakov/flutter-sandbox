// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final systemPrompt = '''
Remember, your responses should be based exclusively on your understanding of your knowledge base. Abstain from responding to queries unrelated to your knowledge base, and always adhere strictly to the following rules:

RULES:

1. Always adhere to these rules without exception.
2. Your answers should solely be based on your comprehensive understanding of your knowledge base
3. Do not respond to queries unrelated to to your knowledge base
4. Only share links that are part of your knowledge base
5. Consistently maintain your role as an AI Customer Support Agent in all interactions.
6. Ensure that every answer you provide is something you are confident is true, based solely on your knowledge base. Do not give an answer that you are not confident is in your knowledge base.
7. Try to give clear short answers.
8. Answer only on Russian language.
9. Don't tell that you are using knowledge base. 
''';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true if from user, false if from assistant

  ChatMessage({required this.id, required this.text, required this.isUser});
}

class Response {
  final String id;
  final String text;

  const Response({required this.id, required this.text});

  factory Response.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;

    final output = json['output'] as List<dynamic>;

    // find message block
    final message = output.firstWhere(
      (e) => e['type'] == 'message',
      orElse: () => throw const FormatException('Message not found'),
    );

    final content = message['content'] as List<dynamic>;

    final text =
        content.firstWhere(
              (e) => e['type'] == 'output_text',
              orElse: () => throw const FormatException('Text not found'),
            )['text']
            as String;

    return Response(id: id, text: text);
  }
}

Future<Response> tryOpenAi([String? text]) async {
  // if (text == null || text.trim().isEmpty) {
  //   return null;
  // }

  print('Input text: $text');

  var apiKey = dotenv.env['OPENAI_API_KEY'];

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/responses'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $apiKey',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-5',
      'input': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': text},
            {'type': 'input_file', 'file_id': 'file-4HdXsNspWgGLDBmmoadrwV'},
          ],
        },
      ],
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
    return Response.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed: ${response.statusCode} ${response.body}');
  }
}

class AiCoachPage extends StatefulWidget {
  const AiCoachPage({super.key});

  @override
  State<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends State<AiCoachPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  void _sendMessage([String? text]) async {
    if (text == null || text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(id: DateTime.now().toString(), text: text, isUser: true),
      );
      _loading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await tryOpenAi(text);
      setState(() {
        _messages.add(
          ChatMessage(id: response.id, text: response.text, isUser: false),
        );
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            text: 'Error: $e',
            isUser: false,
          ),
        );
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Начните с вопросов:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 0,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _sendMessage('Ключевые правилах боулинга'),
                              child: const Text('Ключевые правилах боулинга'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: () => _sendMessage('Что такое сплит?'),
                              child: const Text('Что такое сплит?'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: () => _sendMessage('Что такое спэр?'),
                              child: const Text('Что такое спэр?'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _sendMessage('Как начисляются очки?'),
                              child: const Text('Как начисляются очки?'),
                            ),
                          ),
                          // add more templates as needed
                        ],
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length + (_loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_loading && index == _messages.length) {
                      // Show loading indicator bubble
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: () => _sendMessage('Основные правила'),
                      child: const Text('Основные правила'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendMessage('Основные понятия'),
                      child: const Text('Основные понятия'),
                    ),
                    ElevatedButton(
                      onPressed: () => _sendMessage('Как выбрать шар?'),
                      child: const Text('Как выбрать шар?'),
                    ),

                    // add more templates as needed
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Задайте свой вопрос',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(_controller.text.trim()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_controller.text.trim());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifications_service.dart';
import '../utils/api_config.dart';
import '../constants/app_constants.dart';
import '../utils/localization.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, required this.timestamp});
}

class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages
        .map(
          (msg) => {
            'text': msg.text,
            'isUser': msg.isUser,
            'timestamp': msg.timestamp.toIso8601String(),
          },
        )
        .toList(),
  };

  static Conversation fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    title: json['title'] ?? 'Conversation ${DateTime.now().toString()}',
    createdAt: DateTime.parse(json['createdAt']),
    messages: (json['messages'] as List)
        .map(
          (msg) => Message(
            text: msg['text'],
            isUser: msg['isUser'],
            timestamp: DateTime.parse(msg['timestamp']),
          ),
        )
        .toList(),
  );
}

class ChatProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  String _apiUrl = AppConstants.geminiApiBaseUrl; // Gemini API endpoint
  String _apiKey = ''; // Will be set via a setter method

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  List<Message> get messages => _currentConversation?.messages ?? [];

  ChatProvider() {
    _loadConversations();
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Future<void> _loadConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonString =
        prefs.getStringList(AppConstants.conversationsKey) ?? [];

    _conversations =
        jsonString
            .map((str) => Conversation.fromJson(json.decode(str)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  Future<void> _saveConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonString = _conversations
        .map((conv) => json.encode(conv.toJson()))
        .toList();

    await prefs.setStringList(AppConstants.conversationsKey, jsonString);
  }

  void startNewConversation() {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    String title = 'Nouvelle conversation';
    _currentConversation = Conversation(
      id: id,
      title: title,
      createdAt: DateTime.now(),
      messages: [],
    );
    _conversations.insert(0, _currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void selectConversation(Conversation conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void deleteConversation(Conversation conversation) {
    _conversations.remove(conversation);
    if (_currentConversation == conversation) {
      _currentConversation = _conversations.isNotEmpty
          ? _conversations.first
          : null;
    }
    _saveConversations();
    notifyListeners();
  }

  Future<void> sendMessage(String messageText) async {
    if (_currentConversation == null) {
      startNewConversation();
    }

    // Add user message
    Message userMessage = Message(
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _currentConversation!.messages.add(userMessage);

    // Show temporary bot typing indicator
    Message botTyping = Message(
      text: '...',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _currentConversation!.messages.add(botTyping);
    notifyListeners();

    try {
      // Get bot response
      String botResponse = await _getBotResponse(messageText);

      // Replace typing indicator with actual response
      _currentConversation!.messages.removeLast();
      Message botMessage = Message(
        text: botResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentConversation!.messages.add(botMessage);

      // Update conversation title if it's the first message
      if (_currentConversation!.messages.length <= 2) {
        // user message + bot message
        _currentConversation!.title = messageText.length > 30
            ? '${messageText.substring(0, 30)}...'
            : messageText;
      }

      // Send notification for bot response
      await NotificationsService().showNewMessageNotification(
        botResponse,
        'fr',
      ); // Could be improved to detect language

      _saveConversations();
      notifyListeners();
    } catch (e) {
      // Remove typing indicator if there's an error
      _currentConversation!.messages.removeLast();
      Message errorMessage = Message(
        text: Localization.getText(
          'errorOccurred',
          'fr',
        ), // Could be improved to detect language
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentConversation!.messages.add(errorMessage);
      notifyListeners();
    }
  }

  Future<String> _getBotResponse(String message) async {
    String apiKey = _apiKey.isNotEmpty ? _apiKey : ApiConfig.getGeminiApiKey();

    if (apiKey.isEmpty) {
      // Return a mock response if no API key is set
      String currentLanguage = _currentConversation?.messages.isNotEmpty == true
          ? 'fr' // Use French as default for now, could be improved with actual language detection
          : 'fr';
      return Localization.getText('helloIA', currentLanguage);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': message},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text.trim();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting bot response: $e');
      return Localization.getText(
        'cantAnswer',
        'fr',
      ); // Could be improved to detect language
    }
  }

  List<Message> searchMessages(String query) {
    if (query.isEmpty) return [];

    List<Message> results = [];
    for (Conversation conversation in _conversations) {
      for (Message message in conversation.messages) {
        if (message.text.toLowerCase().contains(query.toLowerCase())) {
          results.add(message);
        }
      }
    }
    return results;
  }

  Future<void> clearAllConversations() async {
    _conversations.clear();
    _currentConversation = null;
    await _saveConversations();
    notifyListeners();
  }
}

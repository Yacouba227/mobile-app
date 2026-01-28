class Localization {
  static Map<String, Map<String, String>> _translations = {
    'fr': {
      'appName': 'ChatBot IA',
      'newConversation': 'Nouvelle conversation',
      'noConversations':
          'Aucune conversation\nCommencez une nouvelle discussion',
      'chat': 'Chat',
      'typeMessage': 'Tapez votre message...',
      'settings': 'Paramètres',
      'theme': 'Thème',
      'language': 'Langue',
      'toneStyle': 'Style de réponse',
      'accessibility': 'Accessibilité',
      'about': 'À propos',
      'light': 'Clair',
      'dark': 'Sombre',
      'french': 'Français',
      'english': 'English',
      'friendly': 'Amical',
      'formal': 'Formel',
      'casual': 'Décontracté',
      'increaseTextSize': 'Augmenter la taille du texte',
      'betterVisibility': 'Pour une meilleure lisibilité',
      'highContrast': 'Contraste élevé',
      'elementVisibility': 'Meilleure visibilité des éléments',
      'version': 'Version',
      'chatApp': 'Application ChatBot IA',
      'advancedAI': 'Une application de discussion avec une IA avancée',
      'helloIA':
          'Bonjour ! Je suis votre assistant IA. Comment puis-je vous aider aujourd\'hui ?',
      'errorOccurred': 'Désolé, une erreur est survenue. Veuillez réessayer.',
      'cantAnswer':
          'Désolé, je ne peux pas répondre à cette question actuellement.',
      'newMessage': 'Nouveau message',
      'reminder': 'Rappel',
      'messages': 'messages',
      'now': 'Maintenant',
      'today': 'Aujourd\'hui',
      'yesterday': 'Hier',
    },
    'en': {
      'appName': 'ChatBot AI',
      'newConversation': 'New conversation',
      'noConversations': 'No conversations\nStart a new discussion',
      'chat': 'Chat',
      'typeMessage': 'Type your message...',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'toneStyle': 'Response style',
      'accessibility': 'Accessibility',
      'about': 'About',
      'light': 'Light',
      'dark': 'Dark',
      'french': 'Français',
      'english': 'English',
      'friendly': 'Friendly',
      'formal': 'Formal',
      'casual': 'Casual',
      'increaseTextSize': 'Increase text size',
      'betterVisibility': 'For better readability',
      'highContrast': 'High contrast',
      'elementVisibility': 'Better visibility of elements',
      'version': 'Version',
      'chatApp': 'ChatBot AI Application',
      'advancedAI': 'A chat application with advanced AI',
      'helloIA': 'Hello! I am your AI assistant. How can I help you today?',
      'errorOccurred': 'Sorry, an error occurred. Please try again.',
      'cantAnswer': 'Sorry, I cannot answer this question at the moment.',
      'newMessage': 'New message',
      'reminder': 'Reminder',
      'messages': 'messages',
      'now': 'Now',
      'today': 'Today',
      'yesterday': 'Yesterday',
    },
  };

  static String getText(String key, String language) {
    if (_translations.containsKey(language)) {
      if (_translations[language]!.containsKey(key)) {
        return _translations[language]![key]!;
      }
    }

    // Fallback to French if key not found in requested language
    if (_translations['fr']!.containsKey(key)) {
      return _translations['fr']![key]!;
    }

    // Return the key as fallback
    return key;
  }
}

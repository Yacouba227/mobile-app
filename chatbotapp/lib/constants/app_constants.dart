class AppConstants {
  // App name
  static const String appName = 'ChatBot IA';

  // API endpoints
  static const String geminiApiBaseUrl = ''
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Shared preferences keys
  static const String darkThemeKey = 'darkTheme';
  static const String languageKey = 'language';
  static const String toneStyleKey = 'toneStyle';
  static const String conversationsKey = 'conversations';
  static const String apiKeyKey = 'apiKey';

  // Supported languages
  static const List<String> supportedLanguages = ['fr', 'en'];

  // Tone styles
  static const List<String> toneStyles = ['friendly', 'formal', 'casual'];

  // Default settings
  static const bool defaultDarkTheme = false;
  static const String defaultLanguage = 'fr';
  static const String defaultToneStyle = 'friendly';
}

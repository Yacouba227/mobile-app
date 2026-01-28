import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = AppConstants.defaultDarkTheme;
  String _language = AppConstants.defaultLanguage; // Default to French
  String _toneStyle =
      AppConstants.defaultToneStyle; // Default tone: friendly, formal, casual

  bool get isDarkTheme => _isDarkTheme;
  String get language => _language;
  String get toneStyle => _toneStyle;

  ThemeData get themeData {
    return _isDarkTheme
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            scaffoldBackgroundColor: Colors.grey[50],
            cardColor: Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
          );
  }

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme =
        prefs.getBool(AppConstants.darkThemeKey) ??
        AppConstants.defaultDarkTheme;
    _language =
        prefs.getString(AppConstants.languageKey) ??
        AppConstants.defaultLanguage;
    _toneStyle =
        prefs.getString(AppConstants.toneStyleKey) ??
        AppConstants.defaultToneStyle;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.darkThemeKey, _isDarkTheme);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, language);
    notifyListeners();
  }

  Future<void> setToneStyle(String toneStyle) async {
    _toneStyle = toneStyle;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.toneStyleKey, toneStyle);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Notification settings
  bool _notificationsEnabled = true;
  bool _notificationSoundEnabled = true;
  
  // Data management
  List<String> _recentSearches = [];
  Map<String, dynamic> _statistics = {};
  
  // Security settings
  bool _biometricLockEnabled = false;
  
  // Accessibility settings
  bool _largeTextEnabled = false;
  bool _highContrastEnabled = false;
  bool _readingModeEnabled = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationSoundEnabled => _notificationSoundEnabled;
  List<String> get recentSearches => _recentSearches;
  Map<String, dynamic> get statistics => _statistics;
  bool get biometricLockEnabled => _biometricLockEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get readingModeEnabled => _readingModeEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load notification settings
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _notificationSoundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
    
    // Load recent searches
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    
    // Load statistics
    String? statsString = prefs.getString('statistics');
    if (statsString != null) {
      // In a real app, you'd parse JSON here
      _statistics = {
        'total_conversations': prefs.getInt('total_conversations') ?? 0,
        'total_messages': prefs.getInt('total_messages') ?? 0,
        'last_active': prefs.getString('last_active') ?? '',
      };
    }
    
    // Load security settings
    _biometricLockEnabled = prefs.getBool('biometric_lock_enabled') ?? false;
    
    // Load accessibility settings
    _largeTextEnabled = prefs.getBool('large_text_enabled') ?? false;
    _highContrastEnabled = prefs.getBool('high_contrast_enabled') ?? false;
    _readingModeEnabled = prefs.getBool('reading_mode_enabled') ?? false;
    
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Save notification settings
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('notification_sound_enabled', _notificationSoundEnabled);
    
    // Save recent searches
    await prefs.setStringList('recent_searches', _recentSearches);
    
    // Save statistics
    await prefs.setInt('total_conversations', _statistics['total_conversations'] ?? 0);
    await prefs.setInt('total_messages', _statistics['total_messages'] ?? 0);
    await prefs.setString('last_active', _statistics['last_active'] ?? '');
    
    // Save security settings
    await prefs.setBool('biometric_lock_enabled', _biometricLockEnabled);
    
    // Save accessibility settings
    await prefs.setBool('large_text_enabled', _largeTextEnabled);
    await prefs.setBool('high_contrast_enabled', _highContrastEnabled);
    await prefs.setBool('reading_mode_enabled', _readingModeEnabled);
  }

  // Notification methods
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleNotificationSound(bool value) async {
    _notificationSoundEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  // Recent searches methods
  Future<void> addRecentSearch(String searchTerm) async {
    if (!_recentSearches.contains(searchTerm)) {
      _recentSearches.insert(0, searchTerm);
      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    await _saveSettings();
    notifyListeners();
  }

  // Statistics methods
  Future<void> updateStatistics({
    int? totalConversations,
    int? totalMessages,
    String? lastActive,
  }) async {
    if (totalConversations != null) {
      _statistics['total_conversations'] = totalConversations;
    }
    if (totalMessages != null) {
      _statistics['total_messages'] = totalMessages;
    }
    if (lastActive != null) {
      _statistics['last_active'] = lastActive;
    }
    await _saveSettings();
    notifyListeners();
  }

  // Security methods
  Future<void> toggleBiometricLock(bool value) async {
    _biometricLockEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  // Accessibility methods
  Future<void> toggleLargeText(bool value) async {
    _largeTextEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool value) async {
    _highContrastEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleReadingMode(bool value) async {
    _readingModeEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  // Data export method (placeholder)
  Future<String> exportData() async {
    // In a real implementation, this would export to a file
    return 'Export functionality would save data to a file here';
  }

  // Data clear method
  Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadSettings(); // Reload default values
  }
}
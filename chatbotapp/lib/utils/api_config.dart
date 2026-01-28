class ApiConfig {
  // Default API key placeholder - users will need to set their own
  static String geminiApiKey = '';

  // Set the API key
  static void setGeminiApiKey(String key) {
    geminiApiKey = key;
  }

  // Get the API key
  static String getGeminiApiKey() {
    return geminiApiKey;
  }
}

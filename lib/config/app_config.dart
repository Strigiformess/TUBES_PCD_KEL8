// config/app_config.dart
// Configuration helper untuk environment variables

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://localhost:3000/api');
  static int get apiTimeout =>
      int.parse(dotenv.get('API_TIMEOUT', fallback: '30'));

  // MongoDB Configuration
  static String get mongoUri => dotenv.get('MONGODB_URI',
      fallback: 'mongodb://localhost:27017/freshcheck');

  // Feature Flags
  static bool get enableBackendSync =>
      dotenv.get('ENABLE_BACKEND_SYNC', fallback: 'true') == 'true';
  static bool get enablePcdFeatures =>
      dotenv.get('ENABLE_PCD_FEATURES', fallback: 'true') == 'true';

  // Debug Settings
  static bool get debugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'false') == 'true';
  static String get logLevel => dotenv.get('LOG_LEVEL', fallback: 'info');

  // App Configuration
  static int get maxRetryCount =>
      int.parse(dotenv.get('MAX_RETRY_COUNT', fallback: '3'));
  static int get syncIntervalMinutes =>
      int.parse(dotenv.get('SYNC_INTERVAL_MINUTES', fallback: '15'));

  /// Load environment variables
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file not found, use fallback values
      print('Warning: .env file not found, using default values');
    }
  }

  /// Print current configuration (untuk debugging)
  static void printConfig() {
    if (!debugMode) return;

    print('=== App Configuration ===');
    print('API Base URL: $apiBaseUrl');
    print('API Timeout: ${apiTimeout}s');
    print('Backend Sync: $enableBackendSync');
    print('PCD Features: $enablePcdFeatures');
    print('Debug Mode: $debugMode');
    print('Max Retry: $maxRetryCount');
    print('Sync Interval: ${syncIntervalMinutes}m');
    print('========================');
  }
}

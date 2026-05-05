import 'dart:io';

class ApiConfig {
  /// Change this to switch between environments:
  /// - 'local': localhost:8080 (for web/desktop testing)
  /// - 'emulator': 10.0.2.2:8080 (for Android emulator)
  /// - 'physical': your_ip:8080 (for physical phone on same network)
  /// - 'custom': set customBaseUrl below
  static const String environment = 'custom'; // Change this

  /// If environment is 'custom', set your backend URL here
  /// Examples:
  /// - http://192.168.2.2:5000 (physical phone on local network)
  /// - http://10.0.2.2:8080 (Android emulator)
  /// - http://localhost:8080 (web/desktop)
  static const String customBaseUrl = 'http://192.168.2.2:5000';

  static String getBaseUrl() {
    switch (environment) {
      case 'local':
        return 'http://localhost:8080';
      case 'emulator':
        // Android emulator special IP for host machine
        return 'http://10.0.2.2:8080';
      case 'physical':
        // Physical device - update this IP to match your laptop's IP
        return 'http://192.168.2.2:5000';
      case 'custom':
        return customBaseUrl;
      default:
        return 'http://localhost:8080';
    }
  }

  /// Helper to get the appropriate URL for current platform
  static String getSmartBaseUrl() {
    if (environment != 'local') {
      return getBaseUrl();
    }

    // If environment is 'local', detect platform
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // iOS simulator
    } else {
      return 'http://localhost:8080'; // Web/Desktop
    }
  }
}

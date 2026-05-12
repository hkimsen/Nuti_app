import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Change this to switch between environments:
  /// - 'local-web': localhost:5000 (for web testing locally)
  /// - 'emulator': 10.0.2.2:5000 (for Android emulator)
  /// - 'physical': 192.168.2.2:5000 (for physical phone on same network)
  static const String environment = 'local-web'; // Change this based on testing platform

  /// Laptop IP for network testing (change if your IP is different)
  static const String laptopIp = '192.168.2.2';

  static String getBaseUrl() {
    switch (environment) {
      case 'local-web':
        // Web browser on localhost
        return 'http://localhost:5000';
      case 'emulator':
        // Android emulator special IP for host machine
        return 'http://10.0.2.2:5000';
      case 'physical':
        // Physical device - uses laptop IP on same network
        return 'http://$laptopIp:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  /// Helper to get the appropriate URL for current platform
  static String getSmartBaseUrl() {
    if (kIsWeb) {
      // Running on web
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Android (physical or emulator)
      return 'http://10.0.2.2:5000'; // Emulator special IP
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:5000';
    } else {
      // Desktop
      return 'http://localhost:5000';
    }
  }
}

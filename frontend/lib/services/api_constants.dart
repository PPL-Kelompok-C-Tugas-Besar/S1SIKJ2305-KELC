import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Otomatis sesuaikan URL berdasarkan platform:
  //   Web (Chrome/Edge)   → localhost:3000
  //   Android Emulator    → 10.0.2.2:3000
  //   Physical Device     → ganti dengan IP WiFi komputer
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Android emulator → host machine
    return 'http://10.0.2.2:3000';
  }

  static String get register => '$baseUrl/auth/register';
  static String get login    => '$baseUrl/auth/login';
  static String get profile  => '$baseUrl/users/profile';
  static String get history  => '$baseUrl/users/history';
}
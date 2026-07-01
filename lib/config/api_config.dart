import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // URL para web
    if (kIsWeb) {
      return 'https://api-4upet.onrender.com/api/v1';
    }
    // URL para emulador Android
    return 'http://10.0.2.2:3000/api/v1';
  }
}

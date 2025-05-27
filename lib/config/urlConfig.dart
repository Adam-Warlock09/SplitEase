import 'package:flutter/foundation.dart';

class AppConfig {

  static String get baseUrl {

    if (kReleaseMode) {
      return 'https://splitease-backend-llwa.onrender.com';
    } else {
      return 'http://localhost:8080';
    }

  }

}

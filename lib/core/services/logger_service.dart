import 'package:flutter/foundation.dart';

class LoggerService {
  void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

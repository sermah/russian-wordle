import 'dart:io';

import 'package:flutter/services.dart';

class Vibration {
  static tap() {
    HapticFeedback.lightImpact();
  }

  static fail() async {
    HapticFeedback.mediumImpact();
    sleep(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }
}
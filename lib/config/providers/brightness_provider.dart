// lib/config/providers/brightness_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrightnessProvider with ChangeNotifier {
  double _brightness = 1.0; // Mặc định là 1.0 (sáng nhất), 0.0 là tối nhất

  double get brightness => _brightness;

  BrightnessProvider() {
    _loadBrightness();
  }

  Future<void> _loadBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    _brightness = prefs.getDouble('app_brightness') ?? 1.0;
    notifyListeners();
  }

  Future<void> setBrightness(double newBrightness) async {
    _brightness = newBrightness.clamp(0.1, 1.0); // Giới hạn từ 0.1 đến 1.0
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('app_brightness', _brightness);
  }
}


// lib/core/providers/text_size_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextSizeProvider with ChangeNotifier {
  double _textScaleFactor = 1.0; // Mặc định là 1.0 (kích thước gốc)

  double get textScaleFactor => _textScaleFactor;

  TextSizeProvider() {
    _loadTextSize();
  }

  Future<void> _loadTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    _textScaleFactor = prefs.getDouble('text_size') ?? 1.0; // Lấy từ key đã lưu
    notifyListeners();
  }

  Future<void> setTextSize(double newSize) async {
    _textScaleFactor = newSize;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_size', newSize); // Lưu vào SharedPreferences
  }
}

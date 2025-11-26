// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_connect/config/services/biometric_auth_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Mặc định là theo hệ thống
  bool _biometricEnabled = false;
  final BiometricAuthService _biometricService = BiometricAuthService();

  ThemeMode get themeMode => _themeMode;
  bool get biometricEnabled => _biometricEnabled;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Cập nhật tên hàm
    final prefs = await SharedPreferences.getInstance();
    // Load theme mode
    final isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Load biometric setting từ service
    _biometricEnabled = await _biometricService.isBiometricEnabled();

    notifyListeners(); // Thông báo cho widget đang lắng nghe
  }

  Future<void> toggleTheme(bool enableDarkMode) async {
    _themeMode = enableDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', enableDarkMode);
  }

  Future<void> toggleBiometric(bool enable) async {
    _biometricEnabled = enable;
    await _biometricService.setBiometricEnabled(enable);
    notifyListeners();
  }
}

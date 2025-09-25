import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 🌞 Light Theme
  static ThemeData lightTheme = ThemeData(
    // 🎨 Màu chính (Primary color) – dùng cho AppBar, button, icon chính
    primaryColor: const Color(0xFF1E88E5),

    // 🎨 Bộ màu tổng thể (ColorScheme) – Flutter dùng cho toàn bộ UI
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      primary: const Color(0xFF1E88E5), // 🔵 màu chính (button, appbar, focus)
      secondary: const Color(0xFF42A5F5), // 🟦 màu phụ (accent, icon nhỏ)
    ).copyWith(
      background: const Color(0xFFF8F9FA), // 🎨 màu nền chính (scaffold)
      surface: Colors.white, // 🎨 màu nền bề mặt (Card, Dialog)
      onBackground: const Color(0xFF333333), // 🎨 màu chữ trên nền chính
      onSurface: const Color(0xFF333333), // 🎨 màu chữ trên card, dialog
      error: Colors.redAccent, // ❌ màu lỗi
    ),

    // 🎨 Màu nền của Scaffold (màn hình chính)
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),

    // 📝 Font chữ toàn app
    fontFamily: 'Roboto',

    // 🎨 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // màu nền appbar
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF333333)), // màu icon trong appbar
      titleTextStyle: TextStyle(
        color: Color(0xFF333333), // màu chữ title appbar
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // status bar trong suốt
        statusBarIconBrightness: Brightness.dark, // icon status bar màu đen
      ),
    ),

    // 🔘 ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5), // nền button
        foregroundColor: Colors.white, // chữ & icon trên button
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // bo góc button
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    // 🔘 TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1E88E5), // màu chữ button text
      ),
    ),

    // 📝 Text Theme (tất cả text trong app)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)), // tiêu đề lớn
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)), // tiêu đề trung
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)), // title AppBar
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333)), // subtitle
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF555555)), // nội dung chính
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF555555)), // nội dung phụ
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)), // label form, nút
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey), // text nhỏ
    ),

    // 📦 Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1), // viền mờ
      ),
    ),

    // 📝 Input (TextField, Form)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // nền textfield
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1), // viền khi enable
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1), // viền khi focus
      ),
      hintStyle: TextStyle(color: Colors.grey[400]), // màu chữ gợi ý (hint)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1), // viền khi có lỗi
      ),
    ),

    // ➖ Divider
    dividerTheme: DividerThemeData(
      color: Colors.grey.withOpacity(0.1), // màu gạch ngăn
      thickness: 1,
      space: 40,
    ),
  );

  // 🌚 Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    primaryColor: const Color(0xFF42A5F5), // màu chính
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
      primary: const Color(0xFF42A5F5), // 🔵 button, icon chính
      secondary: const Color(0xFF90CAF9), // 🟦 accent
    ).copyWith(
      background: const Color(0xFF121212), // nền chính
      surface: const Color(0xFF1E1E1E), // card, dialog
      onBackground: Colors.white, // chữ trên nền
      onSurface: Colors.white, // chữ trên card
      error: const Color(0xFFCF6679), // ❌ lỗi
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // icon status bar màu trắng
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42A5F5), // nền button
        foregroundColor: Colors.white, // chữ button
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF42A5F5)),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C), // nền textfield
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]), // hint màu xám
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
      space: 40,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Giao diện sáng (Light Theme)
  static ThemeData lightTheme = ThemeData(
    // Màu chủ đạo (dùng cho AppBar, button, icon chính)
    primaryColor: const Color(0xFF1E88E5),

    // Bộ màu tổng thể dùng xuyên suốt UI
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      primary: const Color(0xFF1E88E5),
      secondary: const Color(0xFF42A5F5),
    ).copyWith(
      // background: const Color(0xFFF8F9FA),
      surface: Colors.white,
      // onBackground: const Color(0xFF333333),
      onSurface: const Color(0xFF333333),
      error: Colors.redAccent,
    ),

    // Nền của Scaffold (toàn màn hình)
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),

    // Font mặc định
    fontFamily: 'Roboto',

    // AppBar: thanh tiêu đề trên cùng
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF333333)), // Icon trong AppBar
      titleTextStyle: TextStyle(
        color: Color(0xFF333333),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // IconTheme: áp dụng cho toàn bộ icon trong app (trừ AppBar)
    iconTheme: const IconThemeData(
      color: Color(0xFF333333), // Màu icon mặc định
      size: 24, // Kích thước icon mặc định
    ),

    // PrimaryIconTheme: icon trong vùng có primaryColor (ví dụ FloatingActionButton)
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    // Nút có nền (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    // Nút chỉ có chữ (TextButton)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1E88E5),
      ),
    ),

    // Kiểu chữ
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF555555)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF555555)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    ),

    // Card: dùng cho các khối nội dung (ví dụ sản phẩm, bài viết)
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
    ),

    // TextField, Form
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1),
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    ),

    // Divider: đường ngăn giữa các phần
    dividerTheme: DividerThemeData(
      color: Colors.grey.withValues(alpha: 0.1),
      thickness: 1,
      space: 40,
    ),

    // BottomNavigationBar: thanh điều hướng dưới cùng
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1E88E5),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Giao diện tối (Dark Theme)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    // Màu chủ đạo
    primaryColor: const Color(0xFF42A5F5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
      primary: const Color(0xFF42A5F5),
      secondary: const Color(0xFF90CAF9),
    ).copyWith(
      // background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      // onBackground: Colors.white,
      onSurface: Colors.white,
      error: const Color(0xFFCF6679),
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),

    fontFamily: 'Roboto',

    // AppBar tối
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // Icon mặc định
    iconTheme: const IconThemeData(
      color: Colors.white70,
      size: 24,
    ),

    // Icon trên vùng màu chính (ví dụ FAB)
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    // Nút có nền
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    // Nút chỉ có chữ
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF42A5F5)),
    ),

    // Kiểu chữ
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

    // Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
    ),

    // TextField, Form
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
      space: 40,
    ),

    // BottomNavigationBar trong dark mode
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF42A5F5),
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
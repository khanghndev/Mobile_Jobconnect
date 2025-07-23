// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/core/config/providers/text_size_provider.dart';
import 'package:job_connect/core/config/providers/theme_provider.dart';
//import 'package:job_connect/core/services/notification_service.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //await NotificationService().initNotifications();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userId = prefs.getString('userId') ?? '';
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextSizeProvider()),
      ],
      child: MainApp(isLoggedIn: isLoggedIn, userId: userId),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userId;
  const MainApp({super.key, required this.isLoggedIn, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe các thay đổi từ Provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textSizeProvider = Provider.of<TextSizeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JobConnect',

      // 1. Cấu hình Theme từ ThemeProvider
      themeMode: themeProvider.themeMode, // Dùng themeMode từ Provider
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF42A5F5),
        ).copyWith(
          background: const Color(0xFFF8F9FA), // Màu nền tổng thể sáng
          surface: Colors.white, // Màu nền cho Card, Dialog...
          onBackground: const Color(0xFF333333), // Màu chữ trên nền background
          onSurface: const Color(0xFF333333), // Màu chữ trên nền surface
          error: Colors.redAccent, // Màu cho lỗi
        ), // Cách mới để set background
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
          titleTextStyle: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            // Thêm SystemUiOverlayStyle cho Light Theme
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // Icon trạng thái màu tối trên nền sáng
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E88E5)),
        ),
        textTheme: const TextTheme(
          // Sử dụng các màu chữ phù hợp với nền sáng
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF555555)),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ), // Màu chữ nhỏ, ví dụ cho phiên bản
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
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
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.1),
          thickness: 1,
          space: 40,
        ),
      ),

      // Cần định nghĩa darkTheme nếu bạn muốn hỗ trợ chế độ tối
      darkTheme: ThemeData(
        // DARK THEME (ĐIỀU CHỈNH LẠI CÁC MÀU CHÍNH)
        brightness: Brightness.dark,
        primaryColor: const Color(
          0xFF42A5F5,
        ), // Màu primary có thể sáng hơn trong dark mode
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
          primary: const Color(0xFF42A5F5), // Màu primary cho dark mode
          secondary: const Color(0xFF90CAF9), // Màu secondary sáng hơn
        ).copyWith(
          background: const Color(0xFF121212), // Màu nền tối hoàn toàn
          surface: const Color(
            0xFF1E1E1E,
          ), // Màu nền cho Card, Dialog... (hơi sáng hơn background)
          onBackground: Colors.white, // Màu chữ trên nền background (trắng)
          onSurface: Colors.white, // Màu chữ trên nền surface (trắng)
          error: const Color(0xFFCF6679), // Màu lỗi cho dark mode (màu đỏ nhẹ)
        ),
        scaffoldBackgroundColor: const Color(
          0xFF121212,
        ), // Màu nền Scaffold tối hoàn toàn
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), // Màu nền tối cho AppBar
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white), // Icon màu trắng
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            // Thêm SystemUiOverlayStyle cho Dark Theme
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.light, // Icon trạng thái màu sáng trên nền tối
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF42A5F5)),
        ),
        textTheme: const TextTheme(
          // Sử dụng các màu chữ phù hợp với nền tối
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white, // Màu chữ cho tiêu đề phụ/trung bình
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ), // Hơi xám để dễ đọc
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ), // Hơi xám để dễ đọc
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ), // Màu chữ nhỏ, ví dụ cho phiên bản
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E), // Màu card tối
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C), // Màu fill input tối
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1),
          ),
          hintStyle: TextStyle(color: Colors.grey[600]), // Màu hint tối
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
      ),

      // 2. Cấu hình cỡ chữ từ TextSizeProvider
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textSizeProvider.textScaleFactor),
          ),
          child: child!,
        );
      },

      // 3. Quản lý route (SplashScreen)
      home:
          isLoggedIn
              ? HomePage(
                isLoggedIn: isLoggedIn,
                idUser: userId,
              ) // Nếu đã đăng nhập, chuyển đến HomePage
              : LoginScreen(), // Đặt SplashScreen làm trang chủ
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(isLoggedIn: isLoggedIn, idUser: userId),
        // Thêm các route khác nếu cần
        '/application_history': (context) => JobHistoryScreen(idUser: userId),
      },
    );
  }
}

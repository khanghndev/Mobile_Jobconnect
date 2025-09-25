// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/providers/text_size_provider.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/config/routers/app_router.dart';
import 'package:job_connect/config/theme/app_theme.dart';
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

    return ScreenUtilInit(
      designSize: const Size(393, 852), // Iphone 15
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MaterialApp.router(
          routerConfig: RouterModule.routers, // Sử dụng RouterModule đã định nghĩa
          debugShowCheckedModeBanner: false,
          title: 'JobConnect',

          // 1. Cấu hình Theme từ ThemeProvider
          themeMode: themeProvider.themeMode, // Dùng themeMode từ Provider
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // 2. Cấu hình cỡ chữ từ TextSizeProvider
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textSizeProvider.textScaleFactor),
              ),
              child: child!,
            );
          },

          // // 3. Quản lý route (SplashScreen)
          // home:
          //     isLoggedIn
          //         ? HomePage(
          //           isLoggedIn: isLoggedIn,
          //           idUser: userId,
          //         ) // Nếu đã đăng nhập, chuyển đến HomePage
          //         : LoginScreen(), // Đặt SplashScreen làm trang chủ
          // routes: {
          //   '/login': (context) => LoginScreen(),
          //   '/home': (context) => HomePage(isLoggedIn: isLoggedIn, idUser: userId),
          //   // Thêm các route khác nếu cần
          //   '/application_history': (context) => JobHistoryScreen(idUser: userId),
          // },
        );
      },
    );
  }
}

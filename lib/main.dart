import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/providers/text_size_provider.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/config/routers/app_router.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/config/theme/app_theme.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TextSizeProvider()),
        ChangeNotifierProvider( create: (_) => AuthViewModel(
          prefs: SharedPrefsService(prefs: prefs)),
        ),

      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
          title: 'UniJobs',
          // Cấu hình chế độ mode
          themeMode: themeProvider.themeMode, // Dùng themeMode từ Provider
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Cấu hình cỡ chữ
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textSizeProvider.textScaleFactor),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/providers/text_size_provider.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/config/routers/app_router.dart';
import 'package:job_connect/config/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), // iPhone 15
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer2<ThemeProvider, TextSizeProvider>(
          builder: (context, themeProvider, textSizeProvider, _) {
            return MaterialApp.router(
              routerConfig: RouterModule.routers,
              debugShowCheckedModeBanner: false,
              title: 'UniJobs',
              themeMode: themeProvider.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              builder: (context, child) {
                // Sử dụng ResponsiveFramework và MediaQuery đúng cách
                return ResponsiveBreakpoints.builder(
                  breakpoints: [
                    const Breakpoint(start: 0, end: 599, name: MOBILE),
                    const Breakpoint(start: 600, end: 1199, name: TABLET),
                    const Breakpoint(start: 1200, end: 1920, name: DESKTOP),
                    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                  ],
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(textSizeProvider.textScaleFactor),
                    ),
                    child: child!,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

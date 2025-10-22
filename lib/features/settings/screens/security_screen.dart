import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_item.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_section.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_switch_card.dart';
import 'package:provider/provider.dart'; 
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
      });
    }
  }

  Future<void> _saveSecuritySetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Bảo mật"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: "Quên mật khẩu",
              icon: Icons.lock_reset_outlined,
              textColor: theme.colorScheme.primary,
              isToUpperCase: true,
              fontSize: 15.sp,
            ),
            SizedBox(height: 8.h,),
            SettingSection(
              isDivider: false,
              children: [
                SettingItem(
                  icon: Icons.lock_reset_outlined,
                  iconColor: theme.primaryColor,
                  title: "Đổi mật khẩu",
                  subtitle: "Đặt lại mật khẩu tài khoản của bạn",
                  onTap: () {
                    SnackbarApp.show(
                      context,
                      title: 'Thông tin',
                      message: 'Tính năng đang phát triển',
                      backgroundColor: BackgroundColors.backgroundInfoPrimary,
                    );
                    // context.push( '/setting/reset-pass',);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h,),

            SectionTitle(
              title: "Bảo mật nâng cao",
              icon: Icons.account_circle_outlined,
              textColor: theme.colorScheme.primary,
              isToUpperCase: true,
              fontSize: 15.sp,
            ),
            SizedBox(height: 8.h,),
            SettingSection(
              isDivider: false,
              children: [
                SettingSwitchCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: theme.primaryColor,
                  title: "Xác thực hai yếu tố",
                  subtitle: "Yêu cầu mã xác minh khi đăng nhập trên thiết bị mới.",
                  value: _twoFactorEnabled,
                  onChanged: (value) {
                    setState(() {
                      _twoFactorEnabled = value;
                    });
                    _saveSecuritySetting('two_factor_enabled', value);
                  },
                ),
                SettingSwitchCard(
                  icon: Icons.fingerprint,
                  iconColor: theme.primaryColor,
                  title: "Đăng nhập sinh trắc học",
                  subtitle: "Sử dụng vân tay hoặc Face ID để đăng nhập nhanh chóng.",
                  value: themeProvider.biometricEnabled,
                  onChanged: (value) {
                    themeProvider.toggleBiometric(value);
                    SnackbarApp.show(
                      context,
                      title: 'Thông tin',
                      message: 'Đăng nhập sinh trắc học đã ${value ? 'bật' : 'tắt'} trên SettingScreen.',
                      backgroundColor: BackgroundColors.backgroundInfoPrimary,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h,),
            SectionTitle(
              title: "Hoạt động tài khoản",
              icon: Icons.lock_reset_outlined,
              textColor: theme.colorScheme.primary,
              isToUpperCase: true,
              fontSize: 15.sp,
            ),
            SizedBox(height: 8.h,),
            SettingSection(
              isDivider: false,
              children: [
                SettingItem(
                  icon: Icons.history,
                  iconColor: theme.primaryColor,
                  title: "Hoạt động đăng nhập",
                  subtitle: "Xem các phiên đăng nhập gần đây của bạn.",
                  onTap: () {
                    SnackbarApp.show(
                      context,
                      title: 'Thông tin',
                      message: 'Tính năng đang phát triển',
                      backgroundColor: BackgroundColors.backgroundInfoPrimary,
                    );
                  },
                ),
                SettingItem(
                  icon: Icons.devices_other_outlined,
                  iconColor: theme.primaryColor,
                  title: "Thiết bị đã đăng nhập",
                  subtitle:"Xem và quản lý các thiết bị đã đăng nhập tài khoản của bạn.",
                  onTap: () {
                    SnackbarApp.show(
                      context,
                      title: 'Thông tin',
                      message: 'Tính năng đang phát triển',
                      backgroundColor: BackgroundColors.backgroundInfoPrimary,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
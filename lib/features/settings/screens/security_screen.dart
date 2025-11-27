import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_item.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_section.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_switch_card.dart';
import 'package:provider/provider.dart'; 
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_connect/config/services/biometric_auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isBiometricLoading = false;

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

  Future<void> _handleBiometricToggle(bool enable, ThemeProvider themeProvider) async {
    if (!mounted) return;
    
    setState(() {
      _isBiometricLoading = true;
    });
    
    try {
      if (enable) {
        // Kiểm tra thiết bị có hỗ trợ không
        final isSupported = await _biometricService.isDeviceSupported();
        if (!isSupported) {
          if (mounted) {
            setState(() {
              _isBiometricLoading = false;
            });
            SnackbarApp.show(
              context,
              title: 'Không hỗ trợ',
              message: 'Thiết bị này không hỗ trợ sinh trắc học.',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
          return;
        }

        // Kiểm tra có phương thức nào khả dụng không
        final available = await _biometricService.getAvailableBiometrics();
        if (available.isEmpty) {
          if (mounted) {
            setState(() {
              _isBiometricLoading = false;
            });
            SnackbarApp.show(
              context,
              title: 'Chưa cài đặt',
              message: 'Vui lòng cài đặt ít nhất một phương thức sinh trắc học trong Cài đặt hệ thống.',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
          return;
        }

        // Lấy tên phương thức sinh trắc học
        final biometricName = await _biometricService.getPrimaryBiometricName();
        
        // Xác thực
        final authenticated = await _biometricService.authenticate(
          reason: 'Vui lòng xác thực bằng $biometricName để bật đăng nhập sinh trắc học',
          useErrorDialogs: true,
          stickyAuth: true,
        );

        if (authenticated) {
          if (mounted) {
            await themeProvider.toggleBiometric(true);
            setState(() {
              _isBiometricLoading = false;
            });
            SnackbarApp.show(
              context,
              title: 'Thành công',
              message: 'Đăng nhập bằng $biometricName đã được bật.',
              backgroundColor: BackgroundColors.backgroundSuccessPrimary,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _isBiometricLoading = false;
            });
            SnackbarApp.show(
              context,
              title: 'Thất bại',
              message: 'Xác thực không thành công.',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
        }
      } else {
        // Tắt sinh trắc học - không cần xác thực
        await themeProvider.toggleBiometric(false);
        if (mounted) {
          setState(() {
            _isBiometricLoading = false;
          });
          SnackbarApp.show(
            context,
            title: 'Thông tin',
            message: 'Đăng nhập sinh trắc học đã được tắt.',
            backgroundColor: BackgroundColors.backgroundInfoPrimary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
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
                Stack(
                  children: [
                    SettingSwitchCard(
                      icon: Icons.fingerprint,
                      iconColor: theme.primaryColor,
                      title: "Đăng nhập sinh trắc học",
                      subtitle: "Sử dụng vân tay hoặc Face ID để đăng nhập nhanh chóng.",
                      value: themeProvider.biometricEnabled,
                      onChanged: _isBiometricLoading 
                          ? (_) {} // No-op khi đang loading
                          : (value) => _handleBiometricToggle(value, themeProvider),
                    ),
                    if (_isBiometricLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
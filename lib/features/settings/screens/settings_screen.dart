import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/card_prompt_to_page.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/config/widgets/custom_drop_down.dart';
import 'package:job_connect/config/widgets/custom_slider_setting.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_card_profile_header.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_item.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_switch_card.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/config/providers/text_size_provider.dart';
import 'package:job_connect/config/providers/brightness_provider.dart';
import 'package:job_connect/config/services/biometric_auth_service.dart';

class SettingScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const SettingScreen({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
  });

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final BiometricAuthService _biometricService = BiometricAuthService();
  BiometricStatus _biometricStatus = BiometricStatus.error;
  String _biometricTypeName = 'Sinh trắc học';
  bool _isBiometricLoading = false;

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';

  late AnimationController _staggerAnimationController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _staggerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initializeData();
  }

  @override
  void dispose() {
    _staggerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadSettings();
    if (mounted) {
      _staggerAnimationController.forward();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load biometric status
    _biometricStatus = await _biometricService.getBiometricStatus();
    _biometricTypeName = await _biometricService.getPrimaryBiometricName();
    
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedLanguage =
            prefs.getString('selected_language') ?? 'Tiếng Việt';
      });
    }
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)
      await prefs.setBool(key, value);
    else if (value is double)
      await prefs.setDouble(key, value);
    else if (value is String) await prefs.setString(key, value);
  }


  Future<void> _onRefresh() async {
    _staggerAnimationController.reset();
    //   REFRESH

    if (mounted) _staggerAnimationController.forward();

    SnackbarApp.show(
      context,
      title: 'Thành công',
      message: 'Đã làm mới cài đặt',
      backgroundColor: BackgroundColors.backgroundSuccessPrimary,
    );
  }

  Future<void> _onToggleBiometricAuth(
      bool enable, ThemeProvider themeProvider) async {
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
            await _loadSettings(); // Reload status
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
        // Tắt đăng nhập sinh trắc học
        await themeProvider.toggleBiometric(false);
        await _loadSettings(); // Reload status
        if (mounted) {
          setState(() {
            _isBiometricLoading = false;
          });
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: 'Đăng nhập sinh trắc học đã được tắt.',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
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

  /// Widget hiển thị card đăng nhập sinh trắc học
  Widget _buildBiometricCard(ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final isEnabled = themeProvider.biometricEnabled;
    
    // Chọn icon dựa trên loại sinh trắc học
    IconData icon;
    if (_biometricTypeName.contains('Face')) {
      icon = Icons.face_rounded;
    } else if (_biometricTypeName.contains('Vân tay')) {
      icon = Icons.fingerprint_rounded;
    } else {
      icon = Icons.security_rounded;
    }

    // Subtitle dựa trên trạng thái
    String subtitle;
    if (isEnabled) {
      subtitle = 'Sử dụng $_biometricTypeName để đăng nhập nhanh';
    } else {
      subtitle = 'Bật để đăng nhập nhanh bằng $_biometricTypeName';
    }

    return Stack(
      children: [
        SettingSwitchCard(
          icon: icon,
          title: "Đăng nhập sinh trắc học",
          subtitle: subtitle,
          value: isEnabled,
          iconColor: isEnabled 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurfaceVariant,
          onChanged: _isBiometricLoading 
              ? (_) {} // Disable khi đang loading
              : (value) {
                  // Luôn cho phép bấm, kiểm tra bên trong method
                  _onToggleBiometricAuth(value, themeProvider);
                },
        ),
        if (_isBiometricLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textSizeProvider = Provider.of<TextSizeProvider>(context);
    final brightnessProvider = Provider.of<BrightnessProvider>(context);
    final theme = Theme.of(context);
    final userVM = context.watch<UserViewModel>();
    final user = userVM.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppbarTitleLarge(
        title: "Cài đặt & Tùy chỉnh",
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 400),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                if (widget.isLoggedIn && user != null)
                  SettingCardProfileHeader(user: user),
                if (!widget.isLoggedIn)
                  CardPromptToPage(
                    icon: Icons.login_outlined,
                    title: "Bạn chưa đăng nhập",
                    subtitle: "Đăng nhập để quản lý tài khoản và trải nghiệm đầy đủ các tính năng của ${AppStrings.appName}.",
                    buttonText: "Đăng nhập ngay",
                    onPressed: () => context.push(
                      '/auth/login', 
                      extra: {
                        'role': UserRole.candidate.name
                      }
                    ),
                  ),
                SizedBox(height: 16.h),
                SectionTitle(
                  title: "Tài Khoản",
                  icon: Icons.account_circle_outlined,
                  textColor: theme.colorScheme.primary,
                  isToUpperCase: true,
                  fontSize: 15.sp,
                ),

                SizedBox(height: 8.h),
                SettingSection(
                  children: [
                    SettingItem(
                      icon: Icons.manage_accounts_outlined,
                      title: "Thông tin cá nhân",
                      subtitle: "Chỉnh sửa hồ sơ, ảnh đại diện",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          LoginRequiredDialog.show(context, isLoggedIn: false);
                          return;
                        }
                        context.push(
                          '/profile/edit',
                          extra: {
                            'idUser': user?.idUser,
                          }
                        );
                      },
                    ),

                    SettingItem(
                      icon: Icons.shield_outlined,
                      title: "Bảo mật & Quyền riêng tư",
                      subtitle: "Mật khẩu, xác thực, dữ liệu",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          LoginRequiredDialog.show(context, isLoggedIn: false);
                          return;
                        }
                        context.push('/setting/security');
                      },
                    ),
                    SettingItem(
                      icon: Icons.credit_card_outlined,
                      title: "Thanh toán & Gói dịch vụ",
                      subtitle: "Quản lý gói Premium, lịch sử",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          LoginRequiredDialog.show(context, isLoggedIn: false);
                          return;
                        }
                        context.push('/setting/payment');
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                SectionTitle(
                  title: "Giao diện & hiển thị",
                  icon: Icons.palette_outlined,
                  textColor: theme.colorScheme.primary,
                  isToUpperCase: true,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 8.h),
                SettingSection(
                  children: [
                    CustomSliderSetting(
                      icon: Icons.format_size_rounded,
                      title: "Kích thước chữ",
                      value: textSizeProvider.textScaleFactor,
                      min: 0.8,
                      max: 1.5,
                      onChanged: (value) => textSizeProvider.setTextSize(value),
                    ),
                    CustomSliderSetting(
                      icon: Icons.brightness_6_rounded,
                      title: "Độ sáng",
                      value: brightnessProvider.brightness,
                      min: 0.1,
                      max: 1.0,
                      onChanged: (value) {
                        brightnessProvider.setBrightness(value);
                      },
                    ),
                    SettingSwitchCard(
                      icon: Icons.brightness_6_outlined,
                      title: "Chế độ tối",
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value){
                        themeProvider.toggleTheme(value);
                        SnackbarApp.show(
                          context,
                          icon: value? Icons.brightness_4 : Icons.brightness_7,
                          title: 'Thành công',
                          message: "Chế độ tối được ${value ? "kích hoạt" : "đã tắt"}",
                          backgroundColor: value 
                            ? BackgroundColors.backgroundSuccessPrimary 
                            : BackgroundColors.backgroundErrorPrimary,
                        );
                      } 
                    ),
                    CustomDropDown(
                      icon: Icons.language_rounded,
                      title: "Ngôn ngữ",
                      value: _selectedLanguage,
                      items: ["Tiếng Việt", "English", "日本語"],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                          _saveSetting('selected_language', value);
                          SnackbarApp.show(
                            context,
                            title: 'Thành công',
                            message: 'Ngôn ngữ đã đổi thành $value',
                            backgroundColor:
                                BackgroundColors.backgroundSuccessPrimary,
                          );
                        }
                      },
                    ),
                  ],
                ),

                //  Thông báo & tiện ích
                SizedBox(height: 16.h),
                SectionTitle(
                  title: "Thông báo & tiện ích",
                  icon: Icons.notifications_active_outlined,
                  textColor: theme.colorScheme.primary,
                  isToUpperCase: true,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 8.h),
                SettingSection(
                  children: [
                    SettingSwitchCard(
                      icon: Icons.notifications_outlined,
                      title: "Bật thông báo đẩy",
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSetting('notifications_enabled', value);
                        SnackbarApp.show(
                          context,
                          title: 'Thành công',
                          message:
                              'Thông báo đã ${value ? 'bật' : 'tắt'}',
                          backgroundColor:
                              BackgroundColors.backgroundSuccessPrimary,
                        );
                      },
                    ),
                    if (widget.isLoggedIn)
                      _buildBiometricCard(themeProvider),
                  ],
                ),

                //  Hỗ trợ & khác
                SizedBox(height: 16.h),
                SectionTitle(
                  title: "Hỗ trợ & khác",
                  icon: Icons.support_agent_rounded,
                  textColor: theme.colorScheme.primary,
                  isToUpperCase: true,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 8.h),
                SettingSection(
                  children: [
                    SettingItem(
                      icon: Icons.help_center_outlined,
                      title: "Trung tâm trợ giúp",
                      subtitle: "Câu hỏi thường gặp, hướng dẫn",
                      onTap: () => context.push('/setting/help'),
                    ),
                    SettingItem(
                      icon: Icons.policy_outlined,
                      title: "Chính sách & Điều khoản",
                      subtitle: "Quyền riêng tư, điều khoản dịch vụ",
                      onTap: () => context.push('/setting/policy'),
                    ),
                    SettingItem(
                      icon: Icons.info_outline_rounded,
                      title: "Về ${AppStrings.appName.toUpperCase()}",
                      subtitle: "Phiên bản ứng dụng, giới thiệu",
                      onTap: () => context.push('/setting/about')
                    ),
                  ],
                ),

                SizedBox(height: 24.h),
                CustomButtonBorder(
                  title: widget.isLoggedIn ? "Đăng xuất" : "Đăng nhập",
                  icon: widget.isLoggedIn ? Icons.logout_outlined : Icons.login_outlined,
                  onPressed: () => widget.isLoggedIn
                    ? DialogUtils.showLogoutDialog(context)
                    : context.push(
                      '/auth/login', 
                      extra: {
                        'role': UserRole.candidate.name
                      }
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Center(
                    child: Text(
                      "${AppStrings.appName} App v1.0.0",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant .withValues(alpha:0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

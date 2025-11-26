import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart'; 
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_item.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_section.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; 

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appName = AppStrings.appName;
  String _buildNumber = '1';
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appName = packageInfo.appName;
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      if(mounted){
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Lỗi version $e',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted){
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Lỗi đường dẫn $url',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppbarTitleLarge(
        title: "Về ${AppStrings.appName}",
        backgroundColor: theme.primaryColor,
        isShape: true,
        textColor: Colors.white,
        iconColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16.h),
                //   Logo
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha:0.15),
                        blurRadius: 15.r,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppImages.logoApp, 
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorBuilder:(context, error, stackTrace) => Icon(
                      Icons.work_outline_rounded,
                      size: 80,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                //   AppName
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                //   Phiên bản
                Text(
                  'Phiên bản $_version$_buildNumber',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                //   Mô tả ngắn gọn
                Text(
                  '${AppStrings.appName} là nền tảng kết nối ứng viên tài năng với các cơ hội việc làm hấp dẫn trong lĩnh vực Công nghệ thông tin, Thiết kế và Marketing. Sứ mệnh của chúng tôi là đồng hành cùng bạn trên con đường phát triển sự nghiệp.',
                  textAlign: TextAlign.justify,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.85),
                  ),
                ),
                SizedBox(height: 24.h),
                Divider( color: theme.dividerColor.withValues(alpha:0.7)),
                SizedBox(height: 24.h),

                //   Các liên kết hữu ích
                SettingSection(
                  isDivider: false,
                  children: [
                    SettingItem(
                      icon: Icons.web_rounded,
                      iconColor: theme.primaryColor,
                      title: "Trang web chính thức",
                      subtitle: "Trang web chính thức của ${AppStrings.appName}",
                      onTap:() {
                        //   LINK WEB
                        _launchUrl( 'https://huit.edu.vn/');
                      }
                    ),
                    SettingItem(
                      icon: Icons.policy_rounded,
                      iconColor: theme.primaryColor,
                      title: 'Chính sách & Điều khoản',
                      subtitle: "Điều khoản bảo mật của ${AppStrings.appName}",
                      onTap:() {
                        //   LINK WEB
                        context.push('/setting/policy');
                      }
                    ),

                    SettingItem(
                      icon: Icons.contact_support_rounded,
                      iconColor: theme.primaryColor,
                      title: 'Liên hệ hỗ trợ',
                      subtitle: "${AppStrings.appName} luôn lắng nghe bạn",
                      onTap:() {
                        //   MESSEGER 
                        
                      }
                    ),

                    SettingItem(
                      icon: Icons.code_rounded,
                      iconColor: theme.primaryColor,
                      title: 'Giấy phép mã nguồn mở',
                      subtitle: "Ứng dụng đã được đăng kí về pháp lí",
                      onTap:() {
                        showLicensePage(
                          context: context,
                          applicationName: _appName,
                          applicationVersion: 'Phiên bản $_version',
                          applicationIcon: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Image.asset(
                              AppImages.logoApp,
                              width: 48,
                              height: 48,
                            ),
                          ),
                          applicationLegalese:'© ${DateTime.now().year} ${AppStrings.appName} Team',
                        );
                      }
                    ),
                  ],
                ),
              
                SizedBox(height: 24.h),
                // Thông tin nhà phát triển/bản quyền
                Text(
                  '© ${DateTime.now().year} ${AppStrings.appName} Team.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Được phát triển với ❤️ bởi Nhóm Sinh Viên HUIT.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
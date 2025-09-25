import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:job_connect/config/constant/app_string.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Thêm package này để lấy thông tin phiên bản
import 'package:url_launcher/url_launcher.dart'; // Thêm package này để mở URL

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String _appName = AppStrings.appName;
  String _version = '1.0.0';
  String _buildNumber = '1';

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
      print("Error loading package info: $e");
      // Giữ giá trị mặc định nếu có lỗi
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở liên kết: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Về ${AppStrings.appName}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0.8,
        backgroundColor:
            isDarkMode
                ? theme.colorScheme.surface.withOpacity(0.95)
                : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          // Căn giữa nội dung
          child: ConstrainedBox(
            // Giới hạn chiều rộng cho đẹp hơn trên tablet
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                // Logo ứng dụng
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24), // Bo góc lớn hơn
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logohuit.png', // Đảm bảo bạn có logo này
                    width: 100,
                    height: 100,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.work_outline_rounded,
                          size: 80,
                          color: theme.primaryColor,
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tên ứng dụng
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Phiên bản
                Text(
                  'Phiên bản $_version (Build $_buildNumber)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Mô tả ngắn gọn
                Text(
                  '${AppStrings.appName} là nền tảng kết nối ứng viên tài năng với các cơ hội việc làm hấp dẫn trong lĩnh vực Công nghệ thông tin, Thiết kế và Marketing. Sứ mệnh của chúng tôi là đồng hành cùng bạn trên con đường phát triển sự nghiệp.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 32),

                Divider(
                  color: theme.dividerColor.withOpacity(0.7),
                  thickness: 0.8,
                ),
                const SizedBox(height: 24),

                // Thông tin nhà phát triển/bản quyền
                Text(
                  '© ${DateTime.now().year} ${AppStrings.appName} Team.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Được phát triển với ❤️ bởi Nhóm Sinh Viên HUIT.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Các liên kết hữu ích (ví dụ)
                _buildLinkItem(
                  theme,
                  icon: Icons.web_rounded,
                  text: 'Trang web chính thức',
                  onTap:
                      () => _launchUrl(
                        'https://huit.edu.vn/',
                      ), // Thay bằng URL của bạn
                ),
                _buildLinkItem(
                  theme,
                  icon: Icons.policy_rounded,
                  text: 'Chính sách bảo mật',
                  onTap: () {
                    // TODO: Điều hướng đến trang Chính sách bảo mật (có thể là một WebView hoặc URL)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TODO: Mở Chính sách bảo mật'),
                      ),
                    );
                  },
                ),
                _buildLinkItem(
                  theme,
                  icon: Icons.description_rounded,
                  text: 'Điều khoản dịch vụ',
                  onTap: () {
                    // TODO: Điều hướng đến trang Điều khoản dịch vụ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TODO: Mở Điều khoản dịch vụ'),
                      ),
                    );
                  },
                ),
                _buildLinkItem(
                  theme,
                  icon: Icons.contact_support_rounded,
                  text: 'Liên hệ hỗ trợ',
                  onTap: () {
                    // TODO: Điều hướng đến trang Điều khoản dịch vụ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liên hệ hỗ trợ')),
                    );
                  },
                  // () => _launchUrl(
                  //   'mailto:support@${AppStrings.appName}.com',
                  // ), // Thay bằng email hỗ trợ
                ),
                const SizedBox(height: 20),
                _buildLinkItem(
                  theme,
                  icon: Icons.code_rounded, // Icon cho giấy phép
                  text: 'Giấy phép mã nguồn mở',
                  onTap: () {
                    // Sử dụng showLicensePage của Flutter
                    showLicensePage(
                      context: context,
                      applicationName: _appName,
                      applicationVersion: 'Phiên bản $_version',
                      applicationIcon: Padding(
                        // Icon cho trang license
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logohuit.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      applicationLegalese:
                          '© ${DateTime.now().year} ${AppStrings.appName} Team',
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    ThemeData theme, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

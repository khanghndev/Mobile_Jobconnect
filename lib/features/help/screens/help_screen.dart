import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/config/widgets/custom_search_bar_main.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/help/widgets/faq_section.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_item.dart';
import 'package:job_connect/features/settings/widgets/settings/setting_section.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _filteredFaqNormal = [];
  List<Map<String, String>> _filteredFaqSocial = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqNormal = List.from(AppStrings.faqItemsNormal);
    _filteredFaqSocial = List.from(AppStrings.faqItemsSocial);

    // Lắng nghe thay đổi text để filter
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqNormal = AppStrings.faqItemsNormal
          .where((item) =>
              item['question']!.toLowerCase().contains(query) ||
              item['answer']!.toLowerCase().contains(query))
          .toList();
      _filteredFaqSocial = AppStrings.faqItemsSocial
          .where((item) =>
              item['question']!.toLowerCase().contains(query) ||
              item['answer']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          SnackbarApp.show(
            context,
            title: 'Lỗi',
            message: 'Không thể mở ứng dụng email.',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Không thể mở email: ${e.toString()}',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    // Loại bỏ khoảng trắng và ký tự đặc biệt, chỉ giữ số và dấu +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        // Sử dụng LaunchMode.externalApplication để đảm bảo mở dialer thay vì danh bạ
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          SnackbarApp.show(
            context,
            title: 'Lỗi',
            message: 'Không thể mở ứng dụng gọi điện.',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Không thể mở dialer: ${e.toString()}',
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
        title: "Trợ giúp & Phản hồi",
        backgroundColor: theme.primaryColor,
        isShape: true,
        textColor: Colors.white,
        iconColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          CustomSearchBarMain(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            onClear: () {
              _searchController.clear();
              _onSearchChanged();
            },
            hinText: "Tìm kiếm câu hỏi trợ giúp...",
          ),
          SizedBox(height: 24.h),

          SectionTitle(
            title: "Câu hỏi thường gặp",
            icon: Icons.question_answer_rounded,
            textColor: theme.colorScheme.primary,
            isToUpperCase: true,
            fontSize: 16.sp,
          ),
          SizedBox(height: 8.h),
          FAQSection(faqItems: _filteredFaqNormal),

          SizedBox(height: 16.h),
          SectionTitle(
            title: "Về ${AppStrings.appName} Social",
            icon: Icons.question_answer_rounded,
            textColor: theme.colorScheme.primary,
            isToUpperCase: true,
            fontSize: 16.sp,
          ),
          SizedBox(height: 8.h),
          FAQSection(faqItems: _filteredFaqSocial),

          SizedBox(height: 24.h),
          SectionTitle(
            title: "Liên hệ hỗ trợ",
            icon: Icons.support_agent_rounded,
            textColor: theme.colorScheme.primary,
            isToUpperCase: true,
            fontSize: 16.sp,
          ),
          SizedBox(height: 16.h),
          SettingSection(
            children: [
              SettingItem(
                icon: Icons.email_rounded,
                iconColor: theme.primaryColor,
                title: 'Email hỗ trợ',
                subtitle: 'support@${AppStrings.appName}.com',
                onTap: () => _launchEmail('support@${AppStrings.appName}.com'),
              ),
              SettingItem(
                icon: Icons.phone_outlined,
                iconColor: Colors.green,
                title: 'Hotline',
                subtitle: '1900 8888',
                onTap: () => _launchPhone('1900 8888'),
              ),
              SettingItem(
                icon: Icons.chat_rounded,
                iconColor: Colors.orange,
                title: 'Trung tâm trợ giúp',
                subtitle: 'Chat trực tiếp với CSKH',
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: 32.h),
          CustomButtomLeadingIcon(
            onPressed: () {},
            text: 'Gửi phản hồi cho ${AppStrings.appName}',
            icon: Icons.rate_review_rounded,
            iconColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.primaryColor,
            textColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
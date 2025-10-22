import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/features/resume/widgets/cv_templates/template_card.dart';

class CVTemplate {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final Map<String, dynamic> sections;

  CVTemplate({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.sections,
  });
}

class CVTemplatesScreen extends StatefulWidget {
  const CVTemplatesScreen({super.key});

  @override
  State<CVTemplatesScreen> createState() => _CVTemplatesScreenState();
}

class _CVTemplatesScreenState extends State<CVTemplatesScreen> {
  final List<CVTemplate> _templates = [
    CVTemplate(
      id: 'professional',
      name: 'Professional',
      imageUrl: AppImages.logoApp,
      description: 'Mẫu CV chuyên nghiệp, phù hợp cho các vị trí công nghệ',
      sections: {
        'personal_info': true,
        'summary': true,
        'experience': true,
        'education': true,
        'skills': true,
        'projects': true,
        'certificates': true,
        'languages': true,
      },
    ),
    CVTemplate(
      id: 'creative',
      name: 'Creative',
      imageUrl: AppImages.logoApp,
      description: 'Mẫu CV sáng tạo, phù hợp cho các vị trí thiết kế',
      sections: {
        'personal_info': true,
        'summary': true,
        'experience': true,
        'education': true,
        'skills': true,
        'projects': true,
        'portfolio': true,
        'certificates': true,
      },
    ),
    CVTemplate(
      id: 'minimal',
      name: 'Minimal',
      imageUrl: AppImages.logoApp,
      description: 'Mẫu CV tối giản, tập trung vào nội dung',
      sections: {
        'personal_info': true,
        'summary': true,
        'experience': true,
        'education': true,
        'skills': true,
        'projects': true,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarTitleLarge(title: "Chọn mẫu CV"),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Chọn mẫu CV phù hợp với bạn',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                  ),
            ),
          ),
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: 1,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              padding: EdgeInsets.all(16.w),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return TemplateCard(
                  template: template,
                  onSelected: () => _onOpenCreateCV(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onOpenCreateCV(CVTemplate template) {
    context.push(
      '/resume/create',
      extra: {'template': template},
    );
  }
}

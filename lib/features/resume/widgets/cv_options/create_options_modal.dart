import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/resume/widgets/cv_options/create_option_item.dart';

class CreateOptionsModal extends StatelessWidget {
  final ThemeData theme;
  final bool isUploadingCv;
  final double uploadProgress;
  final VoidCallback? onUpload;
  final VoidCallback onAICreate;
  final VoidCallback onTemplates;

  const CreateOptionsModal({
    super.key,
    required this.theme,
    required this.isUploadingCv,
    required this.uploadProgress,
    required this.onUpload,
    required this.onAICreate,
    required this.onTemplates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        top: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thêm CV Mới",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.iconTheme.color?.withValues(alpha:0.7),
                  size: 26.sp,
                ),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24.r,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: theme.dividerColor.withValues(alpha:0.5)),
          SizedBox(height: 15.h),
          CreateOptionItem(
            icon: Icons.cloud_upload_rounded,
            title: "Tải Lên Từ Thiết Bị",
            subtitle: "Chọn file PDF, DOC, DOCX từ máy của bạn.",
            iconBgColor: theme.colorScheme.primaryContainer.withValues(alpha:0.7),
            iconColor: theme.colorScheme.onPrimaryContainer,
            onTap: onUpload,
            trailingWidget: isUploadingCv
                ? SizedBox(
                    width: 120.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LinearProgressIndicator(
                          value: uploadProgress > 0 && uploadProgress < 1
                              ? uploadProgress
                              : (uploadProgress >= 1 ? 1.0 : null),
                          backgroundColor: theme.dividerColor.withValues(alpha:0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          minHeight: 6.h,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '${(uploadProgress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SizedBox(height: 10.h),
          Divider(color: theme.dividerColor.withValues(alpha:0.2)),
          SizedBox(height: 10.h),
          CreateOptionItem(
            icon: Icons.auto_awesome_rounded,
            title: "Tạo CV Bằng AI",
            subtitle: "Để trí tuệ nhân tạo hỗ trợ bạn tạo CV ấn tượng.",
            iconBgColor: theme.colorScheme.secondaryContainer.withValues(alpha:0.7),
            iconColor: theme.colorScheme.onSecondaryContainer,
            onTap: onAICreate,
          ),
          SizedBox(height: 10.h),
          Divider(color: theme.dividerColor.withValues(alpha:0.2)),
          SizedBox(height: 10.h),
          CreateOptionItem(
            icon: Icons.article_outlined,
            title: "Sử Dụng Mẫu CV Có Sẵn",
            subtitle: "Lựa chọn từ thư viện mẫu CV chuyên nghiệp.",
            iconBgColor: theme.colorScheme.tertiaryContainer.withValues(alpha:0.7),
            iconColor: theme.colorScheme.onTertiaryContainer,
            onTap: onTemplates,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
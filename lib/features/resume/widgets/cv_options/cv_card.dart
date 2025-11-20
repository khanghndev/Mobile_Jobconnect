import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/resume/widgets/cv_options/card_popup_menu.dart';

class CvCard extends StatelessWidget {
  final ResumeModel resume;
  final VoidCallback? onView;
  final VoidCallback? onEditName;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const CvCard({
    super.key,
    required this.resume,
    this.onView,
    this.onEditName,
    this.onShare,
    this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String fileName = resume.fileName;
    final String fileSize = resume.fileSizeKB == 0 ? "N/A" : FormatUtils.formatFileSize(resume.fileSizeKB);
    final String date = FormatUtils.formattedDateTime(resume.createdAt);
    final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
    final Color fileIconBgColor =isPdf
      ? theme.colorScheme.errorContainer.withValues(alpha:0.6)
      : theme.colorScheme.primaryContainer.withValues(alpha:0.6);
    final Color fileIconColor =
        isPdf
            ? theme.colorScheme.onErrorContainer.withValues(alpha:0.9)
            : theme.colorScheme.onPrimaryContainer.withValues(alpha:0.9);
    final IconData fileIcon =
        isPdf ? Icons.picture_as_pdf_rounded : Icons.article_rounded;

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      elevation: 1.5,
      shadowColor: theme.shadowColor.withValues(alpha:0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: theme.primaryColor.withValues(alpha:0.08),
        highlightColor: theme.primaryColor.withValues(alpha:0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: fileIconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(fileIcon, color: fileIconColor, size: 26.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13.sp,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.7),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.sd_storage_outlined,
                          size: 13.sp,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          fileSize,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CVCardPopupMenu(
                onEditName: onEditName ?? (){},
                onShare: onShare ?? (){},
                onDownload: onDownload ?? (){},
                onDelete: onDelete ?? (){},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
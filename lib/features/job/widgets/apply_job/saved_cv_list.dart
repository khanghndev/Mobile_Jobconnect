import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';

class SavedCvList extends StatelessWidget {
  final List<ResumeModel> savedCVs;
  final String? selectedCvUrl;
  final ValueChanged<ResumeModel> onSelect;

  const SavedCvList({
    super.key,
    required this.savedCVs,
    required this.onSelect,
    this.selectedCvUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (savedCVs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      constraints: BoxConstraints(maxHeight: 200.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: savedCVs.length,
        itemBuilder: (context, index) {
          final resume = savedCVs[index];
          final bool isSelected = selectedCvUrl == resume.fileUrl;

          return Column(
            children: [
              ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
                title: Text(
                  resume.fileName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  "Cập nhật: ${FormatUtils.formattedDateTime(resume.updatedAt)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () => onSelect(resume),
                dense: true,
                selected: isSelected,
                selectedTileColor: theme.primaryColor.withValues(alpha: 0.05),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
              ),
              if (index < savedCVs.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Divider(
                    height: 1.h,
                    thickness: 1,
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

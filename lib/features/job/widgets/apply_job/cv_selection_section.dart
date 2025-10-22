import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/job/widgets/apply_job/saved_cv_list.dart';
import 'package:job_connect/features/job/widgets/apply_job/selected_cv_info.dart';
class CvSelectionSection extends StatefulWidget {
  final List<ResumeModel> savedCVs;
  final String? selectedSavedCvUrl;
  final String? selectedSavedCvName;
  final String? selectedCVFileName;
  final bool isExpanded;
  final VoidCallback onPickCv;
  final VoidCallback onRemoveCv;
  final ValueChanged<ResumeModel> onSelectSavedCv;
  final ValueChanged<bool> onToggleExpand;
  final bool hasLocalFile;

  const CvSelectionSection({
    super.key,
    required this.savedCVs,
    required this.onPickCv,
    required this.onRemoveCv,
    required this.onSelectSavedCv,
    required this.onToggleExpand,
    this.selectedSavedCvUrl,
    this.selectedSavedCvName,
    this.selectedCVFileName,
    this.isExpanded = false,
    this.hasLocalFile = false,
  });

  @override
  State<CvSelectionSection> createState() => _CvSelectionSectionState();
}

class _CvSelectionSectionState extends State<CvSelectionSection>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Hiển thị CV đã chọn hoặc hướng dẫn
            if (widget.hasLocalFile || widget.selectedSavedCvUrl != null)
              SelectedCvInfo(
                fileName: widget.selectedCVFileName ?? widget.selectedSavedCvName,
                isFromDevice: widget.hasLocalFile,
                isFromSaved: widget.selectedSavedCvUrl != null,
                onRemove: widget.onRemoveCv,
              )
            else
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  "Vui lòng chọn hoặc tải lên CV của bạn.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),

            // Hàng nút Tải lên / CV đã lưu
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onPickCv,
                    icon: Icon(
                      Icons.upload_file_rounded,
                      size: 20.sp,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      "Tải Lên CV",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.primaryColor.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onToggleExpand(!widget.isExpanded),
                    icon: Icon(
                      widget.isExpanded
                          ? Icons.folder_open_rounded
                          : Icons.folder_copy_outlined,
                      size: 20.sp,
                    ),
                    label: const Text(
                      "CV Đã Lưu",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),

            // Danh sách CV có animation mở rộng / thu gọn
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: widget.isExpanded
                  ? (widget.savedCVs.isNotEmpty
                      ? SavedCvList(
                          savedCVs: widget.savedCVs,
                          selectedCvUrl: widget.selectedSavedCvUrl,
                          onSelect: widget.onSelectSavedCv,
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Bạn chưa có CV nào được lưu.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
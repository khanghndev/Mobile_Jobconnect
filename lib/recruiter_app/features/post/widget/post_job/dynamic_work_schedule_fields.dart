import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';

class DynamicWorkScheduleFields extends StatelessWidget {
  final String workType;
  final String? workSchedule;
  final TextEditingController? minHoursController;
  final TextEditingController? maxHoursController;
  final TextEditingController? workDaysController;
  final Color? labelTextColor;
  final Color? prefixIconColor;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const DynamicWorkScheduleFields({
    super.key,
    required this.workType,
    this.workSchedule,
    this.minHoursController,
    this.maxHoursController,
    this.workDaysController,
    this.labelTextColor,
    this.prefixIconColor,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    // Chỉ hiển thị các trường lịch làm việc cho Part-time và Temporary
    if (workType != 'Part-time' && workType != 'Temporary') {
      return const SizedBox.shrink();
    }

    // Nếu chưa chọn workSchedule, hiển thị thông báo hoặc ẩn các trường
    if (workSchedule == null || workSchedule!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: recruiterPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: recruiterPrimary.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: recruiterPrimary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Vui lòng chọn "Thời gian làm việc" ở trên để hiển thị các trường lịch làm việc',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: recruiterPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị workSchedule đã chọn
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                recruiterPrimary.withValues(alpha: 0.1),
                recruiterPrimary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: recruiterPrimary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Thời gian làm việc: $workSchedule',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: recruiterPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Số giờ tối thiểu và tối đa/tuần
        if (minHoursController != null || maxHoursController != null) ...[
          Row(
            children: [
              if (minHoursController != null)
                Expanded(
                  child: CustomTextFieldWithLabel(
                    labelTextColor: labelTextColor ?? recruiterPrimary,
                    prefixIconColor: prefixIconColor ?? recruiterPrimary,
                    fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
                    borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
                    borderRadius: borderRadius ?? 14.r,
                    controller: minHoursController!,
                    label: 'Số giờ tối thiểu/tuần',
                    hintText: 'Giờ',
                    keyboardType: TextInputType.number,
                    icon: Icons.access_time_outlined,
                    iconSize: 20.sp,
                  ),
                ),
              if (minHoursController != null && maxHoursController != null)
                SizedBox(width: 12.w),
              if (maxHoursController != null)
                Expanded(
                  child: CustomTextFieldWithLabel(
                    labelTextColor: labelTextColor ?? recruiterPrimary,
                    prefixIconColor: prefixIconColor ?? recruiterPrimary,
                    fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
                    borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
                    borderRadius: borderRadius ?? 14.r,
                    controller: maxHoursController!,
                    label: 'Số giờ tối đa/tuần',
                    hintText: 'Giờ',
                    keyboardType: TextInputType.number,
                    icon: Icons.access_time_outlined,
                    iconSize: 20.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
        // Số ngày làm việc/tuần
        if (workDaysController != null)
          CustomTextFieldWithLabel(
            labelTextColor: labelTextColor ?? recruiterPrimary,
            prefixIconColor: prefixIconColor ?? recruiterPrimary,
            fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
            borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
            borderRadius: borderRadius ?? 14.r,
            controller: workDaysController!,
            label: 'Số ngày làm việc/tuần',
            hintText: 'Ngày',
            keyboardType: TextInputType.number,
            icon: Icons.calendar_today_outlined,
            iconSize: 20.sp,
          ),
      ],
    );
  }
}


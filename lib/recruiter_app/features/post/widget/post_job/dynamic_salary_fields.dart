import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';

class DynamicSalaryFields extends StatelessWidget {
  final String workType;
  final String? workSchedule;
  final TextEditingController? salaryController;
  final TextEditingController? hourlyRateController;
  final TextEditingController? dailyRateController;
  final TextEditingController? projectBudgetController;
  final Color? labelTextColor;
  final Color? prefixIconColor;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const DynamicSalaryFields({
    super.key,
    required this.workType,
    this.workSchedule,
    this.salaryController,
    this.hourlyRateController,
    this.dailyRateController,
    this.projectBudgetController,
    this.labelTextColor,
    this.prefixIconColor,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    // Render các trường lương theo workType và workSchedule
    if (workType == 'Part-time' || workType == 'Temporary') {
      return Column(
        children: [
          // Lương theo giờ - luôn hiển thị cho Part-time và Temporary
          if (hourlyRateController != null)
            CustomTextFieldWithLabel(
              labelTextColor: labelTextColor ?? recruiterPrimary,
              prefixIconColor: prefixIconColor ?? recruiterPrimary,
              fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
              borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: borderRadius ?? 14.r,
              controller: hourlyRateController!,
              label: 'Lương theo giờ',
              hintText: 'VNĐ/giờ',
              icon: Icons.monetization_on_outlined,
              iconSize: 20.sp,
              keyboardType: TextInputType.number,
            ),
          // Lương theo ngày - hiển thị khi có workSchedule (Sáng, Chiều, Tối)
          if (dailyRateController != null && workSchedule != null && workSchedule!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            CustomTextFieldWithLabel(
              labelTextColor: labelTextColor ?? recruiterPrimary,
              prefixIconColor: prefixIconColor ?? recruiterPrimary,
              fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
              borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: borderRadius ?? 14.r,
              controller: dailyRateController!,
              label: 'Lương theo ngày (${workSchedule})',
              hintText: 'VNĐ/ngày',
              icon: Icons.monetization_on_outlined,
              iconSize: 20.sp,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      );
    } else if (workType == 'Project-based' || workType == 'Freelance') {
      // Project budget
      if (projectBudgetController != null) {
        return CustomTextFieldWithLabel(
          labelTextColor: labelTextColor ?? recruiterPrimary,
          prefixIconColor: prefixIconColor ?? recruiterPrimary,
          fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
          borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
          borderRadius: borderRadius ?? 14.r,
          controller: projectBudgetController!,
          label: 'Ngân sách dự án',
          hintText: 'VNĐ',
          icon: Icons.account_balance_wallet_outlined,
          iconSize: 20.sp,
          keyboardType: TextInputType.number,
        );
      }
    }
    
    // Full-time: Lương theo tháng
    if (salaryController != null) {
      return CustomTextFieldWithLabel(
        labelTextColor: labelTextColor ?? recruiterPrimary,
        prefixIconColor: prefixIconColor ?? recruiterPrimary,
        fillColor: fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
        borderColor: borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? 14.r,
        controller: salaryController!,
        label: 'Mức lương',
        hintText: 'VNĐ/tháng',
        icon: Icons.monetization_on_outlined,
        iconSize: 20.sp,
        keyboardType: TextInputType.number,
      );
    }
    
    return const SizedBox.shrink();
  }
}


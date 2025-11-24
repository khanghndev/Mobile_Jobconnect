import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';

class RecruitmentTab extends StatelessWidget {
  final bool isPremiumUser;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;
  final TextEditingController benefitsController;
  final TextEditingController salaryController;
  final TextEditingController locationController;
  final TextEditingController workDaysController;
  final String? jobType;
  final String? experienceLevel;
  final String? location;
  final List<String> jobTypes;
  final List<String> experienceLevels;
  final List<String> locations;
  final DateTime? selectedDeadline;
  final bool isUrgent;
  final VoidCallback onCreateJob;
  final VoidCallback onResetForm;
  final VoidCallback onPickDeadline;
  final ValueChanged<String> onJobTypeChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<bool> onUrgentChanged;
  final GlobalKey<FormState> formKey;

  const RecruitmentTab({
    super.key,
    required this.isPremiumUser,
    required this.titleController,
    required this.descriptionController,
    required this.requirementsController,
    required this.benefitsController,
    required this.salaryController,
    required this.locationController,
    required this.workDaysController,
    this.jobType,
    this.experienceLevel,
    this.location,
    required this.jobTypes,
    required this.experienceLevels,
    required this.locations,
    this.selectedDeadline,
    required this.isUrgent,
    required this.onCreateJob,
    required this.onResetForm,
    required this.onPickDeadline,
    required this.onJobTypeChanged,
    required this.onExperienceChanged,
    required this.onLocationChanged,
    required this.onUrgentChanged,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với gradient indigo đẹp
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    recruiterPrimary.withValues(alpha: 0.08),
                    recruiterPrimary.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.15),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: recruiterPrimary.withValues(alpha: 0.2),
                  width: 1.5.w,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF283593)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: recruiterPrimary.withValues(alpha: 0.3),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_business_rounded,
                      size: 26.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tạo tin tuyển dụng mới",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: recruiterPrimary,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    recruiterPrimary.withValues(alpha: 0.1),
                    recruiterPrimary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: recruiterPrimary.withValues(alpha: 0.25),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: SectionTitle(
                title: "THÔNG TIN CƠ BẢN",
                icon: Icons.person_pin_rounded,
                iconColor: recruiterPrimary,
                textColor: recruiterPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),

            // Tiêu đề công việc
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: titleController,
              label: 'Tiêu đề công việc',
              hintText: 'Ví dụ: Kỹ sư phần mềm Flutter',
              icon: Icons.work_outline,
              iconSize: 20.sp,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null) {
                  return 'Tiêu đề công việc không được bỏ trống';
                }
                final trimmed = value.trim();
                if (trimmed.isEmpty) {
                  return 'Tiêu đề công việc không được bỏ trống';
                }
                if (trimmed.length < 5) {
                  return 'Tiêu đề công việc phải có ít nhất 5 ký tự';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            SizedBox(height: 18.h),

            // Mô tả công việc
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: descriptionController,
              label: 'Mô tả công việc',
              hintText: 'Mô tả chi tiết về công việc...',
              icon: Icons.description_outlined,
              iconSize: 20.sp,
              maxLines: 5,
            ),
            SizedBox(height: 18.h),

            // Yêu cầu ứng viên
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: requirementsController,
              label: 'Yêu cầu ứng viên',
              hintText: 'Kỹ năng, bằng cấp...',
              icon: Icons.assignment_outlined,
              iconSize: 20.sp,
              maxLines: 4,
            ),
            SizedBox(height: 18.h),

            // Quyền lợi
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: benefitsController,
              label: 'Quyền lợi',
              hintText: 'Chế độ bảo hiểm, thưởng...',
              icon: Icons.card_giftcard_outlined,
              iconSize: 20.sp,
              maxLines: 4,
            ),
            SizedBox(height: 18.h),

            // Deadline
            _buildDatePicker(context, 'Hạn nộp', selectedDeadline, onPickDeadline),
            SizedBox(height: 28.h),

            Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    recruiterPrimary.withValues(alpha: 0.1),
                    recruiterPrimary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: recruiterPrimary.withValues(alpha: 0.25),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: SectionTitle(
                title: "THÔNG TIN CHI TIẾT",
                icon: Icons.info_outline_rounded,
                iconColor: recruiterPrimary,
                textColor: recruiterPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),

            // Loại hình làm việc
            _buildDropdown(
              context: context,
              label: 'Loại hình làm việc',
              icon: Icons.access_time,
              value: jobType,
              items: jobTypes,
              onChanged: onJobTypeChanged,
            ),
            SizedBox(height: 18.h),

            // Mức lương
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: salaryController,
              label: 'Mức lương',
              hintText: 'VNĐ/tháng',
              icon: Icons.monetization_on_outlined,
              iconSize: 20.sp,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => InputValidators.validate(
                value: value,
                hintText: 'Mức lương',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 18.h),

            // Kinh nghiệm
            _buildDropdown(
              context: context,
              label: 'Kinh nghiệm',
              icon: Icons.trending_up_outlined,
              value: experienceLevel,
              items: experienceLevels,
              onChanged: onExperienceChanged,
            ),
            SizedBox(height: 18.h),

            // Địa điểm làm việc
            _buildDropdown(
              context: context,
              label: 'Địa điểm làm việc',
              icon: Icons.location_on_outlined,
              value: location,
              items: locations,
              onChanged: (val) {
                onLocationChanged(val);
                locationController.text = val;
              },
            ),
            SizedBox(height: 18.h),

            // Số ngày làm việc/tuần
            CustomTextFieldWithLabel(
              suffixIconColor: recruiterPrimary,
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: workDaysController,
              label: 'Số ngày làm việc/tuần',
              hintText: 'Nhập số ngày làm việc',
              icon: Icons.calendar_today_outlined,
              iconSize: 20.sp,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => InputValidators.validate(
                value: value,
                hintText: 'Số ngày làm việc/tuần',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16.h),

            // Tin tuyển gấp
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isUrgent
                      ? [
                          const Color(0xFFFFE8E8),
                          const Color(0xFFFFF0F0),
                        ]
                      : [
                          recruiterPrimary.withValues(alpha: 0.08),
                          recruiterPrimary.withValues(alpha: 0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isUrgent
                      ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                      : recruiterPrimary.withValues(alpha: 0.2),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUrgent
                            ? const Color(0xFFEF4444)
                            : recruiterPrimary)
                        .withValues(alpha: 0.15),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: (isUrgent
                              ? const Color(0xFFEF4444)
                              : recruiterPrimary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: isUrgent
                          ? const Color(0xFFEF4444)
                          : recruiterPrimary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Đánh dấu tin tuyển gấp",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: isUrgent
                                ? const Color(0xFFEF4444)
                                : recruiterPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isPremiumUser
                              ? "Tin tuyển dụng của bạn sẽ được ưu tiên hiển thị"
                              : "Cần đăng kí gói Premium để sử dụng tính năng này",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isUrgent,
                    onChanged: isPremiumUser
                        ? (bool? val) {
                            if (val != null) onUrgentChanged(val);
                          }
                        : null,
                    activeColor: isUrgent
                        ? const Color(0xFFEF4444)
                        : recruiterPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: recruiterPrimary.withValues(alpha: 0.3),
                        width: 1.5.w,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onResetForm,
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: Text(
                              "Hủy",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: recruiterPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF283593)],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: recruiterPrimary.withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Validate form trước khi submit
                          if (formKey.currentState!.validate()) {
                            onCreateJob();
                          }
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Đăng tin",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);
    final validValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: recruiterPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: recruiterPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.3),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: recruiterPrimary.withValues(alpha: 0.05),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: recruiterPrimary),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: validValue,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down_rounded, size: 22.sp, color: recruiterPrimary),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    items: items.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: recruiterPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: recruiterPrimary.withValues(alpha: 0.3),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: recruiterPrimary.withValues(alpha: 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20.sp,
              color: recruiterPrimary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color: recruiterPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    date != null ? DateFormat('dd/MM/yyyy – HH:mm').format(date) : 'Chọn ngày',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      color: date != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: recruiterPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

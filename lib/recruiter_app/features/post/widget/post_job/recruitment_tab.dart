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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tạo tin tuyển dụng mới",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            SectionTitle(
              title: "THÔNG TIN CƠ BẢN",
              icon: Icons.person_pin_rounded,
              fontSize: 16.sp,
            ),
            SizedBox(height: 16.h),

            // Tiêu đề công việc
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: titleController,
              label: 'Tiêu đề công việc',
              hintText: 'Ví dụ: Kỹ sư phần mềm Flutter',
              icon: Icons.work_outline,
              keyboardType: TextInputType.text,
              validator: (value) => InputValidators.validate(
                value: value,
                hintText: 'Tiêu đề công việc',
              ),
            ),
            SizedBox(height: 16.h),

            // Mô tả công việc
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: descriptionController,
              label: 'Mô tả công việc',
              hintText: 'Mô tả chi tiết về công việc...',
              icon: Icons.description_outlined,
              maxLines: 5,
            ),
            SizedBox(height: 16.h),

            // Yêu cầu ứng viên
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: requirementsController,
              label: 'Yêu cầu ứng viên',
              hintText: 'Kỹ năng, bằng cấp...',
              icon: Icons.assignment_outlined,
              maxLines: 4,
            ),
            SizedBox(height: 16.h),

            // Quyền lợi
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: benefitsController,
              label: 'Quyền lợi',
              hintText: 'Chế độ bảo hiểm, thưởng...',
              icon: Icons.card_giftcard_outlined,
              maxLines: 4,
            ),
            SizedBox(height: 16.h),

            // Deadline
            _buildDatePicker(context, 'Hạn nộp', selectedDeadline, onPickDeadline),
            SizedBox(height: 24.h),

            SectionTitle(
              title: "THÔNG TIN CHI TIẾT",
              icon: Icons.info_outline_rounded,
              fontSize: 16.sp,
            ),
            SizedBox(height: 16.h),

            // Loại hình làm việc
            _buildDropdown(
              context: context,
              label: 'Loại hình làm việc',
              icon: Icons.access_time,
              value: jobType,
              items: jobTypes,
              onChanged: onJobTypeChanged,
            ),
            SizedBox(height: 16.h),

            // Mức lương
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: salaryController,
              label: 'Mức lương',
              hintText: 'VNĐ/tháng',
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => InputValidators.validate(
                value: value,
                hintText: 'Mức lương',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16.h),

            // Kinh nghiệm
            _buildDropdown(
              context: context,
              label: 'Kinh nghiệm',
              icon: Icons.trending_up_outlined,
              value: experienceLevel,
              items: experienceLevels,
              onChanged: onExperienceChanged,
            ),
            SizedBox(height: 16.h),

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
            SizedBox(height: 16.h),

            // Số ngày làm việc/tuần
            CustomTextFieldWithLabel(
              suffixIconColor: Colors.black87,
              labelTextColor: Colors.black87,
              controller: workDaysController,
              label: 'Số ngày làm việc/tuần',
              hintText: 'Nhập số ngày làm việc',
              icon: Icons.calendar_today_outlined,
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isUrgent ? Colors.red.shade500 : Colors.blue.shade400,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUrgent ? Colors.red.shade200 : Colors.blue.shade200)
                        .withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isUrgent,
                    onChanged: isPremiumUser
                        ? (bool? val) {
                            if (val != null) onUrgentChanged(val);
                          }
                        : null,
                    activeColor: isUrgent ? Colors.red.shade500 : Colors.blue.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.warning_amber_rounded,
                      color: isUrgent ? Colors.red.shade500 : Colors.blue.shade400,
                      size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Đánh dấu tin tuyển gấp",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            color: isUrgent ? Colors.red.shade500 : Colors.blue.shade400,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Cần đăng kí gói Premium để sử dụng tính năng này",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: isUrgent ? Colors.red.shade500 : Colors.blue.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onResetForm,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Hủy",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onCreateJob,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.publish_outlined, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Đăng tin tuyển dụng",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
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
    final validValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Colors.black54)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.black87),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: validValue,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, size: 24.sp),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: Colors.black87),
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        ),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd – HH:mm').format(date) : 'Chọn ngày',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: date != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

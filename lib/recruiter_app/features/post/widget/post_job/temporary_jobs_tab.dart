import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';

class TemporaryJobsFormTab extends StatelessWidget {
  final bool isPremiumUser;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;
  final TextEditingController hourlyRateController;
  final TextEditingController dailyRateController;
  final TextEditingController locationController;
  final TextEditingController minHoursController;
  final TextEditingController maxHoursController;
  final TextEditingController workDaysController;
  final String workType;
  final String workSchedule;
  final String category;
  final String experienceLevel;
  final DateTime? seasonalStart;
  final DateTime? seasonalEnd;
  final DateTime? applicationDeadline;
  final bool isUrgent;
  final VoidCallback onCreateJob;
  final VoidCallback onResetForm;
  final VoidCallback onPickSeasonalStart;
  final VoidCallback onPickSeasonalEnd;
  final VoidCallback onPickDeadline;
  final ValueChanged<String> onWorkTypeChanged;
  final ValueChanged<String> onWorkScheduleChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<bool> onUrgentChanged;
  final GlobalKey<FormState> formKey;
  final List<String> workTypes;
  final List<String> workSchedules;
  final List<String> categories;
  final List<String> experienceLevels;

  const TemporaryJobsFormTab({
    super.key,
    required this.isPremiumUser,
    required this.titleController,
    required this.descriptionController,
    required this.requirementsController,
    required this.hourlyRateController,
    required this.dailyRateController,
    required this.locationController,
    required this.minHoursController,
    required this.maxHoursController,
    required this.workDaysController,
    required this.workType,
    required this.workSchedule,
    required this.category,
    required this.experienceLevel,
    required this.seasonalStart,
    required this.seasonalEnd,
    required this.applicationDeadline,
    required this.isUrgent,
    required this.onCreateJob,
    required this.onResetForm,
    required this.onPickSeasonalStart,
    required this.onPickSeasonalEnd,
    required this.onPickDeadline,
    required this.onWorkTypeChanged,
    required this.onWorkScheduleChanged,
    required this.onCategoryChanged,
    required this.onExperienceChanged,
    required this.onUrgentChanged,
    required this.formKey,
    required this.workTypes,
    required this.workSchedules,
    required this.categories,
    required this.experienceLevels,
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
                    "Tạo tin thời vụ mới",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            SectionTitle(
              title: "THÔNG TIN CHI TIẾT",
              icon: Icons.info_outline_rounded,
              fontSize: 16.sp,
            ),
            SizedBox(height: 16.h),

            // Tiêu đề công việc
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: titleController,
              label: 'Tiêu đề công việc',
              hintText: 'Nhập tiêu đề công việc...',
              icon: Icons.work_outline,
            ),
            SizedBox(height: 16.h),

            // Mô tả
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: descriptionController,
              label: 'Mô tả công việc',
              hintText: 'Mô tả chi tiết công việc...',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            SizedBox(height: 16.h),

            // Yêu cầu
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: requirementsController,
              label: 'Yêu cầu ứng viên',
              hintText: 'Kỹ năng, bằng cấp...',
              icon: Icons.assignment_outlined,
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // Lương
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: hourlyRateController,
              label: 'Lương theo giờ',
              hintText: 'VNĐ/giờ',
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: dailyRateController,
              label: 'Lương theo ngày',
              hintText: 'VNĐ/ngày',
              icon: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),

            // Min & Max hours per week
            Row(
              children: [
                Expanded(
                  child: CustomTextFieldWithLabel(
                    labelTextColor: Colors.black87,
                    controller: minHoursController,
                    label: 'Số giờ tối thiểu/tuần',
                    keyboardType: TextInputType.number,
                    icon: Icons.access_time_outlined,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomTextFieldWithLabel(
                    labelTextColor: Colors.black87,
                    controller: maxHoursController,
                    label: 'Số giờ tối đa/tuần',
                    keyboardType: TextInputType.number,
                    icon: Icons.access_time_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Work days
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: workDaysController,
              label: 'Số ngày làm việc/tuần',
              keyboardType: TextInputType.number,
              icon: Icons.calendar_today_outlined,
            ),
            SizedBox(height: 16.h),

            // Dropdowns
            _buildDropdown(context, 'Loại công việc', workType, workTypes, onWorkTypeChanged, theme),
            SizedBox(height: 16.h),
            _buildDropdown(context, 'Thời gian làm việc', workSchedule, workSchedules, onWorkScheduleChanged, theme),
            SizedBox(height: 16.h),
            _buildDropdown(context, 'Danh mục công việc', category, categories, onCategoryChanged, theme),
            SizedBox(height: 16.h),
            _buildDropdown(context, 'Trình độ kinh nghiệm', experienceLevel, experienceLevels, onExperienceChanged, theme),
            SizedBox(height: 16.h),

            // Location
            CustomTextFieldWithLabel(
              labelTextColor: Colors.black87,
              controller: locationController,
              label: 'Địa điểm làm việc',
              hintText: 'Nhập địa điểm...',
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 24.h),

            // Seasonal dates
            _buildDatePicker(context, 'Ngày bắt đầu (nếu seasonal)', seasonalStart, onPickSeasonalStart, theme),
            SizedBox(height: 24.h),
            _buildDatePicker(context, 'Ngày kết thúc (nếu seasonal)', seasonalEnd, onPickSeasonalEnd, theme),
            SizedBox(height: 24.h),

            // Application deadline
            _buildDatePicker(context, 'Hạn nộp hồ sơ', applicationDeadline, onPickDeadline, theme),
            SizedBox(height: 16.h),

            // Urgent checkbox
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade100 : Colors.blue.shade50, // đổi màu nền
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isUrgent ? Colors.red.shade500 : Colors.blue.shade400, // đổi viền
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
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Hủy",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
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
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_outlined,
                              color: Colors.white, size: 20.w),
                          SizedBox(width: 8.w),
                          Text(
                            "Đăng tin thời vụ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value, List<String> items, ValueChanged<String> onChanged, ThemeData theme) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: theme.textTheme.bodyMedium,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: theme.textTheme.bodyMedium),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, VoidCallback onTap, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Chọn ngày',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildUrgentCheckbox(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: isUrgent,
          onChanged: isPremiumUser ? (val) { if (val != null) onUrgentChanged(val); } : null,
        ),
        SizedBox(width: 8.w),
        Text('Đánh dấu tin tuyển gấp', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

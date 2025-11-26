import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/location_field_with_current_location.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/dynamic_salary_fields.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/dynamic_work_schedule_fields.dart';
import 'package:job_connect/features/job/model/job_category_model.dart';

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
  final String? workSchedule; // Có thể null khi chưa load
  final String? categoryId; // Lưu idCategory thay vì tên
  final String experienceLevel;
  final Function(double?, double?)? onLocationObtained;
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
  final ValueChanged<String> onCategoryChanged; // Nhận idCategory
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<bool> onUrgentChanged;
  final GlobalKey<FormState> formKey;
  final List<String> workTypes;
  final List<String> workSchedules;
  final List<JobCategoryModel> categories; // Thay đổi từ List<String>
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
    required this.categoryId,
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
    this.onLocationObtained,
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
            // Header với gradient indigo
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F0FE),
                    Color(0xFFF0F7FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 6.h),
                    spreadRadius: 1.r,
                  ),
                ],
                border: Border.all(
                  color: recruiterPrimary.withValues(alpha: 0.15),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: recruiterPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 24.sp,
                      color: recruiterPrimary,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tạo tin thời vụ mới",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: recruiterPrimary,
                            fontSize: 20.sp,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            SectionTitle(
              title: "THÔNG TIN CHI TIẾT",
              icon: Icons.info_outline_rounded,
              fontSize: 16.sp,
            ),
            SizedBox(height: 16.h),

            // Tiêu đề công việc
            CustomTextFieldWithLabel(
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: titleController,
              label: 'Tiêu đề công việc',
              hintText: 'Nhập tiêu đề công việc...',
              icon: Icons.work_outline,
              iconSize: 20.sp,
            ),
            SizedBox(height: 16.h),

            // Mô tả
            CustomTextFieldWithLabel(
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              controller: descriptionController,
              label: 'Mô tả công việc',
              hintText: 'Mô tả chi tiết công việc...',
              icon: Icons.description_outlined,
              iconSize: 20.sp,
              maxLines: 4,
            ),
            SizedBox(height: 16.h),

            // Yêu cầu
            CustomTextFieldWithLabel(
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
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // Dropdowns - Đặt trước để user chọn trước
            _buildDropdown(context, 'Loại công việc', workType, workTypes, onWorkTypeChanged, theme),
            SizedBox(height: 16.h),
            _buildDropdown(context, 'Thời gian làm việc', workSchedule, workSchedules, onWorkScheduleChanged, theme),
            SizedBox(height: 16.h),
            _buildCategoryDropdown(context, 'Danh mục công việc', categoryId, categories, onCategoryChanged, theme),
            SizedBox(height: 16.h),
            _buildDropdown(context, 'Trình độ kinh nghiệm', experienceLevel, experienceLevels, onExperienceChanged, theme),
            SizedBox(height: 24.h),

            // Section: Mức lương và lịch làm việc (render động theo workType và workSchedule)
            if (workType == 'Part-time' || workType == 'Temporary') ...[
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
                  title: "MỨC LƯƠNG VÀ LỊCH LÀM VIỆC",
                  icon: Icons.access_time_rounded,
                  iconColor: recruiterPrimary,
                  textColor: recruiterPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              // Lương động theo workType và workSchedule
              DynamicSalaryFields(
                workType: workType,
                workSchedule: workSchedule,
                hourlyRateController: hourlyRateController,
                dailyRateController: dailyRateController,
                labelTextColor: recruiterPrimary,
                prefixIconColor: recruiterPrimary,
                fillColor: recruiterPrimary.withValues(alpha: 0.05),
                borderColor: recruiterPrimary.withValues(alpha: 0.3),
                borderRadius: 14.r,
              ),
              SizedBox(height: 16.h),

              // Lịch làm việc động theo workType và workSchedule
              DynamicWorkScheduleFields(
                workType: workType,
                workSchedule: workSchedule,
                minHoursController: minHoursController,
                maxHoursController: maxHoursController,
                workDaysController: workDaysController,
                labelTextColor: recruiterPrimary,
                prefixIconColor: recruiterPrimary,
                fillColor: recruiterPrimary.withValues(alpha: 0.05),
                borderColor: recruiterPrimary.withValues(alpha: 0.3),
                borderRadius: 14.r,
              ),
              SizedBox(height: 24.h),
            ],

            // Location với nút lấy vị trí hiện tại
            LocationFieldWithCurrentLocation(
              controller: locationController,
              label: 'Địa điểm làm việc',
              hintText: 'Nhập địa điểm hoặc nhấn nút để lấy vị trí hiện tại',
              labelTextColor: recruiterPrimary,
              prefixIconColor: recruiterPrimary,
              fillColor: recruiterPrimary.withValues(alpha: 0.05),
              borderColor: recruiterPrimary.withValues(alpha: 0.3),
              borderRadius: 14.r,
              onLocationObtained: onLocationObtained,
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
            SizedBox(height: 16.h),

            SizedBox(height: 24.h),

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
                        onTap: onCreateJob,
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

  Widget _buildDropdown(BuildContext context, String label, String? value, List<String> items, ValueChanged<String> onChanged, ThemeData theme) {
    const recruiterPrimary = Color(0xFF1A237E);
    // Đảm bảo value hợp lệ - phải nằm trong items
    final validValue = (value != null && items.contains(value)) ? value : (items.isNotEmpty ? items.first : null);
    
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
              hint: items.isEmpty 
                  ? Text(
                      'Đang tải...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    )
                  : null,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: items.isEmpty ? null : (v) { 
                if (v != null) onChanged(v); 
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, String label, String? categoryId, List<JobCategoryModel> categories, ValueChanged<String> onChanged, ThemeData theme) {
    const recruiterPrimary = Color(0xFF1A237E);
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: categoryId,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_rounded, size: 22.sp, color: recruiterPrimary),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15.sp,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              hint: Text(
                categories.isEmpty ? 'Đang tải...' : 'Chọn danh mục',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              items: categories.map((category) => DropdownMenuItem(
                value: category.idCategory,
                child: Text(category.categoryName ?? ''),
              )).toList(),
              onChanged: categories.isEmpty ? null : (v) { 
                if (v != null) onChanged(v); 
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, VoidCallback onTap, ThemeData theme) {
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
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Chọn ngày',
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

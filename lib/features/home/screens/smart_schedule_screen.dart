import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/utils/input_validators.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/job/view_model/job_recommendation_view_model.dart';
import 'package:provider/provider.dart';

class SmartScheduleScreen extends StatefulWidget {
  final String userId;
  const SmartScheduleScreen({super.key, required this.userId});

  @override
  State<SmartScheduleScreen> createState() => _SmartScheduleScreenState();
}

class _SmartScheduleScreenState extends State<SmartScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  List<String> scheduleTypes = ['Toàn thời gian', 'Bán thời gian', 'Làm việc từ xa'];

  List<String> selectedScheduleTypes = [];

  List<String> weekdays = [ 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật' ];

  List<String> selectedWorkingDays = [];

  final TextEditingController _minHoursController = TextEditingController();
  final TextEditingController _maxHoursController = TextEditingController();
  final TextEditingController _areasController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final TextEditingController _clusterCountController = TextEditingController();
  final TextEditingController _takePerClusterController = TextEditingController();
  final TextEditingController _anchorLocationController = TextEditingController();

  bool includeFeaturedFirst = true;

  @override
  void dispose() {
    _minHoursController.dispose();
    _maxHoursController.dispose();
    _areasController.dispose();
    _skillsController.dispose();
    _maxDistanceController.dispose();
    _clusterCountController.dispose();
    _takePerClusterController.dispose();
    _anchorLocationController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final vm = context.read<JobRecommendationViewModel>();

      final inputData = {
        'userId': widget.userId,
        'preferredScheduleTypes': selectedScheduleTypes,
        'preferredWorkingDays': selectedWorkingDays,
        'preferredMinHoursPerWeek': int.tryParse(_minHoursController.text) ?? 0,
        'preferredMaxHoursPerWeek': int.tryParse(_maxHoursController.text) ?? 0,
        'preferredAreas': _areasController.text.split(',').map((e) => e.trim()).toList(),
        'preferredSkills': _skillsController.text.split(',').map((e) => e.trim()).toList(),
        'maxDistanceKm': int.tryParse(_maxDistanceController.text) ?? 0,
        'clusterCount': int.tryParse(_clusterCountController.text) ?? 0,
        'takePerCluster': int.tryParse(_takePerClusterController.text) ?? 0,
        'anchorLocation': _anchorLocationController.text,
        'includeFeaturedFirst': includeFeaturedFirst,
      };

      print("📌 Dữ liệu gửi API:");
      print(inputData);

      /// Gọi API tạo lịch thông minh
      await vm.createSmartSchedule(
        userId: widget.userId,
        preferredScheduleTypes: selectedScheduleTypes,
        preferredWorkingDays: selectedWorkingDays,
        preferredMinHoursPerWeek: double.tryParse(_minHoursController.text) ?? 0,
        preferredMaxHoursPerWeek: double.tryParse(_maxHoursController.text) ?? 0,
        preferredAreas: _areasController.text.split(',').map((e) => e.trim()).toList(),
        preferredSkills: _skillsController.text.split(',').map((e) => e.trim()).toList(),
        maxDistanceKm: double.tryParse(_maxDistanceController.text) ?? 0,
        clusterCount: int.tryParse(_clusterCountController.text) ?? 0,
        takePerCluster: int.tryParse(_takePerClusterController.text) ?? 0,
        anchorLocation: _anchorLocationController.text,
        includeFeaturedFirst: includeFeaturedFirst,
      );

      if (vm.errorMessage != null) {
        SnackbarApp.show(
          context,
          message: 'Không thể tạo lịch thông minh.',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
        return;
      } else if(vm.isSuccess){
        context.push(
          '/home/request-smart-shedule', 
          extra: {"schedule": vm.smartSchedule}
        );
      }
      SnackbarApp.show(
        context,
        message: 'Tạo lịch thông minh thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  }

  void _resetAllFields() {
    setState(() {
      selectedScheduleTypes.clear();
      selectedWorkingDays.clear();

      _minHoursController.clear();
      _maxHoursController.clear();
      _areasController.clear();
      _skillsController.clear();
      _maxDistanceController.clear();
      _clusterCountController.clear();
      _takePerClusterController.clear();
      _anchorLocationController.clear();

      includeFeaturedFirst = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<JobRecommendationViewModel>();
    return OverlayLoading(
      isLoading: vm.isLoading,
      child: Scaffold(
        appBar: CustomAppbarTitleLarge(
          title: 'Smart Schedule',
          actions: [
            GestureDetector(
              onTap: _resetAllFields,
              child: Icon(Icons.refresh, size: 24.sp),
            ),
            SizedBox(width: 16.w,)
          ],
        ),
        body: SafeArea(
          child: UnfocusWidget(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      SizedBox(height: 16.h,),
                      CircleAvatar(
                        radius: 45.r,
                        backgroundColor: BackgroundColors.backgroundBrandPrimary,
                        child: Icon(
                          Icons.smart_button_rounded,
                          size: 50.sp,
                          color: IconColors.iconBrandOnbrand,
                        ),
                      ),
                      SizedBox(height: 16.h,),
                      Text(
                        'Lịch thông minh',
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: TextColors.textBrandPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h,),
                      Text(
                        'Tạo lịch làm thông minh ngay lập tức!',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: TextColors.textDefaultPrimary.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h,),
                      /// SECTION 1 – Schedule Types
                      SectionTitle(
                        title: "Loại lịch làm việc",
                        icon: Icons.schedule_rounded,
                        iconColor: theme.primaryColor,
                        textColor: theme.primaryColor,
                      ),
                      SizedBox(height: 12.h),
              
                      SizedBox(
                        height: 45.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: scheduleTypes.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            final type = scheduleTypes[index];
                            final selected = selectedScheduleTypes.contains(type);
              
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selected
                                      ? selectedScheduleTypes.remove(type)
                                      : selectedScheduleTypes.add(type);
                                });
                              },
                              child: InfoChip(
                                label: type,
                                icon: Icons.schedule_rounded,
                                color: theme.primaryColor,
                                isHighlighted: selected,
                              ),
                            );
                          },
                        ),
                      ),
              
                      SizedBox(height: 22.h),
              
                      /// SECTION 2 – Ngày làm việc
                      SectionTitle(
                        title: "Ngày làm việc mong muốn",
                        icon: Icons.calendar_month_rounded,
                        iconColor: theme.primaryColor,
                        textColor: theme.primaryColor,
                      ),
                      SizedBox(height: 12.h),
              
                      SizedBox(
                        height: 45.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: weekdays.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            final day = weekdays[index];
                            final selected = selectedWorkingDays.contains(day);
              
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selected
                                      ? selectedWorkingDays.remove(day)
                                      : selectedWorkingDays.add(day);
                                });
                              },
                              child: InfoChip(
                                label: day,
                                icon: Icons.calendar_today_rounded,
                                color: theme.primaryColor,
                                isHighlighted: selected,
                              ),
                            );
                          },
                        ),
                      ),
              
                      SizedBox(height: 22.h),
              
                      /// SECTION 3 – Working hours
                      SectionTitle(
                        title: "Thời gian làm việc",
                        icon: Icons.timelapse_rounded,
                        iconColor: theme.primaryColor,
                        textColor: theme.primaryColor,
                      ),
                      SizedBox(height: 16.h),
              
                      CustomTextFieldWithLabel(
                        controller: _minHoursController,
                        label: 'Số giờ tối thiểu / tuần',
                        icon: Icons.timer_outlined,
                        hintText: 'Nhập số giờ',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                        keyboardType: TextInputType.number,
                        validator: (value) => InputValidators.validate(
                          value: value,
                          hintText: 'Số giờ tối thiểu',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: 12.h),
              
                      CustomTextFieldWithLabel(
                        controller: _maxHoursController,
                        label: 'Số giờ tối đa / tuần',
                        icon: Icons.timer_rounded,
                        hintText: 'Nhập số giờ',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                        keyboardType: TextInputType.number,
                        validator: (value) => InputValidators.validate(
                          value: value,
                          hintText: 'Số giờ tối đa',
                          keyboardType: TextInputType.number,
                        ),
                      ),
              
                      SizedBox(height: 22.h),
              
                      /// SECTION 4 – Skills & area
                      SectionTitle(
                        title: "Thông tin chuyên môn",
                        icon: Icons.work_history_rounded,
                        iconColor: theme.primaryColor,
                        textColor: theme.primaryColor,
                      ),
                      SizedBox(height: 16.h),
              
                      CustomTextFieldWithLabel(
                        controller: _areasController,
                        label: 'Khu vực mong muốn',
                        icon: Icons.location_on_outlined,
                        hintText: 'VD: Quận 1, Bình Thạnh,...',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SizedBox(height: 12.h),
              
                      CustomTextFieldWithLabel(
                        controller: _skillsController,
                        label: 'Kỹ năng',
                        icon: Icons.star_border_rounded,
                        hintText: 'VD: Python, SQL, AI,...',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
              
                      SizedBox(height: 22.h),
              
                      /// SECTION 5 – Suggestion algorithm
                      SectionTitle(
                        title: "Thuật toán gợi ý",
                        icon: Icons.scatter_plot_rounded,
                        iconColor: theme.primaryColor,
                        textColor: theme.primaryColor,
                      ),
                      SizedBox(height: 16.h),
              
                      CustomTextFieldWithLabel(
                        controller: _maxDistanceController,
                        label: 'Khoảng cách tối đa (km)',
                        icon: Icons.map_outlined,
                        keyboardType: TextInputType.number,
                        hintText: 'Ví dụ: 10',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SizedBox(height: 12.h),
              
                      CustomTextFieldWithLabel(
                        controller: _clusterCountController,
                        label: 'Số cụm',
                        icon: Icons.grid_view_rounded,
                        keyboardType: TextInputType.number,
                        hintText: 'Ví dụ: 3',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SizedBox(height: 12.h),
              
                      CustomTextFieldWithLabel(
                        controller: _takePerClusterController,
                        label: 'Số job mỗi cụm',
                        icon: Icons.workspaces_outline,
                        keyboardType: TextInputType.number,
                        hintText: 'Ví dụ: 5',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SizedBox(height: 12.h),
              
                      CustomTextFieldWithLabel(
                        controller: _anchorLocationController,
                        label: 'Vị trí anchor (lat,lng)',
                        icon: Icons.my_location_rounded,
                        hintText: 'VD: 10.123, 106.456',
                        labelTextColor: theme.hintColor.withValues(alpha: 0.5),
                        prefixIconColor: theme.hintColor.withValues(alpha: 0.7),
                        fillColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
              
                      SizedBox(height: 14.h),
              
                      SwitchListTile(
                        value: includeFeaturedFirst,
                        onChanged: (val) => setState(() => includeFeaturedFirst = val),
                        title: Text(
                          "Ưu tiên job nổi bật trước",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
              
                      SizedBox(height: 18.h),
                      CustomPrimaryButton(
                        onPressed: _onSave, 
                        text: "LƯU THÔNG TIN",
                      ),
              
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

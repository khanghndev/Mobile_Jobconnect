import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';

class FilterPanelWidget {
  static void show(
    BuildContext context, {
    required Map<String, List<String>> locationGroups,
    required List<String> jobTypes,
    required List<String> experienceLevels,
    required String selectedLocation,
    required String selectedJobType,
    required String selectedExperience,
    required double currentMinSalary,
    required double currentMaxSalary,
    required double maxSalary,
    required Function({
      required String location,
      required String jobType,
      required String experience,
      required double minSalary,
      required double maxSalary,
    }) onApply,
    required VoidCallback onResetFilters,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => _FilterBottomSheet(
        locationGroups: locationGroups,
        jobTypes: jobTypes,
        experienceLevels: experienceLevels,
        initialLocation: selectedLocation,
        initialJobType: selectedJobType,
        initialExperience: selectedExperience,
        initialMinSalary: currentMinSalary,
        initialMaxSalary: currentMaxSalary,
        maxSalary: maxSalary,
        onApply: onApply,
        onResetFilters: onResetFilters,
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Map<String, List<String>> locationGroups;
  final List<String> jobTypes;
  final List<String> experienceLevels;
  final String initialLocation;
  final String initialJobType;
  final String initialExperience;
  final double initialMinSalary;
  final double initialMaxSalary;
  final double maxSalary;
  final Function({
    required String location,
    required String jobType,
    required String experience,
    required double minSalary,
    required double maxSalary,
  }) onApply;
  final VoidCallback onResetFilters;

  const _FilterBottomSheet({
    required this.locationGroups,
    required this.jobTypes,
    required this.experienceLevels,
    required this.initialLocation,
    required this.initialJobType,
    required this.initialExperience,
    required this.initialMinSalary,
    required this.initialMaxSalary,
    required this.maxSalary,
    required this.onApply,
    required this.onResetFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedLocation;
  late String _selectedJobType;
  late String _selectedExperience;
  late double _currentMinSalary;
  late double _currentMaxSalary;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedJobType = widget.initialJobType;
    _selectedExperience = widget.initialExperience;
    _currentMinSalary = widget.initialMinSalary;
    _currentMaxSalary = widget.initialMaxSalary;
  }

  void _applyFilters() {
    widget.onApply(
      location: _selectedLocation,
      jobType: _selectedJobType,
      experience: _selectedExperience,
      minSalary: _currentMinSalary,
      maxSalary: _currentMaxSalary,
    );
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = 'Tất cả';
      _selectedJobType = 'Tất cả';
      _selectedExperience = 'Tất cả';
      _currentMinSalary = 0;
      _currentMaxSalary = widget.maxSalary;
    });
    widget.onResetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ Lọc',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 24.sp),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                    padding: EdgeInsets.all(8.w),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationFilter(theme),
                  SizedBox(height: 32.h),
                  _buildDivider(theme),
                  SizedBox(height: 32.h),
                  _buildFilterSection(
                    theme,
                    'Loại công việc',
                    Icons.work_outline_rounded,
                    widget.jobTypes,
                    _selectedJobType,
                    (value) => setState(() => _selectedJobType = value),
                  ),
                  SizedBox(height: 32.h),
                  _buildDivider(theme),
                  SizedBox(height: 32.h),
                  _buildFilterSection(
                    theme,
                    'Kinh nghiệm',
                    Icons.trending_up_rounded,
                    widget.experienceLevels,
                    _selectedExperience,
                    (value) => setState(() => _selectedExperience = value),
                  ),
                  SizedBox(height: 32.h),
                  _buildDivider(theme),
                  SizedBox(height: 32.h),
                  _buildSalaryFilter(theme),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: Icon(Icons.refresh_rounded, size: 20.sp),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      label: Text(
                        'Đặt Lại',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: Icon(Icons.check_rounded, size: 20.sp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      label: Text(
                        'Áp Dụng',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withValues(alpha: 0.1),
    );
  }

  Widget _buildLocationFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.location_on_rounded, 'Địa điểm'),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _buildFilterChip(
              theme,
              'Tất cả',
              _selectedLocation == 'Tất cả',
              () => setState(() => _selectedLocation = 'Tất cả'),
            ),
            ...widget.locationGroups.entries.expand((entry) {
              final city = entry.key;
              final districts = entry.value;
              return [
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Text(
                    city,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: districts.map((district) {
                    final full = '$district, $city';
                    return _buildFilterChip(
                      theme,
                      district,
                      _selectedLocation == full,
                      () => setState(() => _selectedLocation = full),
                    );
                  }).toList(),
                ),
              ];
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<String> options,
    String selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, icon, title),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: options.map((option) {
            final isSelected = selected == option;
            return _buildFilterChip(
              theme,
              option,
              isSelected,
              () => onChanged(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14.sp,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontSize: 14.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.3),
          width: selected ? 1.5 : 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      elevation: selected ? 2 : 0,
      showCheckmark: false,
    );
  }

  Widget _buildSalaryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.attach_money_rounded, 'Mức lương'),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: RangeSlider(
            values: RangeValues(_currentMinSalary, _currentMaxSalary),
            min: 0,
            max: widget.maxSalary,
            divisions: 100,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            labels: RangeLabels(
              _currentMinSalary == 0
                  ? 'Thoả thuận'
                  : FormatUtils.formatSalary(_currentMinSalary.toInt()),
              FormatUtils.formatSalary(_currentMaxSalary.toInt()),
            ),
            onChanged: (values) {
              setState(() {
                _currentMinSalary = values.start;
                _currentMaxSalary = values.end;
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSalaryChip(
              theme,
              _currentMinSalary == 0
                  ? 'Thoả thuận'
                  : FormatUtils.formatSalary(_currentMinSalary.toInt()),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 20.sp, color: theme.colorScheme.primary),
            _buildSalaryChip(
              theme,
              FormatUtils.formatSalary(_currentMaxSalary.toInt()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryChip(ThemeData theme, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

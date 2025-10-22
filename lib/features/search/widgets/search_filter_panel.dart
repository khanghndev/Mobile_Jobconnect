import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';

class FilterPanelWidget extends StatefulWidget {
  final Map<String, List<String>> locationGroups;
  final List<String> jobTypes;
  final List<String> experienceLevels;
  final Function({
    required String location,
    required String jobType,
    required String experience,
    required double minSalary,
    required double maxSalary,
  }) onApply;
  final VoidCallback onClose;
  final VoidCallback onResetFilters;

  const FilterPanelWidget({
    super.key,
    required this.locationGroups,
    required this.jobTypes,
    required this.experienceLevels,
    required this.onApply,
    required this.onClose, 
    required this.onResetFilters,
  });

  @override
  State<FilterPanelWidget> createState() => _FilterPanelWidgetState();
}

class _FilterPanelWidgetState extends State<FilterPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _panelAnimation;

  String _selectedLocation = 'Tất cả';
  String _selectedJobType = '';
  String _selectedExperience = '';
  final double _minSalary = 0;
  final double _maxSalary = 100000000;
  double _currentMinSalary = 0;
  double _currentMaxSalary = 100000000;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _panelAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApply(
      location: _selectedLocation,
      jobType: _selectedJobType,
      experience: _selectedExperience,
      minSalary: _currentMinSalary,
      maxSalary: _currentMaxSalary,
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
        ),
        SlideTransition(
          position: _panelAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 16,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Container(
                height: 0.75.sh,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bộ Lọc Nâng Cao',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: theme.iconTheme.color, size: 26.sp),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),
                    Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLocationFilter(theme),
                            SizedBox(height: 12.h),
                            Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                            _buildFilterSection(
                              'Loại công việc',
                              widget.jobTypes,
                              _selectedJobType,
                              (value) =>
                                  setState(() => _selectedJobType = value),
                            ),
                            SizedBox(height: 12.h),
                            Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                            _buildFilterSection(
                              'Kinh nghiệm',
                              widget.experienceLevels,
                              _selectedExperience,
                              (value) =>
                                  setState(() => _selectedExperience = value),
                            ),
                            SizedBox(height: 12.h),
                            Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                            _buildSalaryFilter(theme),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -3),
                          ),
                        ],
                        border: Border(
                          top: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.5)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onResetFilters,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.7),
                                  width: 1.5,
                                ),
                                padding:
                                    EdgeInsets.symmetric(vertical: 15.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Đặt Lại',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding:
                                    EdgeInsets.symmetric(vertical: 15.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Áp Dụng',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
          child: Text(
            'Địa điểm',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _buildChoiceChip(theme, 'Tất cả', _selectedLocation == 'Tất cả', () {
              setState(() => _selectedLocation = 'Tất cả');
            }),
            ...widget.locationGroups.entries.expand((entry) {
              final city = entry.key;
              final districts = entry.value;
              return [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    city,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      )),
                ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: districts.map((district) {
                    final full = '$district, $city';
                    return _buildChoiceChip(
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
      String title, List<String> options, String selected, Function(String) onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
          child: Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: options.map((option) {
            final isSelected = selected == option;
            return _buildChoiceChip(theme, option, isSelected, () {
              onChanged(option);
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(
      ThemeData theme, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor:
          theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.r),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.7)
              : theme.dividerColor.withValues(alpha: 0.7),
          width: selected ? 1.5 : 1.0,
        ),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      elevation: selected ? 2 : 0,
      showCheckmark: false,
    );
  }

  Widget _buildSalaryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
          child: Text('Mức lương',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        RangeSlider(
          values: RangeValues(_currentMinSalary, _currentMaxSalary),
          min: _minSalary,
          max: _maxSalary,
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
      ],
    );
  }
}

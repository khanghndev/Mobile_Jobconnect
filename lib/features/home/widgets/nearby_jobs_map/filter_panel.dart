import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SearchMode { radius, location }

class FilterPanel extends StatefulWidget {
  final SearchMode searchMode;
  final double radiusKm;
  final Function(SearchMode) onModeChanged;
  final Function(double) onRadiusChanged;
  final VoidCallback onApplyFilter;

  const FilterPanel({
    super.key,
    required this.searchMode,
    required this.radiusKm,
    required this.onModeChanged,
    required this.onRadiusChanged,
    required this.onApplyFilter,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final List<double> _radiusOptions = [1, 5, 10, 20, 50];
  double _tempRadius = 10;

  @override
  void initState() {
    super.initState();
    _tempRadius = widget.radiusKm;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            spreadRadius: 0,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          Container(
            width: 45.w,
            height: 5.5.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          // Header với toggle
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: theme.primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Bộ lọc tìm kiếm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20.r,
                ),
              ],
            ),
          ),
          Divider(height: 1.h, thickness: 1),
              
              // Toggle Mode
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeToggle(
                        context,
                        SearchMode.radius,
                        'Bán kính',
                        Icons.radio_button_checked_rounded,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildModeToggle(
                        context,
                        SearchMode.location,
                        'Địa điểm',
                        Icons.location_on_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              // Content based on mode
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: widget.searchMode == SearchMode.radius
                    ? _buildRadiusContent(theme, isDark)
                    : _buildLocationContent(theme),
                key: ValueKey(widget.searchMode),
              ),

          // Apply Button
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onRadiusChanged(_tempRadius);
                    widget.onApplyFilter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Áp dụng',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(
    BuildContext context,
    SearchMode mode,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = widget.searchMode == mode;

    return GestureDetector(
      onTap: () => widget.onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? theme.primaryColor
                  : theme.iconTheme.color?.withOpacity(0.6),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusContent(ThemeData theme, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bán kính tìm kiếm',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${_tempRadius.toInt()} km',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: theme.primaryColor.withOpacity(0.2),
              thumbColor: theme.primaryColor,
              overlayColor: theme.primaryColor.withOpacity(0.1),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
              trackHeight: 4.h,
            ),
            child: Slider(
              value: _tempRadius,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_tempRadius.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _tempRadius = value;
                  // Gọi callback để cập nhật vòng tròn real-time
                  widget.onRadiusChanged(value);
                });
              },
            ),
          ),
          SizedBox(height: 12.h),
          
          // Quick select buttons
          Text(
            'Chọn nhanh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _radiusOptions.map((radius) {
              final isSelected = (_tempRadius - radius).abs() < 0.5;
              return GestureDetector(
                onTap: () {
                  setState(() => _tempRadius = radius);
                  widget.onRadiusChanged(radius); // Cập nhật vòng tròn khi chọn quick button
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.dividerColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$radius km',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationContent(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm kiếm theo địa điểm',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20.sp,
                  color: theme.primaryColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Nhập địa điểm vào thanh tìm kiếm phía trên để tìm việc làm tại khu vực đó.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


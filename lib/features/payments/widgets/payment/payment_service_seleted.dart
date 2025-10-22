import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/section_title.dart';

class ServiceItem {
  final String name;
  final int price;
  final String duration;
  final IconData? icon; 

  ServiceItem({
    required this.name,
    required this.price,
    required this.duration,
    this.icon,
  });
}

class ServicesSummaryWidget extends StatelessWidget {
  final List<ServiceItem> selectedServices;
  final double totalAmount;

  const ServicesSummaryWidget({
    super.key,
    required this.selectedServices,
    required this.totalAmount,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TODO: Tiêu đề
            SectionTitle(
              title: "Dịch vụ đã chọn",
              fontSize: 22.sp,
              icon: Icons.check_box,
              iconColor: theme.iconTheme.color
            ),
            SizedBox(height: 20.h), 
            //TODO: Danh sách dịch vụ
            ...List.generate(selectedServices.length, (index) {
              final service = selectedServices[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == selectedServices.length - 1 ? 0 : 16.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //TODO: Icon
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        service.icon ?? Icons.category,
                        color: theme.colorScheme.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    //TODO: Tên và thời gian
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            service.duration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14.sp,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //TODO: Giá
                    Text(
                      FormatUtils.formatCurrency(service.price * 1.0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 20.h),
            Divider(
              color: theme.dividerColor,
              thickness: 1.5.h,
            ),
            SizedBox(height: 16.h),
            //TODO: Tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  FormatUtils.formatCurrency(totalAmount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
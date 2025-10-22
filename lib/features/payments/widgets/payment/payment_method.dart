import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}

class PaymentMethods extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final bool isDarkMode;
  final Function(String) onSelect;

  const PaymentMethods({
    super.key,
    required this.paymentMethods,
    required this.onSelect,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phương thức thanh toán',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20.h),
            ...List.generate(paymentMethods.length, (index) {
              final method = paymentMethods[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == paymentMethods.length - 1 ? 0 : 16.h,
                ),
                child: InkWell(
                  onTap: () => onSelect(method.id),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: method.isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        width: method.isSelected ? 2.w : 1.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      color: method.isSelected
                          ? theme.colorScheme.primary.withValues(alpha:
                              isDarkMode ? 0.1 : 0.05,
                            )
                          : theme.cardColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Icon(
                            method.icon,
                            color: method.isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                            size: 24.sp,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              method.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: method.isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16.sp,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (method.isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                              size: 24.sp,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

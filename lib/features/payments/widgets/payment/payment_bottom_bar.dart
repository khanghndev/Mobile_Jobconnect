import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/custom_primary_button.dart';

class PaymentBottomBar extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onPayment;

  const PaymentBottomBar({
    super.key,
    required this.totalAmount,
    required this.onPayment,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng thanh toán',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: theme.hintColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    FormatUtils.formatCurrency(totalAmount),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomPrimaryButton(
                onPressed: onPayment, 
                text: "Thanh toán ngay"
              ),
            )
          ],
        ),
      ),
    );
  }
}
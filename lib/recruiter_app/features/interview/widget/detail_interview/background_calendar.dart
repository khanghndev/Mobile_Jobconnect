import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_images.dart';

class BackgroundCalendar extends StatelessWidget {
  final Widget child;
  const BackgroundCalendar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.bgCalendarV2,
              fit: BoxFit.cover,
            ),
          ),
          child
        ],
      ),
    );
  }
}
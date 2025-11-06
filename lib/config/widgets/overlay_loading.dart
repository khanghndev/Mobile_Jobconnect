import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OverlayLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const OverlayLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child, 
        if (isLoading)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Center(
              child: SpinKitFadingCube(
                color: theme.primaryColor,
                size: 40.sp,
              ),
            ),
          ),
      ],
    );
  }
}
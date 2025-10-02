import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAdaptiveTapEffect extends StatelessWidget {
  const CustomAdaptiveTapEffect({
    super.key,
    required this.child,
    this.onPressed,
    this.alignment = Alignment.center, 
    this.isOpacity,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final AlignmentGeometry alignment;
  final bool? isOpacity;

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chạy trên nền tảng nào
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // If current platform is iOS
    if (isIOS) {
      return CupertinoButton(
        color: Colors.transparent,
        alignment: alignment,
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        pressedOpacity: isOpacity == true ? 1.0 : null,
        child: child,
      );
    }

    // If current platform is android
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        alignment: alignment,
        elevation: 0,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        overlayColor: isOpacity == true ? Colors.transparent : null,
      ),
      child: child,
    );
  }
}

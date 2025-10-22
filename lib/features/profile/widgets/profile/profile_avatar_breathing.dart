import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAvatarBreathing extends StatefulWidget {
  final double radius;
  final ImageProvider backgroundImage;
  final Widget? child;
  final List<Color> borderColors;
  final Duration duration;

  const ProfileAvatarBreathing({
    super.key,
    required this.radius,
    required this.backgroundImage,
    this.child,
    this.borderColors = const [Colors.cyanAccent, Colors.purpleAccent],
    this.duration = const Duration(seconds: 3),
  });

  @override
  _ProfileAvatarBreathingState createState() => _ProfileAvatarBreathingState();
}

class _ProfileAvatarBreathingState extends State<ProfileAvatarBreathing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: widget.borderColors,
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[200],
            backgroundImage: widget.backgroundImage,
            child: widget.child,
          ),
        );
      },
    );
  }
}

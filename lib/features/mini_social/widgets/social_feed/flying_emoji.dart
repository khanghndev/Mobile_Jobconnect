import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class FlyingEmoji extends StatefulWidget {
  final String emoji;
  const FlyingEmoji({super.key, required this.emoji});

  @override
  State<FlyingEmoji> createState() => _FlyingEmojiState();
}

class _FlyingEmojiState extends State<FlyingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double randomX;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: -200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    randomX = Random().nextDouble() * 100 - 50; // lệch trái/phải
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      bottom: 80,
      left: size.width * 0.45,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(randomX, _animation.value),
            child: Opacity(
              opacity: 1 - _controller.value,
              child: Text(
                widget.emoji,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textDefaultPrimary,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

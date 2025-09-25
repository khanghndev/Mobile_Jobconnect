import 'package:flutter/material.dart';

class GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const GlowCircle({super.key, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity),
            blurRadius: size / 2.5,
            spreadRadius: size / 10,
          )
        ],
      ),
    );
  }
}

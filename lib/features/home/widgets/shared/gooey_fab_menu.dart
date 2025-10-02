import 'dart:math';
import 'package:flutter/material.dart';

class GooeyFABMenu extends StatefulWidget {
  final List<GooeyFABItem> items;

  const GooeyFABMenu({super.key, required this.items});

  @override
  State<GooeyFABMenu> createState() => _GooeyFABMenuState();
}

class _GooeyFABMenuState extends State<GooeyFABMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  void _toggleMenu() {
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final double angle = 90 / (widget.items.length - 1) * index;
          final double rad = angle * pi / 180;

          // delay cho từng nút để bung ra lần lượt
          final intervalStart = index * 0.1;
          final intervalEnd = intervalStart + 0.4;

          final animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOut),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              final offsetX = cos(rad) * 100 * animation.value;
              final offsetY = sin(rad) * 100 * animation.value;

              return Positioned(
                right: 20 + offsetX,
                bottom: 20 + offsetY,
                child: Transform.scale(
                  scale: animation.value,
                  child: Opacity(
                    opacity: animation.value.clamp(0.0, 1.0),
                    child: FloatingActionButton(
                      heroTag: null,
                      mini: true,
                      backgroundColor: item.color,
                      onPressed: () {
                        item.onTap();
                        _toggleMenu();
                      },
                      child: Icon(item.icon),
                    ),
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: _toggleMenu,
            child: Icon(_isOpen ? Icons.close : Icons.menu),
          ),
        ),
      ],
    );
  }
}

class GooeyFABItem {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  GooeyFABItem({
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

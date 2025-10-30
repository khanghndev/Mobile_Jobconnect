import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReactionPicker extends StatelessWidget {
  final List<String> reactions;
  final ValueChanged<String> onSelected;

  const ReactionPicker({
    super.key,
    this.reactions = const ['😂', '😍', '😢', '😡', '👍'],
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    List<String> reactions = const ['😂', '😍', '😢', '😡', '👍'],
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Center(
        child: ReactionPicker(
          reactions: reactions,
          onSelected: (emoji) {
            Navigator.of(ctx).pop(emoji);
          },
        ),
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reactions
              .map(
                (e) => GestureDetector(
                  onTap: () => onSelected(e),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(e, style: TextStyle(fontSize: 28.sp)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
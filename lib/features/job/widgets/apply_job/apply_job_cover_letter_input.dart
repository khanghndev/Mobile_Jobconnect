import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyJobCoverLetterInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;

  const ApplyJobCoverLetterInput({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 4,
    this.maxLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: theme.cardColor,
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? "Viết một vài dòng giới thiệu bản thân, kinh nghiệm và lý do bạn phù hợp với vị trí này...",
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor.withValues(alpha: 0.5),
          ),
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
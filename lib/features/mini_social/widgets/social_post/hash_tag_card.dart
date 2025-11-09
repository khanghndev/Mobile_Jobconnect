import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';

class HashtagCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback? onSend;
  final VoidCallback? onTap;

  const HashtagCard({
    super.key,
    required this.controller,
    required this.onClose,
    this.onSend,
    this.onTap,
  });

  @override
  State<HashtagCard> createState() => _HashtagCardState();
}

class _HashtagCardState extends State<HashtagCard> {
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_textListener);
  }

  void _textListener() {
    final hasTextNow = widget.controller.text.isNotEmpty;
    if (hasTextNow != _hasText) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hashtag',
                style: TextStyle(
                  color: theme.hintColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
              TextButton(
                onPressed: widget.onClose,
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          CustomTextFieldWithLabel(
            controller: widget.controller,
            label: 'Hashtag',
            hintText: 'Nhập hashtag...',
            icon: Icons.tag,
            labelTextColor: theme.hintColor.withValues(alpha: 0.5),
            hintTextColor: theme.hintColor.withValues(alpha: 0.5),
            suffixIcon: _hasText ? Icons.send : Icons.close,
            onSuffixIconTap: _hasText
                ? widget.onSend
                : () => widget.controller.clear(),
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }
}
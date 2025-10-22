import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'custom_search_bar.dart'; 

class CustomSearchAdd extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String>? onCheck;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final Function(String)? onChanged;
  final VoidCallback onAdd;

  const CustomSearchAdd({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onCheck,
    this.onClear, 
    this.onChanged, 
    this.onSubmitted,
    required this.onAdd,
  });

  @override
  State<CustomSearchAdd> createState() => _CustomSearchAddState();
}

class _CustomSearchAddState extends State<CustomSearchAdd> {
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_updateState);
    widget.controller.addListener(_updateState);
  }

  void _updateState() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  void _handleIconPress() {
    if (_isFocused) {
      widget.onCheck!(widget.controller.text);
    } else if (_hasText) {
      widget.onClear?.call();
      widget.controller.clear();
      setState(() {});
    } else {
      widget.onAdd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search
        Expanded(
          child: CustomSearchBar(
            hintText: widget.hintText,
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
        SizedBox(width: 8.w),
        AnimatedScale(
          scale: _isFocused || _hasText ? 0.8 : 1.0, 
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: BackgroundColors.backgroundButtonPrimary,
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: IconButton(
              onPressed: _handleIconPress,
              icon: Icon(
                _isFocused
                    ? Icons.check
                    : (_hasText ? Icons.clear : Icons.add),
                size: 22.sp,
                color: IconColors.iconButtonPrimary,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_updateState);
    widget.controller.removeListener(_updateState);
    super.dispose();
  }
}

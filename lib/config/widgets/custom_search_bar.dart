import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? autofocus;
  final bool? enabled;
  final String? hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus,
    this.enabled,
    this.hintText,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Lắng nghe thay đổi text
    _controller.addListener(_updateClearIconVisibility);

    // Lắng nghe focus
    _focusNode.addListener(_updateClearIconVisibility);
  }

  void _updateClearIconVisibility() {
    setState(() {
      // Click + có chữ
      _showClearIcon = _focusNode.hasFocus && _controller.text.isNotEmpty;
      // Click
      // _showClearIcon = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateClearIconVisibility);
    _focusNode.removeListener(_updateClearIconVisibility);
    // Nếu controller hoặc focusNode được tạo nội bộ thì phải dispose luôn
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: ElementColors.quaternary,
          borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // * Leading
          Icon(
            Icons.search,
            size: 22.sp,
            color: IconColors.iconDefaultSecondary,
          ),

          // Spacing
          SizedBox(
            width: 4.w,
          ),

          // * TextField
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus ?? false,
              enabled: widget.enabled ?? true,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.all(0),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  hintText: _focusNode.hasFocus ? null : widget.hintText,
                  suffixIcon: _showClearIcon
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            // _updateClearIconVisibility();
                            if (widget.onChanged != null) {
                              widget.onChanged!('');
                            }
                          },
                          child: Icon(Icons.cancel,
                              size: 20.sp,
                              color: IconColors.iconDefaultSecondary),
                        )
                      : null,
                  suffixIconConstraints: BoxConstraints(
                    minHeight: 20.h,
                    minWidth: 20.w,
                  ),
                  hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: TextColors.textDefaultSecondary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.43.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

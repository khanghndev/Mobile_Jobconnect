import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class ReactionBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onEmojiTap;

  const ReactionBar({
    super.key,
    required this.controller,
    required this.onEmojiTap,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SafeArea(
        child: Row(
          children: [
            // TextField
            Expanded(
              flex: _isFocused ? 3 : 1, // khi focus thì dài ra
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: TextColors.textBrandOnbrand,
                    ),
                decoration: InputDecoration(
                  hintText: "Gửi tin nhắn...",
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.textBrandOnbrand
                      ),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
                onSubmitted: (text) {
                  debugPrint("Tin nhắn: $text");
                  widget.controller.clear();
                },
              ),
            ),

            // Nút gửi
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              iconSize: 22.sp,
              onPressed: () {
                debugPrint("Tin nhắn: ${widget.controller.text}");
                widget.controller.clear();
              },
            ),

            // Emoji (ẩn khi focus để TextField full hàng)
            if (!_isFocused)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var emoji in ["❤️", "😆", "😮", "😢", "👍", "👎"])
                        GestureDetector(
                          onTap: () => widget.onEmojiTap(emoji),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 6.w),
                            child: Text(
                              emoji,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w600,
                                    color: TextColors.textDefaultPrimary,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

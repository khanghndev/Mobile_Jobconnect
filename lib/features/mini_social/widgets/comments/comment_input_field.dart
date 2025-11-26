import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CommentInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback? onSend;
  final ValueChanged<String>? onChanged;
  final Function(String? imagePath)? onImageSelected;
  final Function(String? icon)? onIconSelected;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.hasText,
    required this.onSend,
    this.onChanged,
    this.onImageSelected,
    this.onIconSelected,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  String? _selectedImagePath;
  String? _selectedIcon;
  
  // List các icon emoji phổ biến
  final List<String> _icons = [
    '👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '💯',
    '🎉', '👏', '😍', '🤔', '😎', '🥳', '💪', '✨'
  ];

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn icon',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                    widget.onIconSelected?.call(icon);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon 
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
    widget.onImageSelected?.call(null);
  }

  void _removeIcon() {
    setState(() {
      _selectedIcon = null;
    });
    widget.onIconSelected?.call(null);
  }

  bool get _hasContent => 
      widget.controller.text.trim().isNotEmpty || 
      _selectedImagePath != null || 
      _selectedIcon != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hiển thị ảnh đã chọn
        if (_selectedImagePath != null)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    File(_selectedImagePath!),
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Hiển thị icon đã chọn
        if (_selectedIcon != null)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedIcon!,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: _removeIcon,
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Input field
        Row(
          children: [
            // Camera button
            GestureDetector(
              onTap: _pickImage,
              child: Icon(
                Icons.camera_alt_outlined,
                size: 24.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(width: 8.w),
            
            Expanded(
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 3,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  setState(() {}); // Rebuild để cập nhật nút send
                },
                decoration: InputDecoration(
                  hintText: "Nhập bình luận...",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon picker button
                      GestureDetector(
                        onTap: _showIconPicker,
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.grey[700],
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            
            // Send button
            IconButton(
              onPressed: _hasContent ? widget.onSend : null,
              icon: Icon(
                Icons.send,
                color: _hasContent ? Colors.blue : Colors.grey,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

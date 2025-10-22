import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EditCVNameDialog extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final void Function(String newName)? onConfirm; // ✅ callback mới

  const EditCVNameDialog({
    super.key,
    required this.controller,
    required this.formKey,
    this.onConfirm, // ✅ optional callback
  });

  @override
  State<EditCVNameDialog> createState() => _EditCVNameDialogState();
}

class _EditCVNameDialogState extends State<EditCVNameDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.drive_file_rename_outline_rounded,
            color: theme.primaryColor,
          ),
          SizedBox(width: 10.w),
          const Text(
            'Chỉnh Sửa Tên CV',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Nhập tên file mới",
            helperText: "Phần mở rộng (.pdf, .docx) sẽ được giữ nguyên.",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Tên file không được để trống'
              : null,
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 10.h,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'HỦY',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              final newName = widget.controller.text.trim();
              context.pop(); 
              if (widget.onConfirm != null) {
                widget.onConfirm!(newName); 
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: const Text(
            'LƯU',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

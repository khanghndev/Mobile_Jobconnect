import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/glass_card.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/glow_circle.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/header_card.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/reason_wrap.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/section_title.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/submit_button.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';

// Tạo model đơn giản
class ReportPost {
  final String userName;
  final String authorName;
  final String? thumbnailUrl;
  final String reason;
  final String? details;

  ReportPost({
    required this.userName,
    required this.authorName,
    this.thumbnailUrl,
    required this.reason,
    this.details,
  });

  @override
  String toString() {
    return '''
ReportPost(
  userName: $userName,
  authorName: $authorName,
  thumbnailUrl: $thumbnailUrl,
  reason: $reason,
  details: $details
)''';
  }
}

class ReportPostScreen extends StatefulWidget {
  final String userName;
  final String authorName;
  final String? thumbnailUrl;

  const ReportPostScreen({
    super.key,
    required this.userName,
    required this.authorName,
    this.thumbnailUrl,
  });

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

class _ReportPostScreenState extends State<ReportPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsCtrl = TextEditingController();
  String? _selectedReason;
  bool _submitting = false;

  final _reasons = const [
    'Nội dung sai sự thật',
    'Spam / Quảng cáo',
    'Ngôn từ thù ghét',
    'Lừa đảo',
    'Tuyển dụng ảo',
    'Nội dung không phù hợp',
    'Khác',
  ];

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() != true || _selectedReason == null) {
      SnackbarApp.show(
        context,
        title: "Thiếu thông tin",
        message: "Vui lòng chọn lý do báo cáo",
        backgroudColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }

    setState(() => _submitting = true);

    final report = ReportPost(
      userName: widget.userName,
      authorName: widget.authorName,
      thumbnailUrl: widget.thumbnailUrl,
      reason: _selectedReason!,
      details: _detailsCtrl.text.trim().isEmpty ? null : _detailsCtrl.text.trim(),
    );

    // In ra console (sau này bạn thay bằng API call)
    debugPrint(report.toString());

    await Future.delayed(const Duration(seconds: 1)); // giả lập gửi server

    setState(() => _submitting = false);

    SnackbarApp.show(
      context,
      title: "Thành công",
      message: "Báo cáo đã được gửi",
      backgroudColor: BackgroundColors.backgroundSuccessPrimary,
    );

    context.pop(); // quay lại trang trước
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Báo cáo bài viết',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Gradient nền
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha:0.6),
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -60.h, right: -60.w, child: GlowCircle(size: 280.w, opacity: 0.25)),
          Positioned(top: 60.h, left: -40.w, child: GlowCircle(size: 200.w, opacity: 0.2)),

          // Nội dung
          UnfocusWidget(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),
                    HeaderCard(
                      title: 'Bạn đang báo cáo',
                      subtitle: widget.userName,
                      author: widget.authorName,
                      thumbnailUrl: widget.thumbnailUrl,
                    ),
                    SizedBox(height: 16.h),
                    const SectionTitle(icon: Icons.flag_rounded, text: 'Chọn lý do'),
                    SizedBox(height: 10.h),
                    ReasonWrap(
                      reasons: _reasons,
                      selected: _selectedReason,
                      onSelected: (r) => setState(() => _selectedReason = r),
                    ),
                    SizedBox(height: 18.h),
                    const SectionTitle(icon: Icons.edit_note_rounded, text: 'Mô tả chi tiết'),
                    SizedBox(height: 10.h),
                    GlassCard(
                      isPadding: false,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _detailsCtrl,
                          maxLines: null,
                          minLines: 6,
                          maxLength: 5000,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Hãy mô tả vấn đề, dẫn chứng, link liên quan (nếu có)...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha:0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
                            ),
                            contentPadding: EdgeInsets.all(14.w),
                            counterText: '',
                          ),
                          validator: (v) {
                            if ((_selectedReason == 'Khác') &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Vui lòng mô tả khi chọn lý do "Khác".';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SubmitButton(
                      text: 'Gửi báo cáo',
                      loading: _submitting,
                      onPressed: _submitting ? null : _handleSubmit,
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Text(
                        'Báo cáo của bạn sẽ được xử lý trong thời gian sớm nhất.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.redAccent.withValues(alpha:0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

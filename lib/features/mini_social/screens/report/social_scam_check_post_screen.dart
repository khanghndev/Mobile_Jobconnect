import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/glass_card.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/glow_circle.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/section_title.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/submit_button.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';

class ScamCheckPostScreen extends StatefulWidget {
  const ScamCheckPostScreen({super.key});

  @override
  State<ScamCheckPostScreen> createState() => _ScamCheckPostScreenState();
}

class _ScamCheckPostScreenState extends State<ScamCheckPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkCtrl = TextEditingController();

  bool _loading = false;
  String? _summaryResult; // Kết luận tổng quát
  List<String> _details = []; // Các dấu hiệu cụ thể

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCheck() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _loading = true;
      _summaryResult = null;
      _details = [];
    });

    // 🚀 Giả lập phân tích ML
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _loading = false;
      _summaryResult = "Có dấu hiệu lừa đảo 🚨";
      _details = [
        "• Link rút gọn hoặc khả nghi (bit.ly, tinyurl, …)",
        "• Nội dung yêu cầu chuyển tiền đặt cọc trước",
        "• Hứa hẹn công việc lương cao không yêu cầu kỹ năng",
        "• Không có thông tin công ty rõ ràng",
      ];
      // Nếu muốn test an toàn thì đổi sang:
      // _summaryResult = "Bài viết có vẻ an toàn ✅";
      // _details = ["Không phát hiện dấu hiệu bất thường"];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Kiểm tra bài viết',
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
          // Nền gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha:0.2),
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -60.h, right: -60.w, child: GlowCircle(size: 280.w, opacity: 0.25)),
          Positioned(top: 80.h, left: -40.w, child: GlowCircle(size: 200.w, opacity: 0.2)),

          // Nội dung
          UnfocusWidget(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),
                    const SectionTitle(icon: Icons.link_rounded, text: 'Nhập link bài viết'),

                    SizedBox(height: 10.h),
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _linkCtrl,
                          decoration: const InputDecoration(
                            hintText: "Dán link bài viết tại đây...",
                            border: InputBorder.none,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Vui lòng nhập link";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    SubmitButton(
                      text: "Phân tích",
                      loading: _loading,
                      onPressed: _loading ? null : _handleCheck,
                    ),

                    if (_summaryResult != null) ...[
                      SizedBox(height: 24.h),
                      const SectionTitle(icon: Icons.analytics_outlined, text: 'Kết quả phân tích'),
                      SizedBox(height: 10.h),

                      // Kết luận
                      GlassCard(
                        child: Text(
                          _summaryResult!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _summaryResult!.contains("lừa đảo")
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Các dấu hiệu chi tiết
                      ..._details.map((d) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _summaryResult!.contains("lừa đảo")
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle,
                                  size: 18.sp,
                                  color: _summaryResult!.contains("lừa đảo")
                                      ? Colors.redAccent
                                      : Colors.green,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    d,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: 20.h),
                      Center(
                        child: Text(
                          'Kết quả phân tích chỉ mang tính tham khảo.\nHãy cẩn thận trước khi tin tưởng bài viết.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.redAccent.withValues(alpha:0.8),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SubmitButton(
                        text: "Báo cáo bài viết",
                        loading: false,
                        onPressed: () {
                          context.push("/report");
                        },
                      ),
                      SizedBox(height: 12.h),
                      SubmitButton(
                        icon: Icons.home,
                        text: "Quay về trang chủ",
                        loading: false,
                        onPressed: () {
                          context.push("/social-feed");
                        },
                      ),
                    ],

                    SizedBox(height: 20.h),
                    
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

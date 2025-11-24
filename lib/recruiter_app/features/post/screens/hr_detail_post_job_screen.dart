import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class HrDetailPostJobScreen extends StatelessWidget {
  final JobPostingModel jobPosting;

  const HrDetailPostJobScreen({super.key, required this.jobPosting});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    const primaryColor = Color(0xFF2563EB);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Chi tiết tin tuyển dụng',
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.info, "Thông tin chung"),
              _infoRow("Tiêu đề", jobPosting.title),
              _infoRow("Mức lương", "${jobPosting.salary} VND"),
              _infoRow("Địa điểm", jobPosting.location),
              _infoRow("Hình thức làm việc", jobPosting.workType),
              _infoRow("Kinh nghiệm", jobPosting.experienceLevel),
              _infoRow("Hạn nộp hồ sơ",
                  dateFormat.format(jobPosting.applicationDeadline ?? DateTime.now())),
              const Divider(height: 30),

              _sectionHeader(Icons.description, "Mô tả công việc"),
              _textBox(jobPosting.description ?? "Không có mô tả"),

              _sectionHeader(Icons.rule, "Yêu cầu"),
              _textBox(jobPosting.requirements ?? "Không có yêu cầu"),

              _sectionHeader(Icons.card_giftcard, "Quyền lợi"),
              _textBox(jobPosting.benefits ?? "Không có thông tin quyền lợi"),

              const Divider(height: 30),
              _sectionHeader(Icons.schedule, "Thông tin thời gian"),
              _infoRow("Ngày đăng", dateFormat.format(jobPosting.createdAt ?? DateTime.now())),
              _infoRow("Cập nhật gần nhất",
                  dateFormat.format(jobPosting.updatedAt?? DateTime.now())),

              if (jobPosting.isFeatured == 1) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text(
                        'Tin nổi bật',
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Row(
                children: [
                  // Expanded(
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) =>
                  //               HrEditDetailPostJobScreen(jobPosting: jobPosting),
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF2563EB),
                  //       padding: const EdgeInsets.symmetric(vertical: 14),
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10)),
                  //     ),
                  //     icon: const Icon(Icons.edit, color: Colors.white,),
                  //     label: const Text(
                  //       "Sửa tin",
                  //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  //     ),
                  //   ),
                  // ),
                  
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "Quay lại",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2563EB), size: 22.sp),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18.sp, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15.5, color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textBox(String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 15.5, height: 1.5),
      ),
    );
  }
}

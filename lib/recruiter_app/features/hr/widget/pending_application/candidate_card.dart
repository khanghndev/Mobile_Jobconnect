import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class CandidateCard extends StatelessWidget {
  final UserModel account;
  final CandidateInfoModel candidate;
  final JobApplicationModel application;
  final JobPostingModel job;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetail;

  const CandidateCard({
    super.key,
    required this.account,
    required this.candidate,
    required this.application,
    required this.job,
    this.onReject,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Tên + Vị trí
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    account.userName.isNotEmpty
                        ? account.userName[0].toUpperCase()
                        : '?',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.userName,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        candidate.workPosition ?? 'Chưa cập nhật vị trí',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Thông tin cơ bản
            RowInfo(icon: Icons.school_outlined, text: candidate.universityName ?? 'Chưa cập nhật trường'),
            SizedBox(height: 6.h),
            RowInfo(icon: Icons.star_outline, text: 'Điểm đánh giá: ${candidate.ratingScore?.toStringAsFixed(1) ?? 'Chưa có'}'),
            SizedBox(height: 6.h),
            RowInfo(icon: Icons.work_outline, text: 'Kinh nghiệm: ${candidate.experienceYears ?? 0} năm'),
            SizedBox(height: 6.h),
            RowInfo(icon: Icons.location_on_outlined, text: 'Vị trí mong muốn: ${candidate.workPosition ?? 'Chưa cập nhật'}'),
            SizedBox(height: 12.h),

            // Kỹ năng
            if ((candidate.skills ?? '').isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kỹ năng:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: candidate.skills!.split(',').map((skill) {
                      return Chip(
                        label: Text(
                          skill.trim(),
                          style: textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                        ),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),

            // Thông báo ứng tuyển
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.blue, size: 18.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Ứng viên đã ứng tuyển ngày ${application.submittedAt.toLocal().toString().split(' ')[0]} vào vị trí ${job.title}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ButtonPrimaryGradient(
                    text: 'Chi tiết', 
                    onPressed: () => onViewDetail,
                  ),
                ),
                SizedBox(width: 8.w),
                CustomButtonBorder(title: 'Từ chối', onPressed: () => onReject),
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: Icon(Icons.close, size: 16.sp, color: Colors.red),
                  label: Text('Từ chối', style: textTheme.labelLarge?.copyWith(fontSize: 14.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget helper để giảm trùng lặp
class RowInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const RowInfo({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 18.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

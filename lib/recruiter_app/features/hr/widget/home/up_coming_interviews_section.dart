import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/model/interview_schedule_model.dart';

class UpComingInterviewsSection extends StatelessWidget {
  final List<InterviewScheduleModel> upcomingInterviewSchedulesList;
  final List<UserModel> accountInterviewList;
  final List<CandidateInfoModel>? candidateInterviewList;
  final void Function()? onViewAll;

  // Sinh màu avatar 1 lần cho mỗi user
  final Map<String, Color> avatarColors = {};

  UpComingInterviewsSection({
    super.key,
    required this.upcomingInterviewSchedulesList,
    required this.accountInterviewList,
    this.candidateInterviewList,
    this.onViewAll,
  }) {
    // Tạo màu avatar cho từng user
    for (var account in accountInterviewList) {
      avatarColors[account.idUser] = _getRandomColor();
    }
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  String _formatHourWithAmPm(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String amPm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $amPm';
  }

  String _getRelativeDateLabel(DateTime inputDate) {
    DateTime today = DateTime.now();
    DateTime t = DateTime(today.year, today.month, today.day);
    DateTime d = DateTime(inputDate.year, inputDate.month, inputDate.day);
    int diff = d.difference(t).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff == -1) return 'Hôm qua';
    if (diff > 1) return '$diff ngày nữa';
    return 'Đã qua ${-diff} ngày';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const recruiterPrimary = Color(0xFF1A237E);
    
    if (upcomingInterviewSchedulesList.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 48.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Không có lịch phỏng vấn sắp tới',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingInterviewSchedulesList.length > 3 ? 3 : upcomingInterviewSchedulesList.length,
              separatorBuilder: (_, __) => Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  height: 1.h,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
              ),
              itemBuilder: (context, index) {
                final schedule = upcomingInterviewSchedulesList[index];
                final account = accountInterviewList[index];
                final candidate = candidateInterviewList?[index];
                return _InterviewItem(
                  userName: account.userName,
                  position: candidate?.workPosition ?? '',
                  hour: _formatHourWithAmPm(schedule.interviewDate),
                  date: _getRelativeDateLabel(schedule.interviewDate),
                  avatarColor: avatarColors[account.idUser]!,
                );
              },
            ),
            if (upcomingInterviewSchedulesList.length > 3) ...[
              SizedBox(height: 16.h),
              Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.1)),
              SizedBox(height: 16.h),
            ],
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Xem tất cả lịch phỏng vấn',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterviewItem extends StatelessWidget {
  final String userName;
  final String position;
  final String hour;
  final String date;
  final Color avatarColor;

  const _InterviewItem({
    required this.userName,
    required this.position,
    required this.hour,
    required this.date,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const recruiterPrimary = Color(0xFF1A237E);

    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.2),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: avatarColor.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              userName.split(' ').isNotEmpty 
                  ? userName.split(' ').last[0].toUpperCase()
                  : userName[0].toUpperCase(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: recruiterPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      position.isNotEmpty ? position : 'Chưa có vị trí',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: recruiterPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: recruiterPrimary.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14.sp,
                    color: recruiterPrimary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    hour,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: recruiterPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                date,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

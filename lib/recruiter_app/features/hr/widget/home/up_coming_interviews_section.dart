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
    if (upcomingInterviewSchedulesList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Center(
                child: Text(
                  'Không có lịch phỏng vấn sắp tới',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingInterviewSchedulesList.length,
                  separatorBuilder: (_, __) => Column(
                    children: [
                      SizedBox(height: 12.h),
                      Divider(height: 1.h),
                      SizedBox(height: 12.h),
                    ],
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
                SizedBox(height: 24.h),
                OutlinedButton(
                  onPressed: onViewAll,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: Text(
                    'Xem tất cả lịch phỏng vấn',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: avatarColor.withOpacity(0.2),
          child: Text(
            userName.split(' ').last,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                position,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hour,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              date,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

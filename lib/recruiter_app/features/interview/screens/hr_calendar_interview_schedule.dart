import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_detail_interview_schedule.dart';

class HrCalendarInterviewSchedule extends StatefulWidget {
  final String idUser;
  final List<InterviewScheduleModel> interviews;
  final List<JobPostingModel> jobPostingsList;
  const HrCalendarInterviewSchedule({
    super.key, 
    required this.idUser, 
    required this.interviews, required this.jobPostingsList
  });

  @override
  State<HrCalendarInterviewSchedule> createState() => _HrCalendarInterviewScheduleState();
}

class _HrCalendarInterviewScheduleState extends State<HrCalendarInterviewSchedule> with AutomaticKeepAliveClientMixin {
  final _monthViewKey = GlobalKey<MonthViewState>();
  late EventController<Object?> _eventController;
  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _eventController = EventController<Object?>();

    // Chuyển từ InterviewScheduleModel sang CalendarEventData
    final events = widget.interviews.map((interview) {
      return CalendarEventData(
        date: interview.interviewDate,
        title: 'Phỏng vấn ${interview.interviewMode}', 
        color: Colors.blueAccent, 
        event: interview,
      );
    }).toList();

    _eventController.addAll(events);
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      body: Stack(
        children: [
          UnfocusWidget(
            child: SafeArea(
              minimum: EdgeInsets.only(left: 16.w, right: 16.w, top: 130.h, bottom: 16.h),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: CalendarControllerProvider<Object?>(
                  controller: _eventController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.w, sigmaY: 5.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: MonthView(
                          key: _monthViewKey,
                          minMonth: DateTime(2000, 1),
                          maxMonth: DateTime(currentMonth.year + 10, 12),
                          startDay: WeekDays.monday,
                          initialMonth: currentMonth,
                          cellAspectRatio: isTablet ? 0.65 : 0.45,
                          borderSize: 0.5.w,
                          borderColor: Colors.grey.shade300,
                          weekDayBuilder: (int weekDayIndex) {
                            const customWeekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                            const recruiterPrimary = Color(0xFF1A237E);
                            return Container(
                              decoration: BoxDecoration(
                                color: recruiterPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                  child: Text(
                                    customWeekDays[weekDayIndex],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                      color: recruiterPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                           cellBuilder: (DateTime date, List<CalendarEventData<Object?>> events, bool isToday, bool isInMonth, bool hideDaysNotInMonth) {
                             // Giới hạn hiển thị tối đa 2 events để tránh ô lịch bị kéo dài
                             final maxDisplay = 2;
                             final hasMore = events.length > maxDisplay;
                             final visibleEvents = hasMore ? events.take(maxDisplay).toList() : events;
                             const recruiterPrimary = Color(0xFF1A237E);
              
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HrDetailInterviewSchedule(
                                      date: date,
                                      events: events,
                                      jobPostingsList: widget.jobPostingsList,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: isToday 
                                      ? recruiterPrimary.withOpacity(0.1) 
                                      : (isInMonth ? Colors.white : Colors.grey.shade50),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isToday 
                                        ? recruiterPrimary 
                                        : Colors.grey.shade200,
                                    width: isToday ? 2 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isToday ? 8.w : 6.w,
                                              vertical: isToday ? 6.h : 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isToday 
                                                  ? recruiterPrimary 
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            child: Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isToday ? 15.sp : 14.sp,
                                                color: isToday 
                                                    ? Colors.white 
                                                    : (isInMonth ? Colors.black87 : Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      if (isInMonth && visibleEvents.isNotEmpty)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...visibleEvents.map((event) {
                                                final interview = event.event as InterviewScheduleModel?;
                                                final isDirect = interview?.interviewMode == 'Trực tiếp';
                                                return Container(
                                                  margin: EdgeInsets.only(bottom: 3.h),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 4.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isDirect 
                                                        ? Colors.blue.shade600 
                                                        : Colors.purple.shade600,
                                                    borderRadius: BorderRadius.circular(6.r),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 2,
                                                        offset: const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isDirect ? Icons.person : Icons.video_call,
                                                        size: 10.sp,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Expanded(
                                                        child: Text(
                                                          interview?.interviewMode ?? event.title,
                                                          style: TextStyle(
                                                            fontSize: 9.sp,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                               if (hasMore)
                                                 Container(
                                                   padding: EdgeInsets.symmetric(
                                                     horizontal: 6.w,
                                                     vertical: 3.h,
                                                   ),
                                                   decoration: BoxDecoration(
                                                     color: recruiterPrimary.withOpacity(0.1),
                                                     borderRadius: BorderRadius.circular(4.r),
                                                     border: Border.all(
                                                       color: recruiterPrimary.withOpacity(0.3),
                                                       width: 1,
                                                     ),
                                                   ),
                                                   child: Row(
                                                     mainAxisSize: MainAxisSize.min,
                                                     children: [
                                                       Icon(
                                                         Icons.more_horiz,
                                                         size: 10.sp,
                                                         color: recruiterPrimary,
                                                       ),
                                                       SizedBox(width: 2.w),
                                                       Text(
                                                         '+${events.length - maxDisplay}',
                                                         style: TextStyle(
                                                           fontSize: 9.sp,
                                                           color: recruiterPrimary,
                                                           fontWeight: FontWeight.bold,
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ) as Widget;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Header với gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF283593),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                  child: Row(
                    children: [
                      // Nút back
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getAdaptiveBackIcon(context),
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Lịch Phỏng Vấn',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Quản lý lịch phỏng vấn ứng viên',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
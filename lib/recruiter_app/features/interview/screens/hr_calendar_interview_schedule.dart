import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_detail_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/interview/widget/detail_interview/background_calendar.dart';

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
            child: BackgroundCalendar(
              child: SafeArea(
                minimum: EdgeInsets.only(left: 16.w, right: 16.w, top: 80.h, bottom: 16.h),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: CalendarControllerProvider<Object?>(
                    controller: _eventController,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.w, sigmaY: 5.h),
                        child: Container(
                          color: Colors.white.withOpacity(0.5),
                          child: MonthView(
                            key: _monthViewKey,
                            minMonth: DateTime(2000, 1),
                            maxMonth: DateTime(currentMonth.year + 10, 12),
                            startDay: WeekDays.monday,
                            initialMonth: currentMonth,
                            cellAspectRatio: isTablet ? 0.51 : 0.45,
                            borderSize: 0.3.w,
                            borderColor: Colors.grey,
                            weekDayBuilder: (int weekDayIndex) {
                              const customWeekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: Text(
                                    customWeekDays[weekDayIndex],
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                                  ),
                                ),
                              );
                            },
                            cellBuilder: (DateTime date, List<CalendarEventData<Object?>> events, bool isToday, bool isInMonth, bool hideDaysNotInMonth) {
                              final maxDisplay = isTablet ? 3 : 4;
                              final hasMore = events.length > maxDisplay;
                              final visibleEvents = hasMore ? events.take(maxDisplay - 1).toList() : events;
                
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
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: isToday ? Colors.blue : Colors.transparent,
                                          borderRadius: BorderRadius.circular(50.r),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              date.day.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                                color: isToday ? Colors.white : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 7.h),
                                      Visibility(
                                        visible: isInMonth,
                                        child: Column(
                                          children: visibleEvents
                                              .map((event) => Container(
                                                    margin: EdgeInsets.symmetric(vertical: 2.h),
                                                    padding: EdgeInsets.all(2.w),
                                                    decoration: BoxDecoration(
                                                      color: event.color,
                                                      borderRadius: BorderRadius.circular(2.r),
                                                    ),
                                                    child: Text(
                                                      event.title,
                                                      style: TextStyle(fontSize: 8.sp, color: Colors.white),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                      if (hasMore && isInMonth)
                                        Text(
                                          '+${events.length - maxDisplay + 1}',
                                          style: TextStyle(fontSize: 11.sp, color: Colors.black26),
                                        ),
                                    ],
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
          ),
          // Nút back
          Positioned(
            top: 32.h,
            left: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(getAdaptiveBackIcon(context), color: Colors.white, size: 24.sp),
              ),
            ),
          ),
          Positioned(
            top: 40.h,
            left: 120.w,
            child: Center(
              child: Text(
                'Lịch Phỏng Vấn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
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
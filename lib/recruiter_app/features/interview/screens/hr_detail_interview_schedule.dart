import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_create_calendar_interview_schedule.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/job/view_model/job_posting_view_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_detail_calendar_interview_schedule.dart';
import 'package:intl/intl.dart';

class HrDetailInterviewSchedule extends StatefulWidget {
  final DateTime date;
  final List<JobPostingModel> jobPostingsList;
  final List<CalendarEventData<Object?>> events;

  const HrDetailInterviewSchedule({
    super.key,
    required this.date,
    required this.events,
    required this.jobPostingsList
  });

  @override
  State<HrDetailInterviewSchedule> createState() => _HrDetailInterviewScheduleState();
}

class _HrDetailInterviewScheduleState extends State<HrDetailInterviewSchedule>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();


  final Map<String, UserModel> _userCache = {};

  bool _loading = true;

  late UserViewModel _userViewModel;
  late JobPostingViewModel _jobPostingViewModel;

  @override
  void initState() {
    super.initState();
    _jobPostingViewModel = context.read<JobPostingViewModel>();
    _userViewModel = context.read<UserViewModel>();
    _preloadData();
  }

  Future<void> _preloadData() async {
    // Load tất cả job postings nếu chưa có
    if (_jobPostingViewModel.jobPostings.isEmpty) {
      await _jobPostingViewModel.fetchAllJobPostings();
    }

    // Load user info cho các interview
    final interviews = widget.events
        .map((e) => e.event)
        .whereType<InterviewScheduleModel>()
        .where((i) =>
            i.interviewDate.year == widget.date.year &&
            i.interviewDate.month == widget.date.month &&
            i.interviewDate.day == widget.date.day)
        .toList();

    for (var i in interviews) {
      if (!_userCache.containsKey(i.idUser)) {
        final user = await _userViewModel.fetchUserViewerById(i.idUser);
        if (user != null) _userCache[i.idUser] = user;
      }
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAddPressed() async {
    final candidateList = _userCache.values.toList();
    // final jobList = _jobPostingViewModel.jobPostings;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HrCreateCalendarInterviewSchedule(
          jobs: widget.jobPostingsList,
          candidateList: candidateList,
        ),
      ),
    );

    _preloadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dayInterviews = widget.events
        .map((e) => e.event)
        .whereType<InterviewScheduleModel>()
        .where((interview) =>
            interview.interviewDate.year == widget.date.year &&
            interview.interviewDate.month == widget.date.month &&
            interview.interviewDate.day == widget.date.day)
        .toList();

    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');
    final formattedDate = dateFormat.format(widget.date);
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
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
                    recruiterPrimary,
                    recruiterSecondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'Lịch Phỏng Vấn',
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          UnfocusWidget(
            child: RefreshIndicator(
              onRefresh: _preloadData,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 80.h),
                    Expanded(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : dayInterviews.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 64.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Không có lịch phỏng vấn',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Ngày ${widget.date.day}/${widget.date.month}/${widget.date.year}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Summary card
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10.w),
                                              decoration: BoxDecoration(
                                                color: recruiterPrimary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Icon(
                                                Icons.calendar_today,
                                                color: recruiterPrimary,
                                                size: 20.sp,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tổng số lịch phỏng vấn',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    '${dayInterviews.length}',
                                                    style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: recruiterPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      // List interviews
                                      ...dayInterviews.map((i) {
                                        final job = _jobPostingViewModel.jobPostings
                                            .firstWhere(
                                                (j) => j.idJobPost == i.idJobPost,
                                                orElse: () => _jobPostingViewModel.jobPostings.first);

                                        final user = _userCache[i.idUser];
                                        final isDirect = i.interviewMode == 'Trực tiếp';
                                        final timeStr = '${i.interviewDate.hour.toString().padLeft(2, '0')}:${i.interviewDate.minute.toString().padLeft(2, '0')}';

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    HrDetailCalendarInterviewSchedule(
                                                  interview: i,
                                                  jobs: _jobPostingViewModel.jobPostings,
                                                  candidates: _userCache.values.toList(),
                                                ),
                                              ),
                                            ).then((_) => _preloadData());
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 10.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Header với mode badge
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: isDirect
                                                          ? [
                                                              Colors.blue.shade600,
                                                              Colors.blue.shade700,
                                                            ]
                                                          : [
                                                              Colors.purple.shade600,
                                                              Colors.purple.shade700,
                                                            ],
                                                    ),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(16.r),
                                                      topRight: Radius.circular(16.r),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(6.w),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(6.r),
                                                        ),
                                                        child: Icon(
                                                          isDirect
                                                              ? Icons.person
                                                              : Icons.video_call,
                                                          color: Colors.white,
                                                          size: 18.sp,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              i.interviewMode ?? 'Phỏng vấn',
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            SizedBox(height: 1.h),
                                                            Text(
                                                              job.title,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Colors.white.withOpacity(0.9),
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.chevron_right,
                                                        color: Colors.white,
                                                        size: 24.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Content
                                                Padding(
                                                  padding: EdgeInsets.all(12.w),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      // Candidate info
                                                      if (user != null)
                                                        Row(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                border: Border.all(
                                                                  color: recruiterPrimary.withOpacity(0.3),
                                                                  width: 2,
                                                                ),
                                                              ),
                                                              child: CircleAvatar(
                                                                radius: 20.r,
                                                                backgroundImage: user.avatarUrl != null
                                                                    ? NetworkImage(user.avatarUrl!)
                                                                    : null,
                                                                backgroundColor: Colors.grey.shade300,
                                                                child: user.avatarUrl == null
                                                                    ? Icon(
                                                                        Icons.person,
                                                                        color: Colors.grey.shade600,
                                                                        size: 24.sp,
                                                                      )
                                                                    : null,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    user.userName,
                                                                    style: TextStyle(
                                                                      fontSize: 15.sp,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.black87,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 2.h),
                                                                  Text(
                                                                    user.email,
                                                                    style: TextStyle(
                                                                      fontSize: 12.sp,
                                                                      color: Colors.grey.shade600,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      else
                                                        Container(
                                                          padding: EdgeInsets.all(10.w),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade100,
                                                            borderRadius: BorderRadius.circular(8.r),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 14.w,
                                                                height: 14.w,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10.w),
                                                              Text(
                                                                "Đang tải thông tin ứng viên...",
                                                                style: TextStyle(
                                                                  fontSize: 13.sp,
                                                                  color: Colors.grey.shade600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      SizedBox(height: 12.h),
                                                      Divider(color: Colors.grey.shade200, height: 1),
                                                      SizedBox(height: 10.h),
                                                      // Time
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(6.w),
                                                            decoration: BoxDecoration(
                                                              color: recruiterPrimary.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6.r),
                                                            ),
                                                            child: Icon(
                                                              Icons.access_time,
                                                              size: 16.sp,
                                                              color: recruiterPrimary,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10.w),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Thời gian',
                                                                  style: TextStyle(
                                                                    fontSize: 11.sp,
                                                                    color: Colors.grey.shade600,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 1.h),
                                                                Text(
                                                                  timeStr,
                                                                  style: TextStyle(
                                                                    fontSize: 14.sp,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Colors.black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (i.location != null) ...[
                                                        SizedBox(height: 8.h),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(6.w),
                                                              decoration: BoxDecoration(
                                                                color: recruiterPrimary.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(6.r),
                                                              ),
                                                              child: Icon(
                                                                Icons.location_on,
                                                                size: 16.sp,
                                                                color: recruiterPrimary,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Địa điểm',
                                                                    style: TextStyle(
                                                                      fontSize: 11.sp,
                                                                      color: Colors.grey.shade600,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 1.h),
                                                                  Text(
                                                                    i.location!,
                                                                    style: TextStyle(
                                                                      fontSize: 14.sp,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.black87,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                      if (i.interviewer != null && i.interviewer!.isNotEmpty) ...[
                                                        SizedBox(height: 8.h),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(6.w),
                                                              decoration: BoxDecoration(
                                                                color: recruiterPrimary.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(6.r),
                                                              ),
                                                              child: Icon(
                                                                Icons.person_outline,
                                                                size: 16.sp,
                                                                color: recruiterPrimary,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10.w),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Người phỏng vấn',
                                                                    style: TextStyle(
                                                                      fontSize: 11.sp,
                                                                      color: Colors.grey.shade600,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 1.h),
                                                                  Text(
                                                                    i.interviewer!,
                                                                    style: TextStyle(
                                                                      fontSize: 14.sp,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.black87,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
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
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            top: 16.h,
          ),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Tìm tên công việc, ngày lễ',
                    hintStyle:
                        TextStyle(fontSize: 20.sp, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(size: 24.sp, Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(size: 24.sp, Icons.add),
                      onPressed: _onAddPressed,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

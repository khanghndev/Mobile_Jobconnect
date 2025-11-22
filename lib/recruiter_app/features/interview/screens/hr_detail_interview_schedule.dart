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
import 'package:job_connect/recruiter_app/features/interview/widget/detail_interview/background_calendar.dart';
import 'package:job_connect/recruiter_app/features/interview/widget/detail_interview/background_form.dart';
import 'package:job_connect/recruiter_app/features/interview/widget/detail_interview/detail_interview_shimmer.dart';
import 'package:job_connect/recruiter_app/features/interview/view_model/interview_schedule_view_model.dart';

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

  String slogan = 'Hãy tận hưởng mỗi ngày!';
  String sloganAuthor = "Job Connect";

  final Map<String, UserModel> _userCache = {};

  bool _loading = true;

  late UserViewModel _userViewModel;
  late JobPostingViewModel _jobPostingViewModel;
  late InterviewScheduleViewModel _interviewVm;

  @override
  void initState() {
    super.initState();
    _jobPostingViewModel = context.read<JobPostingViewModel>();
    _userViewModel = context.read<UserViewModel>();
    _interviewVm = context.read<InterviewScheduleViewModel>();
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          UnfocusWidget(
            child: RefreshIndicator(
              onRefresh: _preloadData,
              child: BackgroundCalendar(
                child: SafeArea(
                  minimum:
                      EdgeInsets.only(left: 16.w, right: 16.w, top: 80.h, bottom: 16.h),
                  child: _loading
                      ? const Center(child: DetailInterviewShimmer())
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BackgroundForm(
                                isMarginTitle: false,
                                titleForm:
                                    'Thứ ${widget.date.weekday}, ${widget.date.day}/${widget.date.month}/${widget.date.year}',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12.h),
                                    Center(
                                      child: Text(
                                        '${widget.date.day}/${widget.date.month}/${widget.date.year} Âm lịch',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      slogan,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        sloganAuthor,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: dayInterviews.isEmpty ? 0 : 16.h),

                                    // LIST CARD
                                    ...dayInterviews.map((i) {
                                      final job = _jobPostingViewModel.jobPostings
                                          .firstWhere(
                                              (j) => j.idJobPost == i.idJobPost,
                                              orElse: () => _jobPostingViewModel.jobPostings.first);

                                      final user = _userCache[i.idUser];

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
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(vertical: 6.h),
                                          child: Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12.r),
                                              color: Colors.blue[50],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${i.interviewMode ?? 'Phỏng vấn'} - ${job.title}',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                if (user != null)
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 18.r,
                                                        backgroundImage: user.avatarUrl != null
                                                            ? NetworkImage(user.avatarUrl!)
                                                            : null,
                                                        backgroundColor: Colors.grey[300],
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            user.userName,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          Text(
                                                            user.email,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Colors.grey[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  const Text("Đang tải ứng viên..."),
                                                SizedBox(height: 6.h),
                                                Row(
                                                  children: [
                                                    Icon(Icons.access_time,
                                                        size: 16.sp, color: Colors.grey[700]),
                                                    SizedBox(width: 6.w),
                                                    Text(
                                                      'Thời gian: ${i.interviewDate.hour.toString().padLeft(2, '0')}:${i.interviewDate.minute.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (i.location != null) SizedBox(height: 6.h),
                                                if (i.location != null)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.location_on_outlined,
                                                          size: 16.sp, color: Colors.grey[700]),
                                                      SizedBox(width: 6.w),
                                                      Expanded(
                                                        child: Text(
                                                          i.location!,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.grey[800],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
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
                child: Icon(getAdaptiveBackIcon(context),
                    color: Colors.white, size: 24.sp),
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

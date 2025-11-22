import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/job_application_status.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/features/home/widgets/home/featured_friends_list.dart';
import 'package:job_connect/features/home/widgets/home/section_header.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/features/job/service/job_transaction_service.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/model/interview_schedule_model.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/recruiter_app/features/hr/screen/hr_detail_recent_activitie_screen.dart';
import 'package:job_connect/recruiter_app/features/hr/widget/home/hr_home_shimmer.dart';
import 'package:job_connect/recruiter_app/features/hr/widget/home/recent_activities_section.dart';
import 'package:job_connect/recruiter_app/features/hr/widget/home/statistics_section.dart';
import 'package:job_connect/recruiter_app/features/hr/widget/home/up_coming_interviews_section.dart';
import 'package:job_connect/recruiter_app/features/hr/widget/home/welcome_section.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_calendar_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/interview/service/interview_schedule_service.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';
import 'package:provider/provider.dart';


//Trang home của HR
class HrHomeScreen extends StatefulWidget {
  final UserModel userAccount;
  const HrHomeScreen({super.key, required this.userAccount});

  @override
  State<HrHomeScreen> createState() => _HrHomeScreenState();
}

class _HrHomeScreenState extends State<HrHomeScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;

  //Lấy ngày hiện tại
  final time = DateTime.now();
  late UserViewModel _userViewModel;
  late SocialConnectionViewModel _connVm;

  final UserService accountService = UserService();
  final CandidateInfoService candidateInfoService = CandidateInfoService();
  final RecruiterService recruiterService = RecruiterService();
  final CompanyService companyService = CompanyService();
  final JobPostingService jobPostingService = JobPostingService();
  final JobApplicationService jobApplicationService = JobApplicationService();
  final InterviewScheduleService interviewScheduleService = InterviewScheduleService();
  final JobTransactionService jobTransactionService = JobTransactionService();
  final SubscriptionPackageService subscriptionpackageService = SubscriptionPackageService();

  UserModel? user;
  RecruiterInfoModel? recruiterInfo;
  CompanyModel? companyInfo;
  List<JobPostingModel> jobPostingsList = [];
  List<List<JobApplicationModel>> jobApplicationsList = [];
  List<List<InterviewScheduleModel>>? interviewSchedulesList;
  List<InterviewScheduleModel> flatInterviewSchedulesList = [];
  List<JobApplicationModel> flatJobApplicationList = [];
  List<InterviewScheduleModel> upcomingInterviewSchedulesList = [];
  List<UserModel> accountInterviewList = [];
  List<UserModel> accountJobApplicationList = [];
  List<CandidateInfoModel> candidateJobApplicationList = [];
  List<CandidateInfoModel>? candidateInterviewList;
  List<CandidateInfoModel> candidateAllList = [];
  List<JobTransactionModel> jobTransactionsList = [];
  List<SubscriptionPackageModel> subscriptionPackagesList = [];
  bool isLoading = true;
  String? error;
  
  // Biển lưu giá trị cũ
  int oldTrendCandidate = 0; // Giá trị ứng viên ứng tuyển cũ
  int oldTrendJob = 0; // Giá trị công việc ứng tuyển cũ
  int oldTrendInterview = 0; // Giá trị đã phỏng vấn cũ
  
  // Ví dụ có giá trị mới:
  late int newCandidate; // Số ứng viên mới
  late int newJob; // Số công việc mới
  late int newInterview; // Số đã phỏng vấn mới

  String trendCandidate = ''; // Biến lưu trữ giá trị trend ứng viên
  String trendJob = ''; // Biến lưu trữ giá trị trend công việc
  String trendInterview = ''; // Biến lưu trữ giá trị trend đã phỏng vấn

  @override
  void initState() {
    super.initState();
     _userViewModel = context.read<UserViewModel>();
     _connVm = context.read<SocialConnectionViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _loadDataAndCalculateTrends();
      _userViewModel.fetchAllUsers();
      await _connVm.getFriends(userId: widget.userAccount.idUser);
      await _connVm.getSentRequests(userId: widget.userAccount.idUser);
      await _connVm.getRequests(userId: widget.userAccount.idUser);
    });
  }

  // Load dữ liệu
  Future<void> _loadDataAndCalculateTrends() async {
    await _loadAllData(); 

    // Gán các giá trị mới sau khi dữ liệu đã có
    newCandidate = jobApplicationsList.length;
    newJob = jobPostingsList.length;
    newInterview = getApplicationsWithStatus(JobApplicationStatus.interview.name).length;

    // Tính và cập nhật các trend
    trendCandidate = getAndUpdateTrend(
      oldValue: oldTrendCandidate,
      newValue: newCandidate,
      updateOldValue: (val) => oldTrendCandidate = val,
    );

    trendJob = getAndUpdateTrend(
      oldValue: oldTrendJob,
      newValue: newJob,
      updateOldValue: (val) => oldTrendJob = val,
    );

    trendInterview = getAndUpdateTrend(
      oldValue: oldTrendInterview,
      newValue: newInterview,
      updateOldValue: (val) => oldTrendInterview = val,
    );
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 1. Lấy user và recruiter
      final acc = await accountService.getUserById(id: widget.userAccount.idUser);
      final rec = await recruiterService.getRecruiterById(id: acc.idUser);
      if (rec == null) throw Exception("Không tìm thấy thông tin nhà tuyển dụng.");

      // 2. Lấy company (bỏ qua lỗi)
      CompanyModel? comp;
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        try {
          comp = await companyService.getCompanyById(id: rec.idCompany!);
        } catch (_) {
          comp = null;
        }
      }

      // 3. Lấy job postings (bỏ qua lỗi)
      List<JobPostingModel> jobPostings = [];
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        try {
          jobPostings = await jobPostingService.getJobPostingsByCompany(companyId: rec.idCompany!);
        } catch (_) {}
      }

      // 4. Lấy job applications song song (bỏ qua lỗi từng job)
      final jobApplications = await Future.wait(jobPostings.map((job) async {
        try {
          return await jobApplicationService.getApplicationsByJobPost(jobPostId: job.idJobPost);
        } catch (_) {
          return <JobApplicationModel>[];
        }
      }));

      final flatJobAppList = jobApplications.expand((e) => e).toList();

      // 5. Lấy User & Candidate cho job applications (bỏ qua lỗi từng user)
      final usersAndCandidates = await Future.wait(flatJobAppList.map((jobApp) async {
        try {
          final user = await accountService.getUserById(id: jobApp.idUser);
          final candidate = await candidateInfoService.getCandidateById(id: jobApp.idUser);
          return {'user': user, 'candidate': candidate};
        } catch (_) {
          return null;
        }
      }));

      final userOfJobApp = usersAndCandidates.whereType<Map>().map((e) => e['user'] as UserModel).toList();
      final candidateInforOfJobAppList = usersAndCandidates.whereType<Map>().map((e) => e['candidate'] as CandidateInfoModel).toList();

      // 6. Lấy lịch phỏng vấn (bỏ qua lỗi từng job)
      final interviewSchedulesTemp = await Future.wait(jobPostings.map((job) async {
        try {
          return await interviewScheduleService.getInterviewScheduleByJobId(jobId: job.idJobPost);
        } catch (_) {
          return <InterviewScheduleModel>[];
        }
      }));

      final flatList = interviewSchedulesTemp.expand((e) => e).toList();

      // 7. Lấy User & Candidate cho lịch phỏng vấn (bỏ qua lỗi từng user)
      final accountsAndCandidates = await Future.wait(flatList.map((schedule) async {
        try {
          final account = await accountService.getUserById(id: schedule.idUser);
          final candidate = await candidateInfoService.getCandidateById(id: schedule.idUser);
          return {'account': account, 'candidate': candidate};
        } catch (_) {
          return null;
        }
      }));

      final accountList = accountsAndCandidates.whereType<Map>().map((e) => e['account'] as UserModel).toList();
      final candidateList = accountsAndCandidates.whereType<Map>().map((e) => e['candidate'] as CandidateInfoModel).toList();

      // 8. Lấy giao dịch & gói dịch vụ
      final results = await Future.wait([
        jobTransactionService.getAllTransactions(),
        SubscriptionPackageService().fetchSubscriptionPackages(),
      ]);

      final jobTransactions = results[0] as List<JobTransactionModel>;
      final subscriptionPackages = results[1] as List<SubscriptionPackageModel>;

      if (!mounted) return;

      // 9. Set state cuối cùng
      setState(() {
        recruiterInfo = rec;
        user = acc;
        companyInfo = comp;
        jobPostingsList = jobPostings;
        jobApplicationsList = jobApplications;
        flatJobApplicationList = flatJobAppList;
        interviewSchedulesList = interviewSchedulesTemp;
        flatInterviewSchedulesList = flatList;
        upcomingInterviewSchedulesList = getUpcomingInterviews(flatList);
        accountInterviewList = accountList;
        accountJobApplicationList = userOfJobApp;
        candidateJobApplicationList = candidateInforOfJobAppList;
        candidateInterviewList = candidateList;
        jobTransactionsList = jobTransactions;
        subscriptionPackagesList = subscriptionPackages;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Lỗi tải dữ liệu tổng.';
        isLoading = false;
      });

      SnackbarApp.show(
        context,
        message: 'Không thể tải dữ liệu tổng.',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  //Lấy số vị trí đã tuyển từ jobpostting
  int getPosisionPost(){
    List<String> posisionPost = [];
    for(int i = 0; i < jobPostingsList.length; i++){
      posisionPost.add(jobPostingsList[i].title);
    }
    List<String> posisionPostUnique = posisionPost.toSet().toList();
    return posisionPostUnique.length;
  }

  // Hàm lấy số hồ sơ ở trạng thái đang chờ - pending
  List<JobApplicationModel> getApplicationsWithStatus(String status) {
    return jobApplicationsList.expand((list) => list)
        .where((app) => app.applicationStatus == status)
        .toList();
  }

  // Hàm tính tổng hồ sơ phỏng vấn
  int sumJobApplicationsList() {
    return jobApplicationsList.fold(0, (total, sublist) => total + sublist.length);
  }

  // Hàm tính tổng lịch phỏng vấn
  int sumInterviewSchedulesList() {
    return interviewSchedulesList?.fold(0, (total, sublist) => total! + sublist.length) ?? 0;
  }

  // Hàm tính số trend ứng viên
  String getAndUpdateTrend({
    required int oldValue,
    required int newValue,
    required void Function(int) updateOldValue,
  }) {
    if (oldValue == 0) {
      updateOldValue(newValue);
      if (newValue > 0) {
        return '100%'; 
      }
      return '0%';
    }

    int increase = (newValue - oldValue);
    double percent = (increase / oldValue) * 100;

    // Cập nhật giá trị cũ với giá trị mới
    updateOldValue(newValue);

    return '${percent.floor()}%';
  }

  // Hàm tính đã vượt qua bao nhiêu ngày
  String getRelativeDateLabel(DateTime inputDate) {
    DateTime now = DateTime.now();
    
    // Làm tròn về 0 giờ để so sánh chỉ ngày, không tính giờ/phút/giây
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime targetDate = DateTime(inputDate.year, inputDate.month, inputDate.day);

    int difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == -1) {
      return 'Hôm qua';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference > 1) {
      return '$difference ngày nữa';
    } else {
      return 'Đã qua ${-difference} ngày';
    }
  }

  // Hàm chuẩn hóa giờ phút có am/pm
  String formatHourWithAmPm(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    String amPm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    String minuteStr = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteStr $amPm';
  }

  // Hàm lấy danh sách phỏng vấn sắp tới
  List<InterviewScheduleModel> getUpcomingInterviews(List<InterviewScheduleModel> list) {
    DateTime now = DateTime.now();
    // Lấy các lịch phỏng vấn có ngày >= hôm nay, sắp xếp tăng dần theo ngày
    return list
        .where((schedule) => !schedule.interviewDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.interviewDate.compareTo(b.interviewDate));
  }
  
  // Hàm color random avatar
  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // Alpha luôn full
      random.nextInt(256), // Red 0-255
      random.nextInt(256), // Green 0-255
      random.nextInt(256), // Blue 0-255
    );
  }

  Future<void> _sendFriendRequest(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();

    await connVm.sendRequest(
      request: SocialConnectionRequest(
        fromUserId: widget.userAccount.idUser,
        toUserId: targetUser.idUser,
      ),
    );

    await connVm.getSentRequests(userId: widget.userAccount.idUser);
  }

  Future<void> _unfriend(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.unfriend(userId1: widget.userAccount.idUser, userId2: targetUser.idUser);

    // Refresh tab nếu đang ở tab "Bạn bè"
    await connVm.getFriends(userId: widget.userAccount.idUser);
  }

  Future<void> _acceptRequest(UserModel user) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.acceptRequest(
      request: SocialConnectionRequest(
        fromUserId: user.idUser,           // người gửi request
        toUserId: widget.userAccount.idUser,  // HR nhận
      ),
    );
    await connVm.getRequests(userId: widget.userAccount.idUser); // cập nhật tab lời mời
    await connVm.getFriends(userId: widget.userAccount.idUser);  // cập nhật bạn bè
  }

  Future<void> _rejectRequest(UserModel user) async {
    final connVm = context.read<SocialConnectionViewModel>();
    await connVm.rejectRequest(
      request: SocialConnectionRequest(
        fromUserId: user.idUser,           // người gửi request
        toUserId: widget.userAccount.idUser,  // HR nhận
      ),
    );
  }

  Future<void> _cancelFriendRequest(UserModel targetUser) async {
    final connVm = context.read<SocialConnectionViewModel>();

    // Tạo request object
    final request = SocialConnectionRequest(
      fromUserId: widget.userAccount.idUser,
      toUserId: targetUser.idUser,
    );

    await connVm.cancelRequest(request: request);
  }

   @override
  Widget build(BuildContext context) {
    super.build(context);
    final userVM = context.watch<UserViewModel>();
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: isLoading
          ? const HrHomeShimmer()
          : RefreshIndicator(
            onRefresh: _loadAllData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeSectionWidget(
                    userName: widget.userAccount.userName,
                    pendingApplications: getApplicationsWithStatus(JobApplicationStatus.pending.name),
                  ),
                  SizedBox(height: 16.h),
                  StatisticsSection(
                    primaryColor: theme.primaryColor,
                    jobApplicationsList: jobApplicationsList,
                    jobPostingsList: jobPostingsList,
                    trendCandidate: trendCandidate,
                    trendJob: trendJob,
                    trendInterview: trendInterview,
                    getApplicationsWithStatus: (status) => getApplicationsWithStatus(status).length,
                  ),
                  SizedBox(height: 16.h),
                  RecentActivitiesSection(
                    getRecentActivities: _getRecentActivities,
                    detailScreenBuilder: (activity) => HrDetailRecentActivitieScreen(
                      title: activity['title'],
                      time: activity['time'],
                      description: activity['description'],
                      icon: activity['icon'],
                      color: activity['color'],
                      details: activity['details'],
                      attachments: activity['attachments'],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SectionHeader(
                    title: "Lịch phỏng vấn sắp tới",
                    onSeeAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HrCalendarInterviewSchedule(
                        idUser: widget.userAccount.idUser,
                        interviews: flatInterviewSchedulesList,
                        jobPostingsList: jobPostingsList
                      )),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  UpComingInterviewsSection(
                    upcomingInterviewSchedulesList: upcomingInterviewSchedulesList,
                    accountInterviewList: accountInterviewList,
                    candidateInterviewList: candidateInterviewList,
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HrCalendarInterviewSchedule(
                        idUser: widget.userAccount.idUser,
                        interviews: flatInterviewSchedulesList,
                        jobPostingsList: jobPostingsList
                      )),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SectionHeader(
                    title: "Bạn có thể biết",
                    onSeeAll: () => context.push('/social/search',extra: {'idUser' : widget.userAccount.idUser}),
                  ),
                  SizedBox(height: 16.h),
                  FeaturedFriendsList(
                    users: userVM.users.where((u) => u.idUser != widget.userAccount.idUser).toList(),
                    getFriendStatus: (user) {
                      return {
                        'isFriend': _connVm.friends.any((f) => f.id == user.idUser),
                          'isRequestSent': _connVm.sentRequests.any((r) => r.idUser2 == user.idUser),
                          'isRequestReceived': _connVm.requests.any((r) => r.idUser1 == user.idUser),
                      };
                    },
                    onSendRequest: (user) async {
                      await _sendFriendRequest(user);
                      setState(() {}); 
                    },
                    onCancelRequest: (user) async {
                      await _cancelFriendRequest(user);
                      setState(() {});
                    },
                    onAcceptRequest: (user) async {
                      await _acceptRequest(user);
                      setState(() {});
                    },
                    onRejectRequest: (user) async {
                      await _rejectRequest(user);
                      setState(() {});
                    },
                    onUnfriend: (user) async {
                      await _unfriend(user);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    List<Map<String, dynamic>> activities = [];

    // Hoạt động từ JobApplication
    for (var application in flatJobApplicationList) {
      final jobPosting = jobPostingsList.firstWhere(
        (job) => job.idJobPost == application.idJobPost,
      );

      // Hoạt động từ JobTransaction
      for (var transaction in jobTransactionsList) {
        final package = subscriptionPackagesList.firstWhere(
          (pkg) => pkg.idPackage == transaction.idPackage,
        );

        activities.add({
          'title': 'Thanh toán gói ${package.packageName} đã được thực hiện',
          'time': DateUtilsHelper.timeAgo(transaction.transactionDate),
          'date': transaction.transactionDate, // thêm trường gốc
          'icon': Icons.attach_money,
          'color': const Color(0xFFFFC107),
        });
      }

      activities.add({
        'title':
            '${_getUserNameById(application.idUser)} đã ứng tuyển vào công việc ${jobPosting.title}',
        'time': DateUtilsHelper.timeAgo(application.updatedAt),
        'date': application.updatedAt,
        'icon': Icons.person_add_alt_1,
        'color': const Color(0xFF4CAF50),
      });
    }
    // Hoạt động từ JobPosting
    for (var job in jobPostingsList) {
      activities.add({
        'title': 'Công việc mới: ${job.title} đã được đăng tuyển',
        'time': DateUtilsHelper.timeAgo(job.createdAt),
        'date': job.createdAt,
        'icon': Icons.work_outline,
        'color': const Color(0xFF3366FF),
      });
    }

    // Sắp xếp theo thời gian thật
    activities.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA); // mới nhất lên đầu
    });

    return activities;
  }

  // Lấy tên user theo jobapplication
  String _getUserNameById(String idUser) {
    final user = accountJobApplicationList.firstWhere(
      (account) => account.idUser == idUser,
    );
    return user.userName;
  }
  
}
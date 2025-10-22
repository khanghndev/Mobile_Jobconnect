import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/app_dialog.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/config/widgets/custom_submit_button.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_job_cover_letter_input.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_job_header.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_tips_card.dart';
import 'package:job_connect/features/job/widgets/apply_job/cv_selection_section.dart';

class ApplyJobScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String idUser;

  const ApplyJobScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.idUser,
  });

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> with TickerProviderStateMixin {
  File? selectedCVFile; // Đổi tên từ selectedCV để rõ ràng hơn là File
  String? selectedCVFileName; // Đổi tên từ fileName
  String applicationStatus = "pending";
  final TextEditingController _coverLetterCon = TextEditingController();
  bool _isSubmitting = false; // Đổi tên từ isSubmitting
  List<ResumeModel> _savedCVs = []; // Đổi tên từ savedCVs và _resumeList
  String? _selectedSavedCvUrl; // Lưu URL của CV đã lưu được chọn
  String? _selectedSavedCvName; // Lưu tên của CV đã lưu được chọn

  bool _isCvListExpanded = false; // Đổi tên từ _isExpanded
  bool _isLoadingData = true; // Đổi tên từ _isLoading
  UserModel? _account;
  // final ImagePicker _picker = ImagePicker(); // Không thấy dùng trong UI này
  final _apiService = ApiService( );

  late AnimationController _formAnimationController; // Animation cho form
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formFadeAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    );
    _initializeData();
  }

  @override
  void dispose() {
    _coverLetterCon.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) {
      _formAnimationController.forward(); 
    }
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoadingData = true);
    try {
      await Future.wait([_fetchAccount(), _fetchResumeList()]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải dữ liệu. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        endpoint:  '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) _account = UserModel.fromJson(data.first);
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  Future<void> _fetchResumeList() async {
    try {
      final response = await _apiService.get(
        endpoint:  "${ApiConstants.resumeEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        setState(() {
          _savedCVs =
              response.map<ResumeModel>((json) => ResumeModel.fromJson(json)).toList();
          // Tự động chọn CV mặc định (nếu có)
          final defaultCv = _savedCVs.firstWhere(
            (cv) => cv.isDefault == 1,
            orElse:
                () =>
                    _savedCVs.isNotEmpty
                        ? _savedCVs.first
                        : ResumeModel(
                          idResume: '',
                          idUser: '',
                          fileName: '',
                          fileUrl: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          fileSizeKB: 0,
                          fileId: '',
                          isDefault:
                              0, // Cần Resume constructor rỗng hoặc một giá trị mặc định
                        ),
          ); // Cần Resume constructor rỗng hoặc một giá trị mặc định
          if (defaultCv.idResume.isNotEmpty) {
            // Kiểm tra xem có CV mặc định không
            _selectedSavedCvUrl = defaultCv.fileUrl;
            _selectedSavedCvName = defaultCv.fileName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải danh sách CV.')),
        );
      }
    }
  }

  Future<void> _pickCV() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
        ], // Chỉ cho phép các định dạng CV phổ biến
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedCVFile = File(result.files.single.path!);
          selectedCVFileName = result.files.single.name;
          _selectedSavedCvUrl = null; // Bỏ chọn CV đã lưu nếu chọn file mới
          _selectedSavedCvName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi khi chọn file CV.')));
      }
    }
  }

  void _selectSavedCV(ResumeModel cv) {
    // Nhận cả object Resume
    setState(() {
      _selectedSavedCvUrl = cv.fileUrl;
      _selectedSavedCvName = cv.fileName;
      selectedCVFile = null; // Bỏ chọn file mới nếu chọn CV đã lưu
      selectedCVFileName = null;
      _isCvListExpanded = false; // Thu gọn danh sách sau khi chọn
    });
  }

  Future<void> _onSubmitApplication() async {
    // TODO: Xử lý logic upload selectedCVFile lên Firebase Storage nếu nó được chọn,
    // sau đó lấy URL trả về để gán cho "cvFileUrl" trong data.
    // Hiện tại, nếu selectedCVFile được chọn, chúng ta sẽ bỏ qua việc gửi cvFileUrl từ selectedSavedCV.

    String? finalCvUrlToSend;
    String?
    finalCvNameToDisplay; // Tên file để hiển thị trong dialog thành công

    if (selectedCVFile != null) {
      // Đây là nơi bạn sẽ upload selectedCVFile lên Firebase và lấy URL
      // Ví dụ (cần logic upload thực tế):
      // final String uploadedUrl = await _uploadFileToFirebase(selectedCVFile!, selectedCVFileName!);
      // finalCvUrlToSend = uploadedUrl;
      // finalCvNameToDisplay = selectedCVFileName;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TODO: Upload CV mới và lấy URL từ Firebase.'),
        ),
      );
      // Hiện tại, để test, ta có thể gán một URL giả hoặc báo lỗi nếu chưa implement
      // finalCvUrlToSend = "URL_UPLOADED_FROM_DEVICE"; // << THAY THẾ BẰNG URL THỰC TẾ SAU KHI UPLOAD
      // finalCvNameToDisplay = selectedCVFileName;
      return; // Ngăn không cho submit nếu chưa có logic upload
    } else if (_selectedSavedCvUrl != null) {
      finalCvUrlToSend = _selectedSavedCvUrl;
      finalCvNameToDisplay = _selectedSavedCvName;
    }

    if (finalCvUrlToSend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chọn hoặc tải lên một CV để ứng tuyển.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic> data = {
      "idJobPost": widget.jobId,
      "idUser": widget.idUser,
      "cvFileUrl": finalCvUrlToSend, // URL của CV (từ Firebase hoặc đã lưu)
      "cvFileName": finalCvNameToDisplay, // Thêm tên file CV
      "coverLetter": _coverLetterCon.text.trim(),
      "applicationStatus": "pending", // Trạng thái ban đầu
    };

    try {
      // final response = // Bỏ biến response không dùng
      await _apiService.post(endpoint:  ApiConstants.jobApplicationEndpoint, body:data);
      // Giả sử API trả về 200 hoặc 201 là thành công
      if (mounted) {
        AppDialog.show(
          context,
          title: "Nộp Hồ Sơ Thành Công!",
          icon: Icons.check_circle_outline_rounded,
          iconColor: Theme.of(context).colorScheme.primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hồ sơ của bạn cho vị trí: ${widget.jobTitle}"),
              SizedBox(height: 8),
              Text("Sử dụng CV: $finalCvNameToDisplay"),
              SizedBox(height: 8),
              Text("Đã được gửi đến nhà tuyển dụng."),
              SizedBox(height: 12),
              Text(
                "Bạn có thể theo dõi trong 'Lịch sử ứng tuyển'.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JobHistoryScreen(idUser: widget.idUser),
                  ),
                );
              },
              child: const Text("XEM LỊCH SỬ"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("VỀ TRANG CHỦ"),
            ),
          ],
        );

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gửi ứng tuyển thất bại: ${e.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Ứng tuyển công việc"),
      body: _isLoadingData
        // TODO: LOADING ĐẸP
        ? Center(
          child: SpinKitFadingCube(color: theme.primaryColor, size: 40.r),
        )
        : SafeArea(
          child: UnfocusWidget(
            child: FadeTransition(
              opacity: _formFadeAnimation,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // TODO: HEADER JOB
                  ApplyJobHeader(
                    jobTitle: widget.jobTitle,
                    companyName: widget.companyName,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: CHỌN CV
                        SectionTitle(
                          title: "Chọn Hồ Sơ CV",
                          icon: Icons.file_present_rounded,
                        ),
                        CvSelectionSection(
                          savedCVs: _savedCVs,
                          selectedSavedCvUrl: _selectedSavedCvUrl,
                          selectedSavedCvName: _selectedSavedCvName,
                          selectedCVFileName: selectedCVFileName,
                          hasLocalFile: selectedCVFile != null,
                          isExpanded: _isCvListExpanded,
                          onPickCv: _pickCV,
                          onRemoveCv: () {
                            setState(() {
                              selectedCVFile = null;
                              selectedCVFileName = null;
                              _selectedSavedCvUrl = null;
                              _selectedSavedCvName = null;
                            });
                          },
                          onSelectSavedCv: (resume) {
                            setState(() {
                              _selectedSavedCvUrl = resume.fileUrl;
                              _selectedSavedCvName = resume.fileName;
                              selectedCVFile = null;
                              selectedCVFileName = null;
                            });
                          },
                          onToggleExpand: (expanded) {
                            setState(() => _isCvListExpanded = expanded);
                          },
                        ),

                        const SizedBox(height: 24),
            
                        SectionTitle(
                          title: "Thư Giới Thiệu (Cover Letter)",
                          icon: Icons.mail_outline_rounded,
                        ),
                        ApplyJobCoverLetterInput(
                          controller: _coverLetterCon,
                        ),
                        const SizedBox(height: 32),
                        
                        CustomSubmitButton(
                          isLoading: _isSubmitting,
                          onPressed: _onSubmitApplication,
                          label: "GỬI ỨNG TUYỂN NGAY",
                          icon: Icons.send_and_archive_rounded,
                        ),
            
                        const SizedBox(height: 24),
                        // TODO: Mẹo Nhỏ Cho Bạn
                        ApplyTipsCard(
                          title: "Mẹo Nhỏ Cho Bạn",
                          tips: AppStrings.applyTipsList,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
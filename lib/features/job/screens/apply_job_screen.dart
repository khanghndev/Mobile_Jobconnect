import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:http/http.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Mặc dù không dùng trực tiếp trong UI này, nhưng có thể cần cho logic upload ảnh CV nếu có
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/account_model.dart';
import 'package:job_connect/data/models/resume_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:file_picker/file_picker.dart'; // Đã có
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart'; // Thêm cho loading indicator đẹp hơn

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

class _ApplyJobScreenState extends State<ApplyJobScreen>
    with TickerProviderStateMixin {
  // Thêm TickerProviderStateMixin
  File? selectedCVFile; // Đổi tên từ selectedCV để rõ ràng hơn là File
  String? selectedCVFileName; // Đổi tên từ fileName
  String applicationStatus = "pending";
  final TextEditingController _coverLetterController = TextEditingController();
  bool _isSubmitting = false; // Đổi tên từ isSubmitting
  List<Resume> _savedCVs = []; // Đổi tên từ savedCVs và _resumeList
  String? _selectedSavedCvUrl; // Lưu URL của CV đã lưu được chọn
  String? _selectedSavedCvName; // Lưu tên của CV đã lưu được chọn

  bool _isCvListExpanded = false; // Đổi tên từ _isExpanded
  bool _isLoadingData = true; // Đổi tên từ _isLoading
  Account? _account;
  // final ImagePicker _picker = ImagePicker(); // Không thấy dùng trong UI này
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

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
    _coverLetterController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) {
      _formAnimationController.forward(); // Chạy animation sau khi tải
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
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) _account = Account.fromJson(data.first);
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  Future<void> _fetchResumeList() async {
    try {
      final response = await _apiService.get(
        "${ApiConstants.resumeEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        setState(() {
          _savedCVs =
              response.map<Resume>((json) => Resume.fromJson(json)).toList();
          // Tự động chọn CV mặc định (nếu có)
          final defaultCv = _savedCVs.firstWhere(
            (cv) => cv.isDefault == 1,
            orElse:
                () =>
                    _savedCVs.isNotEmpty
                        ? _savedCVs.first
                        : Resume(
                          idResume: '',
                          idUser: '',
                          fileName: '',
                          fileUrl: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          fileSizeKB: 0,
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

  void _selectSavedCV(Resume cv) {
    // Nhận cả object Resume
    setState(() {
      _selectedSavedCvUrl = cv.fileUrl;
      _selectedSavedCvName = cv.fileName;
      selectedCVFile = null; // Bỏ chọn file mới nếu chọn CV đã lưu
      selectedCVFileName = null;
      _isCvListExpanded = false; // Thu gọn danh sách sau khi chọn
    });
  }

  Future<void> _submitApplication() async {
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
      "coverLetter": _coverLetterController.text.trim(),
      "applicationStatus": "pending", // Trạng thái ban đầu
    };

    try {
      // final response = // Bỏ biến response không dùng
      await _apiService.post(ApiConstants.jobApplicationPostEndpoint, data);
      // Giả sử API trả về 200 hoặc 201 là thành công
      if (mounted) {
        _showSuccessDialog(finalCvNameToDisplay ?? "CV của bạn");
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

  void _showSuccessDialog(String cvName) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng bằng cách chạm ra ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                "Nộp Hồ Sơ Thành Công!",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hồ sơ của bạn cho vị trí:",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.jobTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text("Sử dụng CV: $cvName", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                "Đã được gửi đến nhà tuyển dụng.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Bạn có thể theo dõi trạng thái trong mục 'Lịch sử ứng tuyển'.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => JobHistoryScreen(idUser: widget.idUser),
                  ),
                ); // Chuyển đến trang lịch sử ứng tuyển
              },
              child: Text(
                "XEM LỊCH SỬ",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst); // Quay về trang chủ
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text("VỀ TRANG CHỦ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          "Ứng tuyển công việc",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0.8,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body:
          _isLoadingData
              ? Center(
                child: SpinKitFadingCube(color: theme.primaryColor, size: 40.0),
              )
              : FadeTransition(
                // Animation cho toàn bộ form
                opacity: _formFadeAnimation,
                child: ListView(
                  // Sử dụng ListView để có thể cuộn nếu nội dung dài
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero, // Bỏ padding mặc định của ListView
                  children: [
                    _buildJobHeader(theme),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            "Chọn Hồ Sơ CV",
                            Icons.file_present_rounded,
                            theme,
                          ),
                          _buildCvSelectionSection(theme),
                          const SizedBox(height: 24),
                          _buildSectionTitle(
                            "Thư Giới Thiệu (Cover Letter)",
                            Icons.mail_outline_rounded,
                            theme,
                          ),
                          _buildCoverLetterInput(theme),
                          const SizedBox(height: 32),
                          _buildSubmitButton(theme),
                          const SizedBox(height: 24),
                          _buildApplicationTips(theme, isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildJobHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), // Tăng padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.jobTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.business_center_outlined,
                color: Colors.white.withOpacity(0.85),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                // Để tên công ty không bị tràn
                child: Text(
                  widget.companyName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvSelectionSection(ThemeData theme) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedCVFile != null || _selectedSavedCvUrl != null)
              _buildSelectedCvInfo(theme)
            else // Chỉ hiển thị thông báo này khi CHƯA có CV nào được chọn
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Vui lòng chọn hoặc tải lên CV của bạn.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickCV,
                    icon: Icon(
                      Icons.upload_file_rounded,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      "Tải Lên CV",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.primaryColor.withOpacity(0.7),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Thêm log ở đây để xem _isCvListExpanded thay đổi như thế nào
                      print(
                        "CV Đã Lưu button pressed. Current _isCvListExpanded: $_isCvListExpanded",
                      );
                      setState(() {
                        _isCvListExpanded = !_isCvListExpanded;
                      });
                      print("New _isCvListExpanded: $_isCvListExpanded");
                    },
                    icon: Icon(
                      _isCvListExpanded
                          ? Icons.folder_open_rounded
                          : Icons.folder_copy_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      "CV Đã Lưu",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
            // AnimatedSize sẽ tự động animate khi widget con của nó thay đổi kích thước
            // Đảm bảo widget con có kích thước rõ ràng khi _isCvListExpanded là true và _savedCVs không rỗng
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              // Thêm alignment để kiểm soát cách nó expand/collapse
              alignment: Alignment.topCenter, // Hoặc Alignment.center
              child:
                  _isCvListExpanded
                      ? (_savedCVs.isNotEmpty
                          ? _buildSavedCvList(theme)
                          : Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 8.0,
                            ), // Thêm bottom padding
                            child: Container(
                              // Bọc Text trong Container để có kích thước rõ ràng
                              width: double.infinity, // Chiếm hết chiều rộng
                              alignment: Alignment.center,
                              child: Text(
                                "Bạn chưa có CV nào được lưu.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ),
                          ))
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCvList(ThemeData theme) {
    print("_buildSavedCvList called with ${_savedCVs.length} CVs.");
    if (_savedCVs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxHeight: 200), // Giữ lại constraints
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _savedCVs.length,
        // separatorBuilder:
        //     (context, index) => Divider(
        //       height: 1,
        //       thickness: 1,
        //       color: theme.dividerColor.withOpacity(0.3),
        //     ),
        itemBuilder: (context, index) {
          final resume = _savedCVs[index];
          final bool isCurrentlySelected =
              _selectedSavedCvUrl == resume.fileUrl;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  isCurrentlySelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      isCurrentlySelected
                          ? theme.primaryColor
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  size: 22,
                ),
                title: Text(
                  resume.fileName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isCurrentlySelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  "Cập nhật: ${FormatUtils.formattedDateTime(resume.updatedAt)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                onTap: () => _selectSavedCV(resume),
                dense: true,
                selected: isCurrentlySelected,
                selectedTileColor: theme.primaryColor.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              if (index <
                  _savedCVs.length -
                      1) // Chỉ thêm Divider nếu không phải item cuối
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                  ), // Padding cho Divider
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedCvInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: theme.primaryColor,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCVFileName ?? _selectedSavedCvName ?? "CV đã chọn",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedCVFile != null)
                  Text(
                    "Từ thiết bị",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (_selectedSavedCvUrl != null)
                  Text(
                    "Từ CV đã lưu",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
            onPressed:
                () => setState(() {
                  selectedCVFile = null;
                  selectedCVFileName = null;
                  _selectedSavedCvUrl = null;
                  _selectedSavedCvName = null;
                }),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetterInput(ThemeData theme) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(
          4.0,
        ), // Padding nhỏ để TextField sát viền Card
        child: TextField(
          controller: _coverLetterController,
          maxLines: 6, // Tăng số dòng
          minLines: 4,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText:
                "Viết một vài dòng giới thiệu bản thân, kinh nghiệm và tại sao bạn phù hợp với vị trí này...",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor.withOpacity(0.7),
            ),
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none, // Bỏ border của TextField
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      // Bọc trong SizedBox để nút chiếm toàn bộ chiều rộng
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.primaryColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16), // Tăng padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // Bo góc lớn hơn
          elevation: 3, // Tăng elevation
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        icon:
            _isSubmitting
                ? Container(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
                : Icon(Icons.send_and_archive_rounded, size: 22), // Icon khác
        label: Text(_isSubmitting ? "ĐANG GỬI HỒ SƠ..." : "GỬI ỨNG TUYỂN NGAY"),
      ),
    );
  }

  Widget _buildApplicationTips(ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16), // Thêm margin top
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(
          isDarkMode ? 0.3 : 0.5,
        ), // Màu nền khác
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: theme.colorScheme.onSecondaryContainer,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Mẹo Nhỏ Cho Bạn",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            "Đảm bảo CV của bạn được cập nhật và không có lỗi chính tả.",
            theme,
          ),
          _buildTipItem(
            "Viết thư xin việc (Cover Letter) thể hiện sự quan tâm và phù hợp của bạn với vị trí.",
            theme,
          ),
          _buildTipItem(
            "Kiểm tra kỹ thông tin trước khi gửi để tránh sai sót.",
            theme,
          ),
          _buildTipItem(
            "Nhà tuyển dụng thường đánh giá cao sự chuyên nghiệp và cẩn thận.",
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

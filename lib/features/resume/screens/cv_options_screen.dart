import 'dart:io';
import 'dart:typed_data'; // Cho Uint8List khi đổi tên file trên Firebase

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cho SystemUiOverlayStyle
import 'package:http/http.dart' as http;
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/account_model.dart';
import 'package:job_connect/core/data/models/resume_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/core/config/utils/format.dart';
import 'package:job_connect/features/file/screens/file_viewer_screen.dart';
import 'package:job_connect/features/resume/screens/create_cv_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'cv_templates_screen.dart'; // Thêm thư viện này

class CVOptionsScreen extends StatefulWidget {
  final void Function(RefreshCallback refreshCallback)? registerRefreshCallback;
  final bool isLoggedIn;
  final String idUser;

  const CVOptionsScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    this.registerRefreshCallback,
  });

  @override
  State<CVOptionsScreen> createState() => _CVOptionsScreenState();
}

class _CVOptionsScreenState extends State<CVOptionsScreen>
    with TickerProviderStateMixin {
  // Đổi thành TickerProviderStateMixin
  late AnimationController _listAnimationController; // Cho animation danh sách
  late AnimationController _fabAnimationController; // Cho animation FAB
  late Animation<double> _fabScaleAnimation;

  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  final List<Resume> _resumeList = [];
  bool _isLoading = true;
  Account? _account;
  String _searchTerm = '';
  String _selectedFilter = 'Tất cả';
  PlatformFile? _pickedCvPlatformFile;
  bool _isUploadingCv = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ), // Tăng thời gian cho mượt hơn
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ), // Thời gian ngắn hơn cho hiệu ứng nảy
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut, // Hiệu ứng nảy
      ),
    );

    _initializeData();
    widget.registerRefreshCallback?.call(_onRefresh);
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) {
      _listAnimationController.forward();
      _fabAnimationController.forward(); // Chạy animation FAB
    }
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await Future.wait([_fetchAccount(), _fetchResumeList()]);
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải dữ liệu. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset(); // Reset animation trước khi tải lại
    _fabAnimationController.reset();
    await _loadAllData();
    if (mounted) {
      _listAnimationController.forward();
      _fabAnimationController.forward();
    }
  }

  // ... (Các hàm _fetchAccount, _fetchResumeList, _pickAndUploadCV, _uploadCvToFirebase, _showSuccessSnackBar, _showErrorSnackBar, _formatFileSize, _deleteCV, _sortByName, _sortByDate, _showFilterDialog, _showHelp, _filteredResumeList giữ nguyên logic)
  // Chỉ cần đảm bảo setState được gọi đúng chỗ để UI cập nhật
  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data != null && data.isNotEmpty) {
        _account = Account.fromJson(data.first);
      }
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
        // setState(() { // Không cần setState ở đây nữa
        _resumeList.clear();
        _resumeList.addAll(
          response.map<Resume>((json) => Resume.fromJson(json)).toList(),
        );
        // });
      }
    } catch (e) {
      print('Error fetching resume: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải danh sách CV.')),
        );
      }
    }
  }

  Future<void> _pickAndUploadCV() async {
    if (_isUploadingCv) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang xử lý một lượt tải lên khác...')),
      );
      return;
    }
    setState(() => _uploadProgress = 0.0);
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        _pickedCvPlatformFile = result.files.first;
        await _uploadCvToFirebase();
      }
    } catch (e) {
      print("Error picking CV: $e");
      _showErrorSnackBar();
    }
  }

  Future<void> _uploadCvToFirebase() async {
    if (_pickedCvPlatformFile == null || _pickedCvPlatformFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một file CV.')),
      );
      return;
    }
    setState(() => _isUploadingCv = true);
    File fileToUpload = File(_pickedCvPlatformFile!.path!);
    String originalFileName = _pickedCvPlatformFile!.name;
    try {
      String userId = widget.idUser;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/$userId/cvs/$originalFileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(fileToUpload);
      uploadTask.snapshotEvents.listen(
        (firebase_storage.TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
          if (mounted) setState(() => _uploadProgress = progress);
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tải lên CV thất bại: $e')));
            setState(() {
              _isUploadingCv = false;
              _uploadProgress = 0.0;
            });
          }
        },
      );
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      try {
        Map<String, dynamic> cvData = {
          "idUser": userId,
          "fileUrl": downloadURL,
          "fileName": originalFileName,
          "fileSizeKB": _pickedCvPlatformFile!.size,
          "isDefault": _resumeList.isEmpty ? 1 : 0,
        };
        await _apiService.post(ApiConstants.resumeEndpoint, cvData);
        if (mounted) {
          _showSuccessSnackBar(originalFileName);
          await _onRefresh();
        }
      } catch (apiError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu thông tin CV: ${apiError.toString()}'),
          ),
        );
        await ref.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tải lên CV thất bại: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingCv = false;
          _pickedCvPlatformFile = null;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _showSuccessSnackBar(String fileName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
            ), // Icon tròn trịa hơn
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đã tải lên CV: $fileName',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700, // Màu xanh đậm hơn
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // Bo góc lớn hơn
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16), // Tăng margin
        action: SnackBarAction(
          label: 'ẨN', // Chữ hoa
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_rounded,
              color: Colors.white,
            ), // Icon tròn trịa hơn
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Không thể tải lên file. Vui lòng thử lại.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700, // Màu đỏ đậm hơn
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _deleteCV(Resume resumeToDelete) {
    // Sử dụng theme cho dialog
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ), // Bo góc dialog
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text(
                'Xác Nhận Xóa',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa vĩnh viễn CV "${resumeToDelete.fileName}" không? Hành động này không thể hoàn tác.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'HỦY BỎ',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext, true);
                // ... (logic xóa giữ nguyên)
                if (!mounted) return;
                final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Đang xóa CV: ${resumeToDelete.fileName}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                bool apiDeleted = false;
                try {
                  await _apiService.delete(
                    '${ApiConstants.resumeEndpoint}/${resumeToDelete.idResume}',
                  );
                  apiDeleted = true;
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.removeCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Lỗi xóa CV trên server: $e'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                  return;
                }
                if (apiDeleted &&
                    resumeToDelete.fileUrl != null &&
                    resumeToDelete.fileUrl!.isNotEmpty &&
                    resumeToDelete.fileUrl!.startsWith(
                      "https://firebasestorage.googleapis.com",
                    )) {
                  try {
                    await firebase_storage.FirebaseStorage.instance
                        .refFromURL(resumeToDelete.fileUrl!)
                        .delete();
                  } catch (e) {
                    if (!mounted) return;
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Lỗi xóa file trên Storage: $e. CV vẫn bị xóa khỏi danh sách.',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        duration: const Duration(seconds: 5),
                        backgroundColor: Colors.orange.shade800,
                      ),
                    );
                  }
                }
                if (!mounted) return;
                setState(
                  () => _resumeList.removeWhere(
                    (resume) => resume.idResume == resumeToDelete.idResume,
                  ),
                );
                scaffoldMessenger.removeCurrentSnackBar();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Đã xóa CV thành công',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'XÓA NGAY',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sortByName() {
    if (mounted) {
      setState(
        () => _resumeList.sort(
          (a, b) =>
              a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()),
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã sắp xếp CV theo tên.')));
    }
  }

  void _sortByDate() {
    if (mounted) {
      setState(
        () => _resumeList.sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sắp xếp CV theo ngày tạo.')),
      );
    }
  }

  void _showFilterDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.filter_alt_outlined, color: theme.primaryColor),
                const SizedBox(width: 10),
                const Text(
                  'Lọc CV Nâng Cao',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Tính năng lọc chi tiết theo ngành nghề, cấp bậc sẽ sớm được cập nhật. Hiện tại bạn có thể lọc theo loại file (PDF, Word) ở thanh bên dưới.',
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ĐÃ HIỂU',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelp() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.help_center_outlined,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Hướng Dẫn Sử Dụng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Chào mừng bạn đến với trang quản lý CV!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ' • Tìm kiếm CV nhanh chóng bằng tên file.',
                    style: TextStyle(height: 1.4),
                  ),
                  Text(
                    ' • Lọc CV theo định dạng PDF hoặc Word.',
                    style: TextStyle(height: 1.4),
                  ),
                  Text(
                    ' • Nhấn vào một CV để xem nội dung chi tiết.',
                    style: TextStyle(height: 1.4),
                  ),
                  Text(
                    ' • Sử dụng menu (⋮) trên mỗi CV để: Chỉnh sửa tên, Chia sẻ link, Tải xuống thiết bị, hoặc Xóa CV.',
                    style: TextStyle(height: 1.4),
                  ),
                  Text(
                    ' • Nhấn nút "+" ở góc dưới để thêm CV mới: Tải lên từ máy, Tạo CV bằng AI (sắp ra mắt), hoặc Sử dụng các mẫu CV chuyên nghiệp có sẵn.',
                    style: TextStyle(height: 1.4),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ' • Menu (⋮) ở góc trên cùng cho phép bạn: Sắp xếp danh sách CV hoặc xem lại hướng dẫn này.',
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OKAY, TÔI HIỂU RỒI!',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  List<Resume> get _filteredResumeList {
    List<Resume> filtered = List.from(_resumeList);
    if (_searchTerm.isNotEmpty) {
      filtered =
          filtered
              .where(
                (resume) => resume.fileName.toLowerCase().contains(
                  _searchTerm.toLowerCase(),
                ),
              )
              .toList();
    }
    if (_selectedFilter != 'Tất cả') {
      if (_selectedFilter == 'PDF') {
        filtered =
            filtered
                .where(
                  (resume) => resume.fileName.toLowerCase().endsWith('.pdf'),
                )
                .toList();
      } else if (_selectedFilter == 'Word') {
        filtered =
            filtered
                .where(
                  (resume) =>
                      resume.fileName.toLowerCase().endsWith('.doc') ||
                      resume.fileName.toLowerCase().endsWith('.docx'),
                )
                .toList();
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF1C1C1E)
              : const Color(0xFFF9F9F9), // Nền sạch sẽ hơn
      body: Container(
        color: theme.cardColor, // Hoặc màu nền phù hợp
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ), // Đảm bảo luôn cuộn được
          slivers: [
            SliverToBoxAdapter(
              // Bọc các widget không cuộn trong SliverToBoxAdapter
              child: Column(
                children: [
                  _buildSearchBarAndActions(theme, isDarkMode),
                  if (_isUploadingCv) _buildUploadProgressIndicator(theme),
                  _buildCvCountAndFilters(theme),
                ],
              ),
            ),
            _isLoading
                ? SliverFillRemaining(
                  // Sử dụng SliverFillRemaining cho trạng thái loading/empty
                  child: Center(
                    child: CircularProgressIndicator(color: theme.primaryColor),
                  ),
                )
                : _filteredResumeList.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(theme))
                : SliverList(
                  // Sử dụng SliverList cho ListView.builder
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final resume = _filteredResumeList[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 475),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            // Thêm Padding ở đây thay vì trong ListView
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              14,
                            ), // bottom 14
                            child: _buildCVCard(resume: resume, theme: theme),
                          ),
                        ),
                      ),
                    );
                  }, childCount: _filteredResumeList.length),
                ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        // Animation cho FAB
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateOptions(context),
          backgroundColor: theme.colorScheme.primary,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: Text(
            "Thêm CV",
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBarAndActions(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        // boxShadow đã có ở AppBar
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên CV...',
                hintStyle: TextStyle(
                  color: theme.hintColor.withOpacity(0.6),
                  fontSize: 15.5,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.primaryColor.withOpacity(0.8),
                  size: 24,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                  isDarkMode ? 0.2 : 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            // Để có hiệu ứng ripple đẹp
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 26,
              ),
              tooltip: 'Tùy chọn & Sắp xếp',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    _buildPopupMenuItem(
                      Icons.sort_by_alpha_rounded,
                      'Sắp xếp: Tên (A-Z)',
                      'sort_name',
                      theme,
                    ),
                    _buildPopupMenuItem(
                      Icons.date_range_rounded,
                      'Sắp xếp: Ngày tạo',
                      'sort_date',
                      theme,
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem(
                      Icons.filter_alt_off_outlined,
                      'Lọc CV (Nâng cao)',
                      'filter',
                      theme,
                    ),
                    _buildPopupMenuItem(
                      Icons.help_outline_rounded,
                      'Trợ giúp',
                      'help',
                      theme,
                    ),
                  ],
              onSelected: (String value) {
                switch (value) {
                  case 'sort_name':
                    _sortByName();
                    break;
                  case 'sort_date':
                    _sortByDate();
                    break;
                  case 'filter':
                    _showFilterDialog();
                    break;
                  case 'help':
                    _showHelp();
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Đang tải lên: ${_pickedCvPlatformFile?.name ?? 'CV của bạn'}...",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            backgroundColor: theme.dividerColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            minHeight: 8, // Dày hơn
            borderRadius: BorderRadius.circular(4), // Bo góc
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvCountAndFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), // Giảm padding top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42, // Chiều cao cố định cho hàng filter
            child: SingleChildScrollView(
              // <--- BỌC TRONG SingleChildScrollView
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                // Row chứa các chip
                children: [
                  _buildFilterChip(
                    'Tất cả',
                    _selectedFilter == 'Tất cả',
                    () => setState(() => _selectedFilter = 'Tất cả'),
                    theme,
                  ),
                  _buildFilterChip(
                    'PDF',
                    _selectedFilter == 'PDF',
                    () => setState(() => _selectedFilter = 'PDF'),
                    theme,
                  ),
                  _buildFilterChip(
                    'Word',
                    _selectedFilter == 'Word',
                    () => setState(() => _selectedFilter = 'Word'),
                    theme,
                  ),
                  // Thêm các filter khác nếu cần, ví dụ:
                  // _buildFilterChip('Mới nhất', _selectedFilter == 'Mới nhất', () => setState(() => _selectedFilter = 'Mới nhất'), theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    IconData icon,
    String text,
    String value,
    ThemeData theme,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ), // Icon nhỏ hơn một chút
          const SizedBox(width: 14),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // Khoảng cách giữa các chip
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) onSelected();
        },
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
          isSelected ? 0.3 : 0.6,
        ), // Màu nền khác nhau
        selectedColor: theme.colorScheme.primaryContainer,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color:
              isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
          fontWeight:
              isSelected
                  ? FontWeight.bold
                  : FontWeight.w500, // Đậm hơn khi selected
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Bo tròn hơn
          side: BorderSide(
            color:
                isSelected
                    ? theme.colorScheme.primary.withOpacity(0.6)
                    : theme.dividerColor.withOpacity(
                      0.4,
                    ), // Border rõ hơn khi selected
            width: isSelected ? 1.8 : 1.2, // Border dày hơn khi selected
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ), // Điều chỉnh padding
        showCheckmark: false, // Bỏ checkmark mặc định
        elevation: isSelected ? 1.5 : 0.5, // Thêm chút elevation
        selectedShadowColor: theme.colorScheme.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchTerm.isEmpty
                  ? Icons.folder_off_outlined
                  : Icons.search_off_rounded, // Icon khác
              size: 80, // Giảm kích thước icon
              color: theme.hintColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _searchTerm.isEmpty
                  ? "Kho CV của bạn đang trống"
                  : "Không tìm thấy CV nào",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchTerm.isEmpty
                  ? "Hãy bắt đầu bằng cách tạo CV mới hoặc tải lên những CV bạn đã có sẵn."
                  : "Vui lòng thử lại với từ khóa khác hoặc điều chỉnh bộ lọc của bạn nhé.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                height: 1.45,
              ),
            ),
            if (_searchTerm.isEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _showCreateOptions(context),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text("Tạo CV Ngay"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCVCard({required Resume resume, required ThemeData theme}) {
    final String fileName = resume.fileName;
    final String fileSize =
        resume.fileSizeKB != null ? _formatFileSize(resume.fileSizeKB) : "N/A";
    final String date = FormatUtils.formattedDateTime(resume.createdAt);
    final bool isPdf = fileName.toLowerCase().endsWith('.pdf');
    final Color fileIconBgColor =
        isPdf
            ? theme.colorScheme.errorContainer.withOpacity(0.6)
            : theme.colorScheme.primaryContainer.withOpacity(0.6);
    final Color fileIconColor =
        isPdf
            ? theme.colorScheme.onErrorContainer.withOpacity(0.9)
            : theme.colorScheme.onPrimaryContainer.withOpacity(0.9);
    final IconData fileIcon =
        isPdf ? Icons.picture_as_pdf_rounded : Icons.article_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 14), // Giảm margin dưới một chút
      elevation: 1.5, // Giảm elevation
      shadowColor: theme.shadowColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ), // Bo góc vừa phải
      child: InkWell(
        onTap: () => _viewCV(context, resume),
        borderRadius: BorderRadius.circular(14),
        splashColor: theme.primaryColor.withOpacity(0.08),
        highlightColor: theme.primaryColor.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ), // Điều chỉnh padding
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48, // Kích thước icon container
                decoration: BoxDecoration(
                  color: fileIconBgColor,
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Bo góc container icon
                ),
                child: Icon(fileIcon, color: fileIconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600, // Đậm hơn một chút
                        color: theme.colorScheme.onSurface,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), // Giảm khoảng cách
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.sd_storage_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          fileSize,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  size: 24,
                ), // Icon nhỏ hơn
                tooltip: 'Tùy chọn CV',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2, // Giảm elevation
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      _buildPopupMenuItem(
                        Icons.edit_note_rounded,
                        'Chỉnh sửa tên',
                        'edit_name',
                        theme,
                      ),
                      _buildPopupMenuItem(
                        Icons.share_rounded,
                        'Chia sẻ',
                        'share',
                        theme,
                      ),
                      _buildPopupMenuItem(
                        Icons.download_for_offline_rounded,
                        'Tải xuống',
                        'download',
                        theme,
                      ),
                      const PopupMenuDivider(height: 0.5), // Divider mỏng hơn
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.error,
                              size: 20,
                            ), // Icon khác
                            const SizedBox(width: 12),
                            Text(
                              'Xóa CV',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                onSelected: (String value) async {
                  switch (value) {
                    case 'edit_name':
                      await _editCVName(context, resume);
                      break;
                    case 'share':
                      _shareCV(context, resume);
                      break;
                    case 'download':
                      await _downloadCV(context, resume);
                      break;
                    case 'delete':
                      _deleteCV(resume);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal tạo CV mới
  void _showCreateOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Để Container bên trong kiểm soát màu và bo góc
      isScrollControlled: true, // Cho phép modal cao hơn nửa màn hình
      builder:
          (context) => StatefulBuilder(
            // Sử dụng StatefulBuilder để modal có thể tự cập nhật state (cho progress bar)
            builder: (BuildContext context, StateSetter modalSetState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      20, // Padding cho bàn phím (nếu có)
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor, // Màu nền từ theme
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ), // Bo góc lớn hơn
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // Header của Modal
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Thêm CV Mới",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.iconTheme.color?.withOpacity(0.7),
                            size: 26,
                          ),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: theme.dividerColor.withOpacity(0.5)),
                    const SizedBox(height: 15),

                    _buildOptionItem(
                      icon: Icons.cloud_upload_rounded,
                      title: "Tải Lên Từ Thiết Bị",
                      subtitle: "Chọn file PDF, DOC, DOCX từ máy của bạn.",
                      iconBgColor: theme.colorScheme.primaryContainer
                          .withOpacity(0.7),
                      iconColor: theme.colorScheme.onPrimaryContainer,
                      onTap:
                          _isUploadingCv
                              ? null
                              : () {
                                Navigator.pop(
                                  context,
                                ); // Đóng modal trước khi chọn file
                                _pickAndUploadCV();
                              },
                      trailingWidget:
                          _isUploadingCv
                              ? SizedBox(
                                width: 120, // Giới hạn chiều rộng cho progress
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    LinearProgressIndicator(
                                      value:
                                          _uploadProgress > 0 &&
                                                  _uploadProgress < 1
                                              ? _uploadProgress
                                              : (_uploadProgress >= 1
                                                  ? 1.0
                                                  : null),
                                      backgroundColor: theme.dividerColor
                                          .withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.primaryColor,
                                      ),
                                      minHeight: 6, // Dày hơn một chút
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                              : Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: theme.iconTheme.color?.withOpacity(0.5),
                              ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: theme.dividerColor.withOpacity(0.2)),
                    const SizedBox(height: 10),
                    _buildOptionItem(
                      icon: Icons.auto_awesome_rounded, // Icon AI mới
                      title: "Tạo CV Bằng AI",
                      subtitle:
                          "Để trí tuệ nhân tạo hỗ trợ bạn tạo CV ấn tượng.",
                      iconBgColor: theme.colorScheme.secondaryContainer
                          .withOpacity(0.7),
                      iconColor: theme.colorScheme.onSecondaryContainer,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tính năng AI CV sẽ sớm được cập nhật!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: theme.colorScheme.secondary,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Divider(color: theme.dividerColor.withOpacity(0.2)),
                    const SizedBox(height: 10),
                    _buildOptionItem(
                      icon: Icons.article_outlined, // Icon mẫu CV
                      title: "Sử Dụng Mẫu CV Có Sẵn",
                      subtitle: "Lựa chọn từ thư viện mẫu CV chuyên nghiệp.",
                      iconBgColor: theme.colorScheme.tertiaryContainer
                          .withOpacity(0.7),
                      iconColor: theme.colorScheme.onTertiaryContainer,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CVTemplatesScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                    const SizedBox(height: 10), // Khoảng trống dưới cùng
                  ],
                ),
              );
            },
          ),
    );
  }

  // Hàm upload mới để có thể cập nhật UI của modal
  Future<void> _uploadCvToFirebaseWithModalUpdate(
    StateSetter modalSetState,
  ) async {
    if (_pickedCvPlatformFile == null || _pickedCvPlatformFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một file CV.')),
      );
      return;
    }
    // Cập nhật state chung và state của modal
    setState(() => _isUploadingCv = true);
    modalSetState(() => _isUploadingCv = true); // Cập nhật cả modal

    File fileToUpload = File(_pickedCvPlatformFile!.path!);
    String originalFileName = _pickedCvPlatformFile!.name;
    try {
      String userId = widget.idUser;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/$userId/cvs/$originalFileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(fileToUpload);

      uploadTask.snapshotEvents.listen(
        (firebase_storage.TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
          if (mounted) {
            // Cập nhật state chung và state của modal
            setState(() => _uploadProgress = progress);
            modalSetState(() => _uploadProgress = progress);
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tải lên CV thất bại: $e')));
            // Cập nhật state chung và state của modal
            setState(() {
              _isUploadingCv = false;
              _uploadProgress = 0.0;
            });
            modalSetState(() {
              _isUploadingCv = false;
              _uploadProgress = 0.0;
            });
          }
        },
      );
      // ... (phần còn lại của logic upload và lưu API giữ nguyên)
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      try {
        Map<String, dynamic> cvData = {
          "idUser": userId,
          "fileUrl": downloadURL,
          "fileName": originalFileName,
          "fileSizeKB": _pickedCvPlatformFile!.size,
          "isDefault": _resumeList.isEmpty ? 1 : 0,
        };
        await _apiService.post(ApiConstants.resumeEndpoint, cvData);
        if (mounted) {
          _showSuccessSnackBar(originalFileName);
          await _onRefresh();
        }
      } catch (apiError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu thông tin CV: ${apiError.toString()}'),
          ),
        );
        await ref.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tải lên CV thất bại: $e')));
      }
    } finally {
      if (mounted) {
        // Cập nhật state chung và state của modal
        setState(() {
          _isUploadingCv = false;
          _pickedCvPlatformFile = null;
          _uploadProgress = 0.0;
        });
        modalSetState(() {
          _isUploadingCv = false;
          _pickedCvPlatformFile = null;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Color iconBgColor,
    required Color iconColor,
    Widget? trailingWidget,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Bo góc cho hiệu ứng chạm
      splashColor: iconBgColor.withOpacity(0.5), // Màu splash
      highlightColor: iconBgColor.withOpacity(0.3), // Màu highlight
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 8.0,
        ), // Tăng padding
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14), // Tăng padding icon
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14), // Bo góc lớn hơn
              ),
              child: Icon(icon, color: iconColor, size: 26), // Icon lớn hơn
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, // Đậm hơn
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.8,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10), // Khoảng cách trước trailing widget
            trailingWidget ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
          ],
        ),
      ),
    );
  }

  void _viewCV(BuildContext context, Resume resume) {
    if (resume.fileUrl != null && resume.fileUrl!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FileViewerScreen(
                fileUrl: resume.fileUrl!,
                fileName: resume.fileName,
              ),
        ),
      ).then((_) => _onRefresh());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy URL của file CV.')),
        );
      }
    }
  }

  Future<void> _editCVName(BuildContext context, Resume resume) async {
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController(
      text: resume.fileName,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String? newFileNameFull = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.drive_file_rename_outline_rounded,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 10),
              const Text(
                'Chỉnh Sửa Tên CV',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Nhập tên file mới",
                helperText: "Phần mở rộng (.pdf, .docx) sẽ được giữ nguyên.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Tên file không được để trống'
                          : null,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'HỦY',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text(
                'LƯU',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(nameController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
    // ... (logic xử lý đổi tên giữ nguyên)
    if (newFileNameFull == null) return;
    final String finalNewFileName = newFileNameFull.trim();
    if (finalNewFileName == resume.fileName) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Tên file không thay đổi.')));
      return;
    }
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(this.context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Đang cập nhật tên CV thành $finalNewFileName...'),
      ),
    );
    String oldFileUrl = resume.fileUrl!;
    String newFileUrl = oldFileUrl;
    if (oldFileUrl.isNotEmpty &&
        oldFileUrl.startsWith("https://firebasestorage.googleapis.com")) {
      try {
        final firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;
        final oldRef = storage.refFromURL(oldFileUrl);
        final List<String> pathSegments = oldRef.fullPath.split('/');
        pathSegments.removeLast();
        pathSegments.add(finalNewFileName);
        final String newFullPath = pathSegments.join('/');
        final newRef = storage.ref().child(newFullPath);
        final firebase_storage.FullMetadata oldMetadata =
            await oldRef.getMetadata();
        final Uint8List? fileData = await oldRef.getData();
        if (fileData != null) {
          final firebase_storage.SettableMetadata newSettableMetadata =
              firebase_storage.SettableMetadata(
                contentType: oldMetadata.contentType,
              );
          await newRef.putData(fileData, newSettableMetadata);
          newFileUrl = await newRef.getDownloadURL();
        } else {
          throw Exception("Không thể lấy dữ liệu file cũ từ Storage.");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đổi tên trên Storage: $e. Sử dụng URL cũ.'),
            ),
          );
        }
        newFileUrl = oldFileUrl;
      }
    }
    try {
      await _apiService.put(
        '${ApiConstants.resumeEndpoint}/${resume.idResume}',
        {'fileName': finalNewFileName, 'fileUrl': newFileUrl},
      );
      if (newFileUrl != oldFileUrl &&
          oldFileUrl.isNotEmpty &&
          oldFileUrl.startsWith("https://firebasestorage.googleapis.com")) {
        try {
          await firebase_storage.FirebaseStorage.instance
              .refFromURL(oldFileUrl)
              .delete();
        } catch (e) {
          print("Lỗi khi xóa file cũ trên Storage sau khi đổi tên: $e");
        }
      }
      if (mounted) {
        setState(() {
          final index = _resumeList.indexWhere(
            (r) => r.idResume == resume.idResume,
          );
          if (index != -1) {
            _resumeList[index] = _resumeList[index].copyWith(
              fileName: finalNewFileName,
              fileUrl: newFileUrl,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật tên CV thành: $finalNewFileName'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật thông tin CV: $e')),
        );
      }
      if (newFileUrl != oldFileUrl &&
          newFileUrl.isNotEmpty &&
          newFileUrl.startsWith("https://firebasestorage.googleapis.com")) {
        try {
          await firebase_storage.FirebaseStorage.instance
              .refFromURL(newFileUrl)
              .delete();
        } catch (storageDeleteError) {
          print("Lỗi khi rollback file mới trên Storage: $storageDeleteError");
        }
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _shareCV(BuildContext context, Resume resume) {
    if (resume.fileUrl != null && resume.fileUrl!.isNotEmpty) {
      Share.share(
        'Xem CV của tôi: ${resume.fileUrl!}',
        subject: 'CV: ${resume.fileName}',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có URL để chia sẻ CV này.')),
        );
      }
    }
  }

  Future<void> _downloadCV(BuildContext context, Resume resume) async {
    if (resume.fileUrl == null || resume.fileUrl!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có URL để tải CV này.')),
        );
      }
      return;
    }
    bool permissionsGranted = true;
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) status = await Permission.storage.request();
      permissionsGranted = status.isGranted;
    }
    if (!permissionsGranted && Platform.isAndroid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền truy cập bộ nhớ để tải file.'),
          ),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đang tải xuống ${resume.fileName}...')),
      );
    }
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${resume.fileName}';
      final response = await http.get(Uri.parse(resume.fileUrl!));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Lỗi tải file: ${response.statusCode}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tải xong: ${resume.fileName}. Đang mở...'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể mở file: ${result.message}. File đã được lưu tại: $filePath',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải hoặc mở CV: $e')));
      }
    }
  }
}

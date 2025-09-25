import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/company_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/features/company/screens/company_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Thêm thư viện

class CompanyScreen extends StatefulWidget {
  final String idUser;
  const CompanyScreen({Key? key, required this.idUser}) : super(key: key);

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen>
    with TickerProviderStateMixin {
  // Thêm TickerProviderStateMixin
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  List<Company> _companyList = [];
  bool _isLoading = true;
  List<JobPosting> _jobList = [];
  List<Company> _filteredCompanies = [];
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late AnimationController _listAnimationController; // Animation cho danh sách

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) _listAnimationController.forward();
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await Future.wait([_fetchCompanyList(), _fetchJobs()]);
    } catch (e) {
      if (mounted)
        setState(() => _errorMessage = "Lỗi tải dữ liệu: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    _searchController.clear(); // Xóa tìm kiếm khi refresh
    await _loadAllData();
    if (mounted) _listAnimationController.forward();
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await _apiService.get(ApiConstants.jobPostingEndpoint);
      if (mounted) {
        // setState(() { // Không cần setState ở đây nữa
        _jobList.clear();
        _jobList.addAll(response.map((job) => JobPosting.fromJson(job)));
        // });
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<void> _fetchCompanyList() async {
    try {
      final data = await _apiService.get(ApiConstants.companiesEndpoint);
      if (mounted) {
        // setState(() { // Không cần setState ở đây nữa
        _companyList.clear();
        _companyList.addAll(
          data.map<Company>((item) => Company.fromJson(item)).toList(),
        );
        // Sắp xếp theo tên công ty
        _companyList.sort(
          (a, b) => a.companyName.toLowerCase().compareTo(
            b.companyName.toLowerCase(),
          ),
        );
        _filteredCompanies = List.from(_companyList);
        // });
      }
    } catch (e) {
      print('Error fetching companies: $e');
      if (mounted)
        setState(() => _errorMessage = "Không thể tải danh sách công ty.");
    }
  }

  String _removeDiacritics(String input) {
    // ... (giữ nguyên hàm này)
    final diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'Á': 'A',
      'À': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'É': 'E',
      'È': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ế': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ố': 'O',
      'Ồ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ớ': 'O',
      'Ờ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ứ': 'U',
      'Ừ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Giảm debounce time một chút
      _filterCompanies(_searchController.text);
    });
  }

  void _filterCompanies(String query) {
    if (!mounted) return;
    final lowerCaseQuery = _removeDiacritics(query.toLowerCase());
    setState(() {
      _listAnimationController.reset(); // Reset animation khi filter
      if (query.isEmpty) {
        _filteredCompanies = List.from(_companyList);
      } else {
        _filteredCompanies =
            _companyList.where((company) {
              final companyNameNormalized = _removeDiacritics(
                company.companyName.toLowerCase(),
              );
              final industryNormalized =
                  company.industry != null
                      ? _removeDiacritics(company.industry!.toLowerCase())
                      : '';
              final addressNormalized =
                  company.address != null
                      ? _removeDiacritics(company.address!.toLowerCase())
                      : '';
              return companyNameNormalized.contains(lowerCaseQuery) ||
                  industryNormalized.contains(lowerCaseQuery) ||
                  addressNormalized.contains(lowerCaseQuery);
            }).toList();
      }
      _listAnimationController.forward(); // Chạy lại animation
    });
  }

  int _getJobCountForCompany(String companyId) {
    return _jobList.where((job) => job.idCompany == companyId).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final SystemUiOverlayStyle systemOverlayStyle =
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF4F6F8), // Nền tinh tế
      appBar: AppBar(
        elevation: 0.8, // Shadow nhẹ
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          // Nút back tùy chỉnh
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Khám Phá Doanh Nghiệp',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: systemOverlayStyle,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: Column(
          children: [
            _buildSearchBar(context, theme),
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      )
                      : _errorMessage.isNotEmpty
                      ? _buildErrorState(context, _errorMessage, theme)
                      : _filteredCompanies.isEmpty
                      ? _buildEmptyState(
                        context,
                        _searchController.text.isNotEmpty,
                        theme,
                      )
                      : AnimationLimiter(
                        // Thêm AnimationLimiter
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ), // Luôn cho phép cuộn
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16,
                          ), // Điều chỉnh padding
                          itemCount: _filteredCompanies.length,
                          itemBuilder: (context, index) {
                            final company = _filteredCompanies[index];
                            return AnimationConfiguration.staggeredList(
                              // Animation cho từng card
                              position: index,
                              duration: const Duration(milliseconds: 425),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildCompanyCard(
                                    context,
                                    company,
                                    theme,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, ngành nghề, địa chỉ...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor.withOpacity(0.7),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.iconTheme.color?.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () => _searchController.clear(),
                  splashRadius: 20,
                )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 70,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh, // Gọi _onRefresh
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Thử Lại Ngay"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isSearching,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0), // Tăng padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.apartment_rounded, // Icon khác
              size: 80, // Icon lớn hơn
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching
                  ? "Không Tìm Thấy Công Ty"
                  : "Chưa Có Dữ Liệu Công Ty",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? "Vui lòng thử lại với từ khóa tìm kiếm khác hoặc kiểm tra kết nối mạng."
                  : "Chúng tôi đang cập nhật dữ liệu. Vui lòng quay lại sau hoặc thử làm mới.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                isSearching ? "Xóa Tìm Kiếm & Làm Mới" : "Làm Mới Danh Sách",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    Company company,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final jobCount = _getJobCountForCompany(company.idCompany);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shadowColor: theme.shadowColor.withOpacity(isDarkMode ? 0.15 : 0.08),
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailsScreen(
                company: company,
                idUser: widget.idUser,
              ),
            ),
          ).then((_) => _onRefresh());
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor,
                theme.cardColor.withOpacity(0.95),
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: (company.logoCompany != null &&
                          company.logoCompany!.isNotEmpty)
                      ? Image.network(
                          company.logoCompany!,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Center(
                            child: Image.asset(
                              "assets/images/logohuit.png",
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            company.companyName.isNotEmpty
                                ? company.companyName[0].toUpperCase()
                                : 'C',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      company.companyName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (company.industry != null &&
                        company.industry!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              company.industry!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.8),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            company.address ?? 'Chưa cập nhật',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.8),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_rounded,
                            size: 14,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$jobCount Việc Làm',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

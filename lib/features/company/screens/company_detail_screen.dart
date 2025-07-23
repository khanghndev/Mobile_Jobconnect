import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/company_model.dart';
import 'package:job_connect/core/data/models/job_posting_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/core/config/utils/format.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Thêm thư viện

class CompanyDetailsScreen extends StatefulWidget {
  final String idUser;
  final Company company;

  const CompanyDetailsScreen({
    super.key,
    required this.company,
    required this.idUser,
  });

  @override
  CompanyDetailState createState() => CompanyDetailState();
}

class CompanyDetailState extends State<CompanyDetailsScreen>
    with TickerProviderStateMixin {
  // Thêm TickerProviderStateMixin
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  List<JobPosting> _companyJobsList = [];
  bool _isLoadingCompanyJobs = true;
  String _companyJobsError = '';

  late AnimationController _animationController; // Animation cho các card
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchAndFilterCompanyJobs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndFilterCompanyJobs() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCompanyJobs = true;
      _companyJobsError = '';
      _companyJobsList.clear();
    });
    try {
      final responseData = await _apiService.get(
        ApiConstants.jobPostingEndpoint,
      );
      List<JobPosting> allJobs =
          responseData
              .map<JobPosting>((job) => JobPosting.fromJson(job))
              .toList();
      String targetCompanyId = widget.company.idCompany;
      // Lọc và sắp xếp: công việc nổi bật lên đầu, sau đó theo ngày tạo mới nhất
      allJobs =
          allJobs.where((job) => job.idCompany == targetCompanyId).toList();
      allJobs.sort((a, b) {
        if (a.isFeatured == 1 && b.isFeatured != 1) return -1;
        if (a.isFeatured != 1 && b.isFeatured == 1) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      if (mounted) {
        setState(() => _companyJobsList = allJobs);
        _animationController.forward(
          from: 0.0,
        ); // Chạy animation sau khi có jobs
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companyJobsError = "Lỗi tải công việc: ${e.toString()}";
          _companyJobsList = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingCompanyJobs = false);
    }
  }

  Future<void> _onRefresh() async {
    _animationController.reset();
    await _fetchAndFilterCompanyJobs();
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(
      url.startsWith('http') ? url : 'https://$url',
    ); // Đảm bảo có scheme
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể mở liên kết: $url')));
      }
    }
  }

  Widget _buildCompanyLogo(BuildContext context, ThemeData theme) {
    final companyInitial =
        (widget.company.companyName.isNotEmpty)
            ? widget.company.companyName[0].toUpperCase()
            : "C";
    final String? coverPhotoUrl =
        widget.company.logoCompany; // Giả sử có trường này

    return Stack(
      alignment: Alignment.center, // Căn giữa các thành phần trong Stack
      children: [
        // Lớp 1: Ảnh bìa hoặc Gradient nền
        Container(
          // Chiều cao này sẽ là chiều cao của FlexibleSpaceBar.background
          // Nó cần đủ lớn để chứa ảnh bìa và phần logo nhô ra
          height: 280.0, // Có thể điều chỉnh chiều cao này
          decoration: BoxDecoration(
            gradient:
                (coverPhotoUrl == null || coverPhotoUrl.isEmpty)
                    ? LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(
                          0.9,
                        ), // Màu đậm hơn ở trên
                        theme.primaryColor.withOpacity(
                          0.6,
                        ), // Màu nhạt hơn ở dưới
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                    : null,
            image:
                (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                    ? DecorationImage(
                      image: NetworkImage(coverPhotoUrl),
                      fit: BoxFit.cover,
                      // Lớp phủ nhẹ lên ảnh bìa để text/logo nổi hơn
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.35),
                        BlendMode.darken,
                      ),
                    )
                    : null,
          ),
        ),

        // Lớp 2: Logo và Tên công ty (khi SliverAppBar mở rộng)
        // Positioned này để đảm bảo logo và tên công ty nằm ở vị trí đẹp khi header mở rộng
        // và không bị che bởi title của SliverAppBar khi co lại.
        Positioned(
          // bottom: 65, // Điều chỉnh vị trí này để logo và tên không quá sát title khi co lại
          // Hoặc sử dụng Column và MainAxisAlignment.center nếu không có ảnh bìa
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, // Kích thước logo
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor, // Nền cho logo
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.25),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      (widget.company.logoCompany != null &&
                              widget.company.logoCompany!.isNotEmpty)
                          ? Image.network(
                            widget.company.logoCompany!,
                            fit: BoxFit.contain, // Contain để thấy rõ logo
                            errorBuilder:
                                (context, error, stackTrace) => Center(
                                  child: Image.asset(
                                    "assets/images/logohuit.png",
                                  ),
                                ),
                          )
                          : Center(
                            child: Text(
                              companyInitial,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              // Tên công ty sẽ hiển thị ở đây khi header mở rộng
              // Nó sẽ bị ẩn đi bởi title của FlexibleSpaceBar khi co lại
              // Chúng ta sẽ dùng Opacity để làm mờ nó đi khi title của FlexibleSpaceBar xuất hiện
              // (Cần tính toán scroll offset để làm điều này, hoặc đơn giản là chấp nhận nó bị che)
              Text(
                widget.company.companyName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color:
                      (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                          ? Colors.white
                          : theme.colorScheme.onPrimary, // Màu chữ tùy theo nền
                  fontWeight: FontWeight.bold,
                  shadows:
                      (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                          ? [
                            // Shadow cho chữ trên ảnh
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.company.industry!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.company.industry!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.onPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String? content,
    bool isLink = false,
    ThemeData? themeData,
  }) {
    final theme =
        themeData ??
        Theme.of(context); // Sử dụng theme được truyền vào hoặc theme mặc định
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Tăng padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Tăng padding icon
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(
                0.6,
              ), // Màu nền icon
              borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ), // Icon nhỏ hơn chút
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    // Sử dụng labelLarge
                    fontWeight: FontWeight.w600, // Đậm hơn
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style:
                      isLink
                          ? theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500, // Link đậm hơn
                          )
                          : theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            height: 1.45, // Tăng chiều cao dòng
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyJobCard(
    BuildContext context,
    JobPosting job,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final jobCompanyLogoUrl = job.company.logoCompany;
    final jobCompanyName = job.company.companyName;
    final jobCompanyInitial =
        (jobCompanyName.isNotEmpty) ? jobCompanyName[0].toUpperCase() : "J";
    final salaryText =
        (job.salary != null && job.salary! > 0)
            ? FormatUtils.formatSalary(job.salary!)
            : "Thỏa Thuận";

    return Card(
      elevation: 2.5, // Tăng elevation
      margin: const EdgeInsets.only(bottom: 16.0), // Tăng margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ), // Bo góc lớn hơn
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => JobDetailScreen(
                    idUser: widget.idUser,
                    idJobPost: job.idJobPost,
                  ),
            ),
          ).then((_) => _onRefresh());
        },
        borderRadius: BorderRadius.circular(16.0),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Tăng padding
          child: Column(
            // Sử dụng Column để thêm tag "Nổi bật"
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60, // Tăng kích thước logo
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                        width: 0.8,
                      ),
                    ),
                    child:
                        (jobCompanyLogoUrl != null &&
                                jobCompanyLogoUrl.isNotEmpty)
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                jobCompanyLogoUrl,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (c, e, s) => Center(
                                      child: Image.asset(
                                        "assets/images/logohuit.png",
                                      ),
                                    ),
                              ),
                            )
                            : Center(
                              child: Text(
                                jobCompanyInitial,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.isFeatured == 1) // Tag "Nổi bật"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade600,
                                  Colors.orange.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NỔI BẬT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          jobCompanyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 14), // Tăng khoảng cách
              Wrap(
                spacing: 10.0, // Tăng spacing
                runSpacing: 8.0,
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.attach_money_rounded,
                    text: salaryText,
                    color: theme.colorScheme.secondary,
                    theme: theme,
                  ),
                  if (job.workType.isNotEmpty)
                    _buildInfoChip(
                      context,
                      icon: Icons.work_history_outlined,
                      text: job.workType,
                      color: theme.colorScheme.primary,
                      theme: theme,
                    ),
                  if (job.experienceLevel.isNotEmpty)
                    _buildInfoChip(
                      context,
                      icon: Icons.military_tech_outlined,
                      text: job.experienceLevel!,
                      color: theme.colorScheme.tertiary,
                      theme: theme,
                    ),
                  _buildInfoChip(
                    context,
                    icon: Icons.calendar_month_outlined,
                    text:
                        "Đăng ${FormatUtils.formattedDateTime(job.createdAt)}",
                    color: theme.colorScheme.onSurfaceVariant,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ), // Tăng padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Nền đậm hơn
        borderRadius: BorderRadius.circular(10), // Bo góc lớn hơn
        // border: Border.all(color: color.withOpacity(0.4), width: 1) // Có thể thêm border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18), // Icon lớn hơn
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ), // Chữ đậm hơn
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
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

  Widget _buildContentCard(
    String content,
    ThemeData theme, {
    bool isHtml = false,
  }) {
    return Card(
      elevation: 1.5,
      shadowColor: theme.shadowColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content.isNotEmpty ? content : "Chưa có thông tin.",
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF4F6F8), // Nền tinh tế
      // AppBar được loại bỏ để sử dụng CustomScrollView với SliverAppBar
      body: RefreshIndicator(
        // Thêm RefreshIndicator ở đây
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: CustomScrollView(
          // Sử dụng CustomScrollView
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight:
                  280.0, // Chiều cao khi mở rộng (chứa ảnh bìa và logo)
              floating: false,
              pinned: true, // AppBar sẽ pin lại khi cuộn lên
              stretch: true, // Cho phép stretch
              backgroundColor: theme.colorScheme.primary, // Màu nền khi co lại
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2.0,
              systemOverlayStyle:
                  SystemUiOverlayStyle.light, // Icon status bar màu trắng
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                background: _buildCompanyLogo(
                  context,
                  theme,
                ), // Phần header với logo và ảnh bìa
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 50.0,
                  bottom: 16.0,
                  end: 50.0,
                ), // Điều chỉnh padding
                centerTitle: true,
                title: Text(
                  // Title này sẽ chỉ hiển thị khi AppBar co lại
                  widget.company.companyName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color:
                        Colors
                            .white, // Luôn là màu trắng để nổi trên nền primary
                    fontWeight: FontWeight.bold,
                    // Thêm shadow để dễ đọc hơn khi co lại trên nền ảnh (nếu ảnh bìa phức tạp)
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _onRefresh,
                  tooltip: 'Làm mới',
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {
                    // Chia sẻ thông tin công ty
                    final shareContent =
                        'Công ty: ${widget.company.companyName}\n'
                        'Ngành nghề: ${widget.company.industry}\n'
                        'Địa chỉ: ${widget.company.address}\n'
                        'Website: ${widget.company.websiteUrl ?? "Chưa có"}';
                    // Sử dụng package share để chia sẻ
                    Share.share(shareContent);
                  },
                  tooltip: 'Chia sẻ',
                ),
              ],
            ),
            SliverToBoxAdapter(
              // Phần còn lại của nội dung
              child: FadeTransition(
                // Animation cho nội dung
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 400),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        _buildSectionTitle(
                          context,
                          "Giới Thiệu Công Ty",
                          Icons.info_outline_rounded,
                          theme,
                        ),
                        _buildContentCard(
                          widget.company.description ??
                              'Chưa có thông tin giới thiệu.',
                          theme,
                        ),
                        const SizedBox(height: 24),

                        _buildSectionTitle(
                          context,
                          "Thông Tin Liên Hệ",
                          Icons.contact_page_outlined,
                          theme,
                        ),
                        Card(
                          elevation: 1.5,
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.location_city_rounded,
                                  title: 'Địa chỉ',
                                  content: widget.company.address,
                                  themeData: theme,
                                ),
                                Divider(
                                  color: theme.dividerColor.withOpacity(0.3),
                                  height: 1,
                                ),
                                if (widget.company.websiteUrl != null &&
                                    widget.company.websiteUrl!.isNotEmpty)
                                  GestureDetector(
                                    onTap:
                                        () => _launchURL(
                                          widget.company.websiteUrl!,
                                        ),
                                    child: _buildInfoRow(
                                      context: context,
                                      icon: Icons.language_rounded,
                                      title: 'Website',
                                      content: widget.company.websiteUrl,
                                      isLink: true,
                                      themeData: theme,
                                    ),
                                  ),
                                if (widget.company.scale!.isNotEmpty) ...[
                                  Divider(
                                    color: theme.dividerColor.withOpacity(0.3),
                                    height: 1,
                                  ),
                                  _buildInfoRow(
                                    context: context,
                                    icon: Icons.groups_2_outlined,
                                    title: 'Quy mô',
                                    content: widget.company.scale,
                                    themeData: theme,
                                  ),
                                ],
                                // Thêm các thông tin khác như email, SĐT nếu có
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildSectionTitle(
                          context,
                          "Việc Làm Đang Tuyển (${_companyJobsList.length})",
                          Icons.work_history_outlined,
                          theme,
                        ),
                        const SizedBox(height: 12),
                        _isLoadingCompanyJobs
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30.0,
                                ),
                                child: CircularProgressIndicator(
                                  color: theme.primaryColor,
                                ),
                              ),
                            )
                            : _companyJobsList.isEmpty
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _companyJobsError.isNotEmpty
                                      ? _companyJobsError
                                      : 'Hiện chưa có vị trí nào đang tuyển tại công ty này.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                            : Column(
                              // Sử dụng Column thay vì ListView.builder trực tiếp
                              children:
                                  _companyJobsList
                                      .map(
                                        (job) => _buildCompanyJobCard(
                                          context,
                                          job,
                                          theme,
                                        ),
                                      )
                                      .toList(),
                            ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

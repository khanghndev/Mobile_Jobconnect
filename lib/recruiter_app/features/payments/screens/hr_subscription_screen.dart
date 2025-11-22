import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/button_primary_gradient.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/mini_social/widgets/connect/groups_tab_shimmer.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';
import 'hr_payment_screen.dart';

class HrSubscriptionScreen extends StatefulWidget {
  final String recruiterId;
  final String currentPackageId;
  HrSubscriptionScreen({
    super.key,
    required this.recruiterId,
    required this.currentPackageId,
  });

  @override
  _HrSubscriptionScreenState createState() => _HrSubscriptionScreenState();
}

class _HrSubscriptionScreenState extends State<HrSubscriptionScreen> {
  final SubscriptionPackageService _service = SubscriptionPackageService();

  List<SubscriptionPackageModel> _packages = [];
  String _selectedId = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final packages = await _service.fetchSubscriptionPackages();
      if (!mounted) return;
      setState(() {
        _packages = packages;
        _selectedId = ''; // Không chọn trước gói nào
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi lấy gói dịch vụ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  SubscriptionPackageModel get _selectedPackage {
    return _packages.firstWhere(
      (p) => p.idPackage == _selectedId,
      orElse: () => _packages.first,
    );
  }

  void _onSelect(String id) {
    setState(() => _selectedId = id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppbarTitleLarge(title: 'Chọn gói dịch vụ'),
      body: _isLoading
          ? GroupsTabShimmer()
          : _error != null
              ? Center(
                  child: BackgroundErrorState(
                    title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                    onRetry: _fetchPackages,
                  ),
                )
              : _packages.isEmpty
                  ? BackgroundEmptyState(
                      onRefresh: _fetchPackages,
                      title: 'Dịch Vụ',
                      iconData: Icons.dataset,
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _packages.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, i) {
                              final pkg = _packages[i];
                              final sel = pkg.idPackage == _selectedId;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: sel ? Colors.blue : Colors.grey.shade300,
                                    width: sel ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                elevation: 3,
                                child: ExpansionTile(
                                  key: Key(pkg.idPackage),
                                  initiallyExpanded: sel,
                                  onExpansionChanged: (open) {
                                    if (open) _onSelect(pkg.idPackage);
                                  },
                                  leading: Icon(
                                    sel
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: sel ? Colors.blue : Colors.grey,
                                    size: 22.sp,
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Package name
                                      Text(
                                        pkg.packageName,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: sel ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 20.sp,
                                          color: sel ? Colors.blue : Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),

                                      // Price
                                      Row(
                                        children: [
                                          Icon(Icons.monetization_on, size: 22.sp, color: sel ? Colors.blue : Colors.orange),
                                          SizedBox(width: 6.w),
                                          Text(
                                            FormatUtils.formatCurrency(pkg.price),
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.sp,
                                              color: sel ? Colors.blue : Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: sel ? Colors.blue.shade50 : Colors.grey.shade50,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.r),
                                          bottomRight: Radius.circular(10.r),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Description
                                          if (pkg.description != null && pkg.description!.isNotEmpty) ...[
                                            Text(
                                              pkg.description!,
                                              style: textTheme.bodyMedium?.copyWith(
                                                fontSize: 16.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                          ],

                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 20.sp, color: Colors.red.shade600),
                                              SizedBox(width: 6.w),
                                              Text(
                                                '${pkg.durationDays} ngày',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontSize: 16.sp,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          // Job post limit
                                          Row(
                                            children: [
                                              Icon(Icons.post_add, size: 20.sp, color: Colors.orange),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'Giới hạn tin đăng: ${pkg.jobPostLimit}',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontSize: 16.sp,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),

                                          // CV view limit
                                          Row(
                                            children: [
                                              Icon(Icons.remove_red_eye, size: 20.sp, color: Colors.green),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'Giới hạn xem CV: ${pkg.cvViewLimit}',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontSize: 16.sp,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: ButtonPrimaryGradient(
                            text: 'THANH TOÁN', 
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HrPaymentScreen(
                                    package: _selectedPackage,
                                    recruiterId: widget.recruiterId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

 
}

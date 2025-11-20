import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';

class JobDetailScreen extends StatefulWidget {
  final JobPostingModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  CompanyModel? company;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final result = await CompanyService().getCompanyById(id: widget.job.idCompany!);
      setState(() {
        company = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("❌ Lỗi khi load công ty: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const Icon(Icons.business_center,
                          size: 60, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        isLoading
                            ? "Đang tải..."
                            : (company?.companyName ?? "Công ty chưa cập nhật"),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.job.title ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _infoChip(Icons.payments,
                            "${widget.job.salary?.toStringAsFixed(0)} VNĐ"),
                        _infoChip(
                            Icons.calendar_today_outlined,
                            "${widget.job.applicationDeadline?.day}/${widget.job.applicationDeadline?.month}/${widget.job.applicationDeadline?.year}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection("Địa chỉ làm việc", widget.job.location ?? '',
                      Icons.location_on),
                  const SizedBox(height: 24),
                  _buildSection("1. Mô tả công việc",
                      widget.job.description ?? "Không có", Icons.description),
                  _buildSection("2. Yêu cầu",
                      widget.job.requirements ?? "Không có", Icons.rule),
                  _buildSection("3. Quyền lợi",
                      widget.job.benefits ?? "Không có", Icons.card_giftcard),
                  _buildSection("4. Loại hình công việc", widget.job.workType ?? '',
                      Icons.work_outline),
                  _buildSection("5. Kinh nghiệm yêu cầu",
                      widget.job.experienceLevel ?? '', Icons.school),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15.2,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

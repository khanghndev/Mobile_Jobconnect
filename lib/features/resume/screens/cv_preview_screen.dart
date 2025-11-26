import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class CVPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> cvData;
  final String templateId;

  const CVPreviewScreen({
    super.key,
    required this.cvData,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước CV'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCV(context),
            tooltip: 'Chia sẻ CV',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadCV(context),
            tooltip: 'Tải xuống CV',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfo(),
            const SizedBox(height: 24),
            if (cvData['summary'] != null) ...[
              _buildSection('Tóm tắt', cvData['summary']),
              const SizedBox(height: 24),
            ],
            if (cvData['experience'] != null &&
                (cvData['experience'] as List).isNotEmpty) ...[
              _buildSection('Kinh nghiệm', _buildExperienceList()),
              const SizedBox(height: 24),
            ],
            if (cvData['education'] != null &&
                (cvData['education'] as List).isNotEmpty) ...[
              _buildSection('Học vấn', _buildEducationList()),
              const SizedBox(height: 24),
            ],
            if (cvData['skills'] != null &&
                (cvData['skills'] as List).isNotEmpty) ...[
              _buildSection('Kỹ năng', _buildSkillsList()),
              const SizedBox(height: 24),
            ],
            if (cvData['projects'] != null &&
                (cvData['projects'] as List).isNotEmpty) ...[
              _buildSection('Dự án', _buildProjectsList()),
              const SizedBox(height: 24),
            ],
            if (cvData['certificates'] != null &&
                (cvData['certificates'] as List).isNotEmpty) ...[
              _buildSection('Chứng chỉ', _buildCertificatesList()),
              const SizedBox(height: 24),
            ],
            if (cvData['languages'] != null &&
                (cvData['languages'] as List).isNotEmpty) ...[
              _buildSection('Ngôn ngữ', _buildLanguagesList()),
              const SizedBox(height: 24),
            ],
            if (cvData['portfolio'] != null &&
                (cvData['portfolio'] as List).isNotEmpty) ...[
              _buildSection('Portfolio', _buildPortfolioList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final personalInfo = cvData['personal_info'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          personalInfo['name'] ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (personalInfo['email'] != null)
          Text(personalInfo['email'], style: const TextStyle(fontSize: 16)),
        if (personalInfo['phone'] != null)
          Text(personalInfo['phone'], style: const TextStyle(fontSize: 16)),
        if (personalInfo['address'] != null)
          Text(personalInfo['address'], style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildExperienceList() {
    final experiences = cvData['experience'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          experiences.map((exp) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp['position'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${exp['company'] ?? ''} • ${exp['from'] ?? ''} - ${exp['to'] ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (exp['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      exp['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEducationList() {
    final educations = cvData['education'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          educations.map((edu) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu['school'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${edu['major'] ?? ''} • ${edu['from'] ?? ''} - ${edu['to'] ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSkillsList() {
    final skills = cvData['skills'] as List;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          skills.map((skill) {
            return Chip(label: Text(skill), backgroundColor: Colors.blue[100]);
          }).toList(),
    );
  }

  Widget _buildProjectsList() {
    final projects = cvData['projects'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          projects.map((project) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (project['role'] != null)
                    Text(
                      project['role'],
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (project['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      project['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCertificatesList() {
    final certificates = cvData['certificates'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          certificates.map((cert) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${cert['issuer'] ?? ''} • ${cert['date'] ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLanguagesList() {
    final languages = cvData['languages'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          languages.map((lang) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    lang['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getLanguageLevel(lang['level']),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  String _getLanguageLevel(String? level) {
    switch (level) {
      case 'native':
        return '(Bản ngữ)';
      case 'fluent':
        return '(Thành thạo)';
      case 'advanced':
        return '(Nâng cao)';
      case 'intermediate':
        return '(Trung cấp)';
      case 'basic':
        return '(Cơ bản)';
      default:
        return '';
    }
  }

  Widget _buildPortfolioList() {
    final portfolio = cvData['portfolio'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          portfolio.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item['url'] != null)
                    Text(
                      item['url'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  if (item['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  Future<void> _shareCV(BuildContext context) async {
    try {
      final pdf = await _generatePDF();
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/cv.pdf');
      await file.writeAsBytes(pdf);
      await Share.shareXFiles([XFile(file.path)], text: 'CV của tôi');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chia sẻ CV: $e')));
    }
  }

  Future<void> _downloadCV(BuildContext context) async {
    try {
      final pdf = await _generatePDF();
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/cv.pdf');
      await file.writeAsBytes(pdf);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CV đã được tải xuống tại: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải xuống CV: $e')));
    }
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    //   Implement PDF generation based on template
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Add PDF content here
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

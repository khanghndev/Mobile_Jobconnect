import 'package:flutter/material.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'cv_templates_screen.dart';

class CreateCVScreen extends StatefulWidget {
  final CVTemplate template;

  const CreateCVScreen({super.key, required this.template});

  @override
  State<CreateCVScreen> createState() => _CreateCVScreenState();
}

class _CreateCVScreenState extends State<CreateCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _cvData = {};
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initializeCVData();
  }


  void _initializeCVData() {
    widget.template.sections.forEach((key, value) {
      if (value == true) {
        // Các section dạng danh sách
        if ([
          'experience',
          'education',
          'projects',
          'certificates',
          'languages',
          'portfolio',
        ].contains(key)) {
          _cvData[key] = []; // danh sách
        } else {
          _cvData[key] = {}; // map đơn
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarTitleLarge(
        title: "Tạo CV",
        actions: [
          IconButton(
            icon: Icon(Icons.preview),
            onPressed: _previewCV,
            tooltip: 'Xem trước',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveCV,
            tooltip: 'Lưu CV',
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < widget.template.sections.length - 1) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep < widget.template.sections.length - 1
                        ? 'Tiếp tục'
                        : 'Hoàn thành',
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Quay lại'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: _buildSteps(),
      ),
    );
  }

  List<Step> _buildSteps() {
    final steps = <Step>[];
    int index = 0;

    widget.template.sections.forEach((section, enabled) {
      if (enabled == true) {
        steps.add(
          Step(
            title: Text(_getSectionTitle(section)),
            content: _buildSectionContent(section),
            isActive: _currentStep >= index,
            state:
                _currentStep > index ? StepState.complete : StepState.indexed,
          ),
        );
        index++;
      }
    });

    return steps;
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'personal_info':
        return 'Thông tin cá nhân';
      case 'summary':
        return 'Tóm tắt';
      case 'experience':
        return 'Kinh nghiệm';
      case 'education':
        return 'Học vấn';
      case 'skills':
        return 'Kỹ năng';
      case 'projects':
        return 'Dự án';
      case 'certificates':
        return 'Chứng chỉ';
      case 'languages':
        return 'Ngôn ngữ';
      case 'portfolio':
        return 'Portfolio';
      default:
        return section;
    }
  }

  Widget _buildSectionContent(String section) {
    switch (section) {
      case 'personal_info':
        return _buildPersonalInfoSection();
      case 'summary':
        return _buildSummarySection();
      case 'experience':
        return _buildExperienceSection();
      case 'education':
        return _buildEducationSection();
      case 'skills':
        return _buildSkillsSection();
      case 'projects':
        return _buildProjectsSection();
      case 'certificates':
        return _buildCertificatesSection();
      case 'languages':
        return _buildLanguagesSection();
      case 'portfolio':
        return _buildPortfolioSection();
      default:
        return const Text('Section not implemented');
    }
  }

  Widget _buildPersonalInfoSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              hintText: 'Nhập họ và tên của bạn',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
            onSaved: (value) {
              _cvData['personal_info'] = {
                ..._cvData['personal_info'],
                'name': value,
              };
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Nhập email của bạn',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!value.contains('@')) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onSaved: (value) {
              _cvData['personal_info'] = {
                ..._cvData['personal_info'],
                'email': value,
              };
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              hintText: 'Nhập số điện thoại của bạn',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              return null;
            },
            onSaved: (value) {
              _cvData['personal_info'] = {
                ..._cvData['personal_info'],
                'phone': value,
              };
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Địa chỉ',
              hintText: 'Nhập địa chỉ của bạn',
            ),
            onSaved: (value) {
              _cvData['personal_info'] = {
                ..._cvData['personal_info'],
                'address': value,
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return TextFormField(
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Tóm tắt',
        hintText:
            'Viết một đoạn tóm tắt ngắn gọn về bản thân và mục tiêu nghề nghiệp',
        alignLabelWithHint: true,
      ),
      onSaved: (value) {
        _cvData['summary'] = value;
      },
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['experience'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildExperienceItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addExperience,
          icon: const Icon(Icons.add),
          label: const Text('Thêm kinh nghiệm'),
        ),
      ],
    );
  }

  Widget _buildExperienceItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Vị trí',
                hintText: 'Nhập vị trí công việc',
              ),
              onSaved: (value) {
                _cvData['experience'][index]['position'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Công ty',
                hintText: 'Nhập tên công ty',
              ),
              onSaved: (value) {
                _cvData['experience'][index]['company'] = value;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Từ',
                      hintText: 'MM/YYYY',
                    ),
                    onSaved: (value) {
                      _cvData['experience'][index]['from'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Đến',
                      hintText: 'MM/YYYY',
                    ),
                    onSaved: (value) {
                      _cvData['experience'][index]['to'] = value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả công việc và thành tích của bạn',
                alignLabelWithHint: true,
              ),
              onSaved: (value) {
                _cvData['experience'][index]['description'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addExperience() {
    setState(() {
      if (_cvData['experience'] == null) {
        _cvData['experience'] = [];
      }
      (_cvData['experience'] as List).add({});
    });
  }

  Widget _buildEducationSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['education'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildEducationItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addEducation,
          icon: const Icon(Icons.add),
          label: const Text('Thêm học vấn'),
        ),
      ],
    );
  }

  Widget _buildEducationItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Trường học',
                hintText: 'Nhập tên trường',
              ),
              onSaved: (value) {
                _cvData['education'][index]['school'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Chuyên ngành',
                hintText: 'Nhập chuyên ngành',
              ),
              onSaved: (value) {
                _cvData['education'][index]['major'] = value;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Từ',
                      hintText: 'MM/YYYY',
                    ),
                    onSaved: (value) {
                      _cvData['education'][index]['from'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Đến',
                      hintText: 'MM/YYYY',
                    ),
                    onSaved: (value) {
                      _cvData['education'][index]['to'] = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addEducation() {
    setState(() {
      if (_cvData['education'] == null) {
        _cvData['education'] = [];
      }
      (_cvData['education'] as List).add({});
    });
  }

  Widget _buildSkillsSection() {
    return Column(
      children: [
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Kỹ năng',
            hintText: 'Nhập các kỹ năng của bạn, phân cách bằng dấu phẩy',
            alignLabelWithHint: true,
          ),
          onSaved: (value) {
            _cvData['skills'] =
                value?.split(',').map((e) => e.trim()).toList() ?? [];
          },
        ),
      ],
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['projects'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildProjectItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addProject,
          icon: const Icon(Icons.add),
          label: const Text('Thêm dự án'),
        ),
      ],
    );
  }

  Widget _buildProjectItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tên dự án',
                hintText: 'Nhập tên dự án',
              ),
              onSaved: (value) {
                _cvData['projects'][index]['name'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                hintText: 'Nhập vai trò của bạn trong dự án',
              ),
              onSaved: (value) {
                _cvData['projects'][index]['role'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả dự án và đóng góp của bạn',
                alignLabelWithHint: true,
              ),
              onSaved: (value) {
                _cvData['projects'][index]['description'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addProject() {
    setState(() {
      if (_cvData['projects'] == null) {
        _cvData['projects'] = [];
      }
      (_cvData['projects'] as List).add({});
    });
  }

  Widget _buildCertificatesSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['certificates'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildCertificateItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addCertificate,
          icon: const Icon(Icons.add),
          label: const Text('Thêm chứng chỉ'),
        ),
      ],
    );
  }

  Widget _buildCertificateItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tên chứng chỉ',
                hintText: 'Nhập tên chứng chỉ',
              ),
              onSaved: (value) {
                _cvData['certificates'][index]['name'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tổ chức cấp',
                hintText: 'Nhập tên tổ chức cấp chứng chỉ',
              ),
              onSaved: (value) {
                _cvData['certificates'][index]['issuer'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ngày cấp',
                hintText: 'MM/YYYY',
              ),
              onSaved: (value) {
                _cvData['certificates'][index]['date'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addCertificate() {
    setState(() {
      if (_cvData['certificates'] == null) {
        _cvData['certificates'] = [];
      }
      (_cvData['certificates'] as List).add({});
    });
  }

  Widget _buildLanguagesSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['languages'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildLanguageItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addLanguage,
          icon: const Icon(Icons.add),
          label: const Text('Thêm ngôn ngữ'),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ngôn ngữ',
                hintText: 'Nhập tên ngôn ngữ',
              ),
              onSaved: (value) {
                _cvData['languages'][index]['name'] = value;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Trình độ'),
              items: const [
                DropdownMenuItem(value: 'native', child: Text('Bản ngữ')),
                DropdownMenuItem(value: 'fluent', child: Text('Thành thạo')),
                DropdownMenuItem(value: 'advanced', child: Text('Nâng cao')),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('Trung cấp'),
                ),
                DropdownMenuItem(value: 'basic', child: Text('Cơ bản')),
              ],
              onChanged: (value) {
                setState(() {
                  _cvData['languages'][index]['level'] = value;
                });
              },
              onSaved: (value) {
                _cvData['languages'][index]['level'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addLanguage() {
    setState(() {
      if (_cvData['languages'] == null) {
        _cvData['languages'] = [];
      }
      (_cvData['languages'] as List).add({});
    });
  }

  Widget _buildPortfolioSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_cvData['portfolio'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            return _buildPortfolioItem(index);
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addPortfolioItem,
          icon: const Icon(Icons.add),
          label: const Text('Thêm portfolio'),
        ),
      ],
    );
  }

  Widget _buildPortfolioItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                hintText: 'Nhập tiêu đề portfolio',
              ),
              onSaved: (value) {
                _cvData['portfolio'][index]['title'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'Nhập URL portfolio',
              ),
              onSaved: (value) {
                _cvData['portfolio'][index]['url'] = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả ngắn gọn về portfolio',
                alignLabelWithHint: true,
              ),
              onSaved: (value) {
                _cvData['portfolio'][index]['description'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPortfolioItem() {
    setState(() {
      if (_cvData['portfolio'] == null) {
        _cvData['portfolio'] = [];
      }
      (_cvData['portfolio'] as List).add({});
    });
  }

  void _previewCV() {
    // TODO: Implement CV preview
  }

  void _saveCV() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: Save CV data to database or local storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV đã được lưu thành công')),
      );
    }
  }
}

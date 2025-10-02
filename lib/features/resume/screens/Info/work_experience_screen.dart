import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

// Model cho kinh nghiệm làm việc
class WorkExperience {
  String companyName;
  String position;
  String startDate; // "MM/YYYY"
  String endDate; // "MM/YYYY" hoặc "Hiện tại"
  String description;
  bool isAIGenerated;

  WorkExperience({
    required this.companyName,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.isAIGenerated = false,
  });
}

class WorkExperienceScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo; // Nhận dữ liệu từ màn hình trước
  final bool isAIGenerated;

  const WorkExperienceScreen({
    Key? key,
    required this.personalInfo,
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _WorkExperienceScreenState createState() => _WorkExperienceScreenState();
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  List<WorkExperience> _experiences = [];
  bool _isGenerating = false;

  void _addOrEditExperience({WorkExperience? experience, int? index}) {
    // Sử dụng TextEditingController để quản lý trạng thái của form trong dialog
    final _companyController = TextEditingController(
      text: experience?.companyName ?? '',
    );
    final _positionController = TextEditingController(
      text: experience?.position ?? '',
    );
    final _startDateController = TextEditingController(
      text: experience?.startDate ?? '',
    );
    final _endDateController = TextEditingController(
      text: experience?.endDate ?? '',
    );
    final _descriptionController = TextEditingController(
      text: experience?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                experience == null ? "Thêm kinh nghiệm" : "Sửa kinh nghiệm",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.isAIGenerated)
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI có thể giúp bạn tạo mô tả công việc',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: "Tên công ty *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        labelText: "Vị trí *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              labelText: "Từ tháng/năm *",
                              border: OutlineInputBorder(),
                              hintText: "MM/YYYY",
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endDateController,
                            decoration: InputDecoration(
                              labelText: "Đến tháng/năm *",
                              border: OutlineInputBorder(),
                              hintText: "MM/YYYY hoặc Hiện tại",
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Mô tả công việc/Thành tựu *",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                    ),
                    if (widget.isAIGenerated) ...[
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.auto_awesome),
                        label: Text(
                          _isGenerating ? "Đang tạo..." : "Tạo mô tả bằng AI",
                        ),
                        onPressed:
                            _isGenerating
                                ? null
                                : () async {
                                  setState(() => _isGenerating = true);
                                  try {
                                    // TODO: Implement AI API call
                                    await Future.delayed(
                                      Duration(seconds: 2),
                                    ); // Simulate API call
                                    _descriptionController.text =
                                        "AI suggested description for ${_positionController.text} at ${_companyController.text}";
                                  } finally {
                                    setState(() => _isGenerating = false);
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Hủy"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text(experience == null ? "Thêm" : "Lưu"),
                  onPressed: () {
                    if (_companyController.text.isEmpty ||
                        _positionController.text.isEmpty ||
                        _startDateController.text.isEmpty ||
                        _endDateController.text.isEmpty ||
                        _descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    final newExperience = WorkExperience(
                      companyName: _companyController.text,
                      position: _positionController.text,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      description: _descriptionController.text,
                      isAIGenerated: widget.isAIGenerated,
                    );

                    setState(() {
                      if (index != null) {
                        _experiences[index] = newExperience;
                      } else {
                        _experiences.add(newExperience);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _nextStep() {
    // Thu thập _experiences
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EducationScreen(
              personalInfo: widget.personalInfo,
              workExperiences: _experiences,
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Kinh nghiệm đã lưu')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bước 2/6: Kinh nghiệm làm việc"),
        actions: [
          if (widget.isAIGenerated)
            IconButton(
              icon: Icon(Icons.auto_awesome),
              onPressed: () {
                // TODO: Implement AI suggestions for work experience
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang tạo gợi ý từ AI...')),
                );
              },
              tooltip: 'Gợi ý từ AI',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (widget.isAIGenerated)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn đang tạo CV với sự hỗ trợ của AI',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child:
                  _experiences.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Chưa có kinh nghiệm nào",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Hãy thêm kinh nghiệm làm việc của bạn",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _experiences.length,
                        itemBuilder: (context, index) {
                          final exp = _experiences[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                "${exp.position} tại ${exp.companyName}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${exp.startDate} - ${exp.endDate}",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    exp.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (exp.isAIGenerated)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Được tạo bởi AI",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed:
                                        () => _addOrEditExperience(
                                          experience: exp,
                                          index: index,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _experiences.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onTap:
                                  () => _addOrEditExperience(
                                    experience: exp,
                                    index: index,
                                  ),
                            ),
                          );
                        },
                      ),
            ),
            SizedBox(height: 20),
            OutlinedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Thêm kinh nghiệm"),
              onPressed: () => _addOrEditExperience(),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Quay lại"),
                ),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text("Tiếp tục"),
                  style: ElevatedButton.styleFrom(minimumSize: Size(120, 40)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

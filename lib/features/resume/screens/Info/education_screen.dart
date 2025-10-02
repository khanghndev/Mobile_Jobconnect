import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/skills_screen.dart';
import 'work_experience_screen.dart';

// Model cho học vấn
class Education {
  String institutionName;
  String degree; // Chuyên ngành/Bằng cấp
  String studyTime; // Từ tháng/năm - Đến tháng/năm hoặc Năm tốt nghiệp
  String gpaAchievements; // Tùy chọn
  bool isAIGenerated;

  Education({
    required this.institutionName,
    required this.degree,
    required this.studyTime,
    this.gpaAchievements = '',
    this.isAIGenerated = false,
  });
}

class EducationScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<WorkExperience> workExperiences;
  final bool isAIGenerated;

  const EducationScreen({
    Key? key,
    required this.personalInfo,
    required this.workExperiences,
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  List<Education> _educations = [];
  bool _isGenerating = false;

  void _addOrEditEducation({Education? education, int? index}) {
    final _institutionController = TextEditingController(
      text: education?.institutionName ?? '',
    );
    final _degreeController = TextEditingController(
      text: education?.degree ?? '',
    );
    final _studyTimeController = TextEditingController(
      text: education?.studyTime ?? '',
    );
    final _gpaController = TextEditingController(
      text: education?.gpaAchievements ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(education == null ? "Thêm học vấn" : "Sửa học vấn"),
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
                                'AI có thể giúp bạn tạo mô tả học vấn',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: _institutionController,
                      decoration: InputDecoration(
                        labelText: "Tên trường/tổ chức *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _degreeController,
                      decoration: InputDecoration(
                        labelText: "Chuyên ngành/Bằng cấp *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _studyTimeController,
                      decoration: InputDecoration(
                        labelText: "Thời gian học *",
                        border: OutlineInputBorder(),
                        hintText: "VD: 08/2018 - 06/2022",
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _gpaController,
                      decoration: InputDecoration(
                        labelText: "GPA/Thành tích (tùy chọn)",
                        border: OutlineInputBorder(),
                      ),
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
                                    _gpaController.text =
                                        "AI suggested achievements for ${_degreeController.text} at ${_institutionController.text}";
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
                  child: Text(education == null ? "Thêm" : "Lưu"),
                  onPressed: () {
                    if (_institutionController.text.isEmpty ||
                        _degreeController.text.isEmpty ||
                        _studyTimeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    final newEducation = Education(
                      institutionName: _institutionController.text,
                      degree: _degreeController.text,
                      studyTime: _studyTimeController.text,
                      gpaAchievements: _gpaController.text,
                      isAIGenerated: widget.isAIGenerated,
                    );

                    setState(() {
                      if (index != null) {
                        _educations[index] = newEducation;
                      } else {
                        _educations.add(newEducation);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SkillsScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences,
              educations: _educations,
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bước 3/6: Học vấn"),
        actions: [
          if (widget.isAIGenerated)
            IconButton(
              icon: Icon(Icons.auto_awesome),
              onPressed: () {
                // TODO: Implement AI suggestions for education
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
                  _educations.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Chưa có thông tin học vấn",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Hãy thêm thông tin học vấn của bạn",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _educations.length,
                        itemBuilder: (context, index) {
                          final edu = _educations[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                "${edu.degree} tại ${edu.institutionName}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    edu.studyTime,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (edu.gpaAchievements.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      "GPA/Thành tích: ${edu.gpaAchievements}",
                                    ),
                                  ],
                                  if (edu.isAIGenerated)
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
                                        () => _addOrEditEducation(
                                          education: edu,
                                          index: index,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _educations.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onTap:
                                  () => _addOrEditEducation(
                                    education: edu,
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
              label: Text("Thêm học vấn"),
              onPressed: () => _addOrEditEducation(),
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

import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/career_objective_screen.dart';
import 'package:job_connect/features/resume/screens/Info/education_screen.dart';

class SkillsScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final List<dynamic> workExperiences;
  final List<Education> educations;
  final bool isAIGenerated;

  const SkillsScreen({
    Key? key,
    required this.personalInfo,
    required this.workExperiences,
    required this.educations,
    this.isAIGenerated = false,
  }) : super(key: key);

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _skillsController = TextEditingController();
  List<String> _skills = []; // Hoặc dùng Set<String> để tránh trùng lặp
  // Hoặc nếu dùng flutter_chips_input:
  // final _chipKey = GlobalKey<ChipsInputState>();

  void _suggestSkillsByAI() {
    // Gọi API AI dựa trên vị trí ứng tuyển (widget.appliedPosition)
    // Giả sử AI trả về một danh sách các kỹ năng
    List<String> suggestedSkills = [
      "Flutter",
      "Dart",
      "Firebase",
      "Problem Solving (AI Demo)",
    ];
    setState(() {
      // Thêm các kỹ năng gợi ý vào danh sách, tránh trùng lặp
      for (var skill in suggestedSkills) {
        if (!_skills.contains(skill) &&
            !_skillsController.text
                .split(',')
                .map((s) => s.trim())
                .contains(skill)) {
          _skills.add(skill); // Nếu dùng list of chips
        }
      }
      // Hoặc cập nhật vào TextField
      _skillsController.text =
          (_skillsController.text.isEmpty
              ? ""
              : _skillsController.text + ", ") +
          suggestedSkills.join(", ");
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('AI đã gợi ý kỹ năng!')));
  }

  void _addSkillFromTextField() {
    final skillsFromText =
        _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
    setState(() {
      for (var skill in skillsFromText) {
        if (!_skills.contains(skill)) {
          _skills.add(skill);
        }
      }
      _skillsController.clear(); // Xóa text field sau khi thêm
    });
  }

  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CareerObjectiveScreen(
              personalInfo: widget.personalInfo,
              workExperiences: widget.workExperiences, // Pass directly
              educations: widget.educations,
              skills: _skills,
              isAIGenerated: widget.isAIGenerated,
            ),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Kỹ năng đã lưu (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bước 4/6: Kỹ năng")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Nhập các kỹ năng của bạn, cách nhau bằng dấu phẩy (,) hoặc thêm từng kỹ năng một.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillsController,
                    decoration: InputDecoration(
                      labelText: "VD: Java, Python, Giao tiếp",
                      hintText: "Nhập kỹ năng rồi nhấn Thêm hoặc dấu phẩy",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: _addSkillFromTextField,
                  tooltip: "Thêm kỹ năng từ ô nhập liệu",
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  _skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          onDeleted: () {
                            setState(() {
                              _skills.remove(skill);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),
            TextButton.icon(
              icon: Icon(Icons.lightbulb_outline),
              label: Text("Gợi ý kỹ năng bằng AI"),
              onPressed: _suggestSkillsByAI,
            ),
            // Nếu dùng flutter_chips_input
            // ChipsInput(
            //   key: _chipKey,
            //   initialValue: [],
            //   decoration: InputDecoration(labelText: "Nhập kỹ năng"),
            //   findSuggestions: (String query) {
            //     // Có thể dùng cho autocomplete nếu có danh sách kỹ năng sẵn
            //     return <String>[];
            //   },
            //   onChanged: (data) {
            //     // data là List<String> các skills
            //   },
            //   chipBuilder: (context, state, skill) {
            //     return InputChip(
            //       key: ObjectKey(skill),
            //       label: Text(skill),
            //       onDeleted: () => state.deleteChip(skill),
            //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //     );
            //   },
            //   suggestionBuilder: (context, state, skill) { /* ... */ },
            // ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Quay lại"),
                ),
                ElevatedButton(onPressed: _nextStep, child: Text("Tiếp tục")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

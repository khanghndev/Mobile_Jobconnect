import 'package:flutter/material.dart';
import 'package:job_connect/features/resume/screens/Info/work_experience_screen.dart';
import 'work_experience_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final bool isAIGenerated;
  final Map<String, dynamic>? initialData;

  const PersonalInfoScreen({
    Key? key,
    this.isAIGenerated = false,
    this.initialData,
  }) : super(key: key);

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // Tùy chọn
  final _linkedinController = TextEditingController(); // Tùy chọn
  final _portfolioController = TextEditingController(); // Tùy chọn

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _positionController.text = widget.initialData!['position'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _addressController.text = widget.initialData!['address'] ?? '';
      _linkedinController.text = widget.initialData!['linkedin'] ?? '';
      _portfolioController.text = widget.initialData!['portfolio'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> personalInfo = {
        'name': _nameController.text,
        'position': _positionController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'linkedin': _linkedinController.text,
        'portfolio': _portfolioController.text,
        'isAIGenerated': widget.isAIGenerated,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => WorkExperienceScreen(
                personalInfo: personalInfo,
                isAIGenerated: widget.isAIGenerated,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bước 1/6: Thông tin cá nhân"),
        actions: [
          if (widget.isAIGenerated)
            IconButton(
              icon: Icon(Icons.auto_awesome),
              onPressed: () {
                // TODO: Implement AI suggestions for personal info
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang tạo gợi ý từ AI...')),
                );
              },
              tooltip: 'Gợi ý từ AI',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Họ và tên *",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for name
                            },
                          )
                          : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(
                  labelText: "Vị trí ứng tuyển *",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for position
                            },
                          )
                          : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí ứng tuyển';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email *",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for email
                            },
                          )
                          : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại *",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for phone
                            },
                          )
                          : null,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Địa chỉ (tùy chọn)",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for address
                            },
                          )
                          : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _linkedinController,
                decoration: InputDecoration(
                  labelText: "Link LinkedIn (tùy chọn)",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for LinkedIn
                            },
                          )
                          : null,
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _portfolioController,
                decoration: InputDecoration(
                  labelText: "Link Portfolio (tùy chọn)",
                  suffixIcon:
                      widget.isAIGenerated
                          ? IconButton(
                            icon: Icon(Icons.auto_awesome),
                            onPressed: () {
                              // TODO: Implement AI suggestion for portfolio
                            },
                          )
                          : null,
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _nextStep,
                child: Text("Tiếp tục"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

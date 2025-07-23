import 'package:job_connect/core/data/models/account_model.dart';

class Resume {
  final String idResume;
  final String idUser;
  final String fileUrl;
  final String fileName;
  final int fileSizeKB;
  final int isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Account? user;
  final List<String>? resumeSkills;

  Resume({
    required this.idResume,
    required this.idUser,
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeKB,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.resumeSkills,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      idResume: json['idResume'],
      idUser: json['idUser'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSizeKB: json['fileSizeKB'],
      isDefault: json['isDefault'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? Account.fromJson(json['user']) : null,
      resumeSkills:
          (json['resumeSkills'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'idResume': idResume,
    'idUser': idUser,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSizeKB': fileSizeKB,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'user': user?.toJson(),
    'resumeSkills': resumeSkills,
  };

  // Trong class Resume
  Resume copyWith({
    String? idResume,
    String? idUser,
    String? fileUrl,
    String? fileName,
    int? fileSizeKB, // Hoặc tên trường kích thước file của bạn
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isDefault,
  }) {
    return Resume(
      idResume: idResume ?? this.idResume,
      idUser: idUser ?? this.idUser,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeKB: fileSizeKB ?? this.fileSizeKB,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

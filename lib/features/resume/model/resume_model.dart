import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/resume/model/resume_skill_model.dart';

class ResumeModel {
  final String idResume;
  final String idUser;
  final String fileUrl;
  final String fileName;
  final int fileSizeKB;
  final String fileId;
  final int isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final List<ResumeSkillModel>? resumeSkills;

  ResumeModel({
    required this.idResume,
    required this.idUser,
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeKB,
    required this.fileId,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.resumeSkills,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      idResume: json['idResume'],
      idUser: json['idUser'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSizeKB: json['fileSizeKB'],
      fileId: json['fileId'],
      isDefault: json['isDefault'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      resumeSkills: (json['resumeSkills'] as List?)?.map((e) => ResumeSkillModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'idResume': idResume,
    'idUser': idUser,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSizeKB': fileSizeKB,
    'fileId': fileId,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'user': user?.toJson(),
    'resumeSkills': resumeSkills,
  };

  ResumeModel copyWith({
    String? idResume,
    String? idUser,
    String? fileUrl,
    String? fileName,
    int? fileSizeKB,
    String? fileId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isDefault,
    UserModel? user,
    List<ResumeSkillModel>? resumeSkills,
  }) {
    return ResumeModel(
      idResume: idResume ?? this.idResume,
      idUser: idUser ?? this.idUser,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeKB: fileSizeKB ?? this.fileSizeKB,
      fileId: fileId ?? this.fileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      user: user ?? this.user,
      resumeSkills: resumeSkills ?? this.resumeSkills,
    );
  }
}

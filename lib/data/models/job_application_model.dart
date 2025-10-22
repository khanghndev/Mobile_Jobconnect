import 'package:job_connect/data/models/job_posting_model.dart';

class JobApplicationModel {
  final String idJobPost;
  final String idUser;
  final String? cvFileUrl;
  final String? coverLetter;
  final String applicationStatus;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final JobPostingModel jobPosting;

  JobApplicationModel({
    required this.idJobPost,
    required this.idUser,
    this.cvFileUrl,
    this.coverLetter,
    required this.applicationStatus,
    required this.submittedAt,
    required this.updatedAt,
    required this.jobPosting,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) =>
      JobApplicationModel(
        idJobPost: json['idJobPost'],
        idUser: json['idUser'],
        cvFileUrl: json['cvFileUrl'],
        coverLetter: json['coverLetter'],
        applicationStatus: json['applicationStatus'],
        submittedAt: DateTime.parse(json['submittedAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        jobPosting: JobPostingModel.fromJson(
          json['jobPosting'] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        'idJobPost': idJobPost,
        'idUser': idUser,
        'cvFileUrl': cvFileUrl,
        'coverLetter': coverLetter,
        'applicationStatus': applicationStatus,
        'submittedAt': submittedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'jobPosting': jobPosting.toJson(),
      };

  JobApplicationModel copyWith({
    String? idJobPost,
    String? idUser,
    String? cvFileUrl,
    String? coverLetter,
    String? applicationStatus,
    DateTime? submittedAt,
    DateTime? updatedAt,
    JobPostingModel? jobPosting,
  }) {
    return JobApplicationModel(
      idJobPost: idJobPost ?? this.idJobPost,
      idUser: idUser ?? this.idUser,
      cvFileUrl: cvFileUrl ?? this.cvFileUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobPosting: jobPosting ?? this.jobPosting,
    );
  }

  @override
  String toString() => 'JobApplicationModel($idJobPost - $idUser)';
}
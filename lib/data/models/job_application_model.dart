import 'package:job_connect/data/models/job_posting_model.dart';

class JobApplication {
  final String idJobPost;
  final String idUser;
  final String? cvFileUrl;
  final String? coverLetter;
  final String applicationStatus;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final JobPosting jobPosting;

  JobApplication({
    required this.idJobPost,
    required this.idUser,
    this.cvFileUrl,
    this.coverLetter,
    required this.applicationStatus,
    required this.submittedAt,
    required this.updatedAt,
    required this.jobPosting,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      idJobPost: json['idJobPost'],
      idUser: json['idUser'],
      cvFileUrl: json['cvFileUrl'],
      coverLetter: json['coverLetter'],
      applicationStatus: json['applicationStatus'],
      submittedAt: DateTime.parse(json['submittedAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      jobPosting: JobPosting.fromJson(
        json['jobPosting'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idJobPost': idJobPost,
      'idUser': idUser,
      'cvFileUrl': cvFileUrl,
      'coverLetter': coverLetter,
      'applicationStatus': applicationStatus,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'jobPosting': jobPosting.toJson(),
    };
  }
}

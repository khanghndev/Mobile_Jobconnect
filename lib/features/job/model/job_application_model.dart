import 'package:job_connect/features/job/model/job_posting_model.dart';

class JobApplicationModel {
  final String idJobPost;
  final String idUser;
  final String? cvFileUrl;
  final String? coverLetter;
  final String applicationStatus;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final JobPostingModel? jobPosting;
  final double? proposedRate;
  final int? availableHoursPerWeek;
  final String? availableDays;

  JobApplicationModel({
    required this.idJobPost,
    required this.idUser,
    this.cvFileUrl,
    this.coverLetter,
    required this.applicationStatus,
    required this.submittedAt,
    required this.updatedAt,
    this.jobPosting,
    this.proposedRate,
    this.availableHoursPerWeek,
    this.availableDays,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) =>
      JobApplicationModel(
        idJobPost: json['idJobPost']?.toString() ?? '',
        idUser: json['idUser']?.toString() ?? '',
        cvFileUrl: json['cvFileUrl']?.toString(),
        coverLetter: json['coverLetter']?.toString(),
        applicationStatus: json['applicationStatus']?.toString() ?? '',
        submittedAt: DateTime.parse(json['submittedAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        jobPosting: json['jobPosting'] != null
            ? JobPostingModel.fromJson(
                json['jobPosting'] as Map<String, dynamic>)
            : null,
        proposedRate: json['proposedRate'] != null
            ? (json['proposedRate'] as num).toDouble()
            : null,
        availableHoursPerWeek: json['availableHoursPerWeek'] != null
            ? (json['availableHoursPerWeek'] as int)
            : null,
        availableDays: json['availableDays']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'idJobPost': idJobPost,
        'idUser': idUser,
        'cvFileUrl': cvFileUrl,
        'coverLetter': coverLetter,
        'applicationStatus': applicationStatus,
        'submittedAt': submittedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'jobPosting': jobPosting?.toJson(),
        'proposedRate': proposedRate,
        'availableHoursPerWeek': availableHoursPerWeek,
        'availableDays': availableDays,
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
    double? proposedRate,
    int? availableHoursPerWeek,
    String? availableDays,
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
      proposedRate: proposedRate ?? this.proposedRate,
      availableHoursPerWeek: availableHoursPerWeek ?? this.availableHoursPerWeek,
      availableDays: availableDays ?? this.availableDays,
    );
  }

  @override
  String toString() =>
      'JobApplicationModel($idJobPost - $idUser, proposedRate: $proposedRate, availableHoursPerWeek: $availableHoursPerWeek, availableDays: $availableDays)';
}

import 'package:job_connect/features/company/model/company_model.dart';

class JobPostingModel {
  final String idJobPost;
  final String title;
  final String description;
  final String requirements;
  final double? salary;
  final String location;
  final double? latitude;
  final double? longitude;
  final String workType;
  final String experienceLevel;
  final String? idCompany;
  final DateTime? applicationDeadline;
  final String? benefits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String postStatus;
  final int isFeatured;
  final CompanyModel? company;
  final String? idCategory;
  final String? jobCategory;
  final String? urgencyLevel;
  final String? workSchedule;
  final int? minHoursPerWeek;
  final int? maxHoursPerWeek;
  final int? workDaysPerWeek;
  final String? projectDuration;
  final DateTime? seasonalStartDate;
  final DateTime? seasonalEndDate;
  final double? hourlyRate;
  final double? dailyRate;
  final double? projectBudget;
  final bool? isSeasonal;
  final bool? isUrgent;
  final List<dynamic> workSchedules;
  final List<dynamic> skills;

  JobPostingModel({
    required this.idJobPost,
    required this.title,
    required this.description,
    required this.requirements,
    this.salary,
    required this.location,
    this.latitude,
    this.longitude,
    required this.workType,
    required this.experienceLevel,
    this.idCompany,
    this.applicationDeadline,
    this.benefits,
    required this.createdAt,
    required this.updatedAt,
    required this.postStatus,
    required this.isFeatured,
    this.company,
    this.idCategory,
    this.jobCategory,
    this.urgencyLevel,
    this.workSchedule,
    this.minHoursPerWeek,
    this.maxHoursPerWeek,
    this.workDaysPerWeek,
    this.projectDuration,
    this.seasonalStartDate,
    this.seasonalEndDate,
    this.hourlyRate,
    this.dailyRate,
    this.projectBudget,
    this.isSeasonal,
    this.isUrgent,
    this.workSchedules = const [],
    this.skills = const [],
  });

  factory JobPostingModel.fromJson(Map<String, dynamic> json) =>
      JobPostingModel(
        idJobPost: json['idJobPost'],
        title: json['title'],
        description: json['description'],
        requirements: json['requirements'],
        salary:
            (json['salary'] != null) ? (json['salary'] as num).toDouble() : null,
        location: json['location'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        workType: json['workType'],
        experienceLevel: json['experienceLevel'],
        idCompany: json['idCompany'],
        applicationDeadline: json['applicationDeadline'] != null
            ? DateTime.parse(json['applicationDeadline'])
            : null,
        benefits: json['benefits'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        postStatus: json['postStatus'],
        isFeatured: json['isFeatured'] ?? 0,
        company: json['company'] != null
            ? CompanyModel.fromJson(json['company'])
            : null,
        idCategory: json['idCategory'],
        jobCategory: json['jobCategory'],
        urgencyLevel: json['urgencyLevel'],
        workSchedule: json['workSchedule'],
        minHoursPerWeek: json['minHoursPerWeek'],
        maxHoursPerWeek: json['maxHoursPerWeek'],
        workDaysPerWeek: json['workDaysPerWeek'],
        projectDuration: json['projectDuration'],
        seasonalStartDate: json['seasonalStartDate'] != null
            ? DateTime.parse(json['seasonalStartDate'])
            : null,
        seasonalEndDate: json['seasonalEndDate'] != null
            ? DateTime.parse(json['seasonalEndDate'])
            : null,
        hourlyRate: (json['hourlyRate'] != null)
            ? (json['hourlyRate'] as num).toDouble()
            : null,
        dailyRate: (json['dailyRate'] != null)
            ? (json['dailyRate'] as num).toDouble()
            : null,
        projectBudget: (json['projectBudget'] != null)
            ? (json['projectBudget'] as num).toDouble()
            : null,
        isSeasonal: json['isSeasonal'] ?? false,
        isUrgent: json['isUrgent'] ?? false,
        workSchedules: json['workSchedules'] ?? [],
        skills: json['skills'] ?? [],
      );

  Map<String, dynamic> toJson() => {
        'idJobPost': idJobPost,
        'title': title,
        'description': description,
        'requirements': requirements,
        'salary': salary,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'workType': workType,
        'experienceLevel': experienceLevel,
        'idCompany': idCompany,
        'applicationDeadline': applicationDeadline?.toIso8601String(),
        'benefits': benefits,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'postStatus': postStatus,
        'isFeatured': isFeatured,
        'company': company?.toJson(),
        'idCategory': idCategory,
        'jobCategory': jobCategory,
        'urgencyLevel': urgencyLevel,
        'workSchedule': workSchedule,
        'minHoursPerWeek': minHoursPerWeek,
        'maxHoursPerWeek': maxHoursPerWeek,
        'workDaysPerWeek': workDaysPerWeek,
        'projectDuration': projectDuration,
        'seasonalStartDate': seasonalStartDate?.toIso8601String(),
        'seasonalEndDate': seasonalEndDate?.toIso8601String(),
        'hourlyRate': hourlyRate,
        'dailyRate': dailyRate,
        'projectBudget': projectBudget,
        'isSeasonal': isSeasonal,
        'isUrgent': isUrgent,
        'workSchedules': workSchedules,
        'skills': skills,
      };

  JobPostingModel copyWith({
    String? idJobPost,
    String? title,
    String? description,
    String? requirements,
    double? salary,
    String? location,
    double? latitude,
    double? longitude,
    String? workType,
    String? experienceLevel,
    String? idCompany,
    DateTime? applicationDeadline,
    String? benefits,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? postStatus,
    int? isFeatured,
    CompanyModel? company,
    String? idCategory,
    String? jobCategory,
    String? urgencyLevel,
    String? workSchedule,
    int? minHoursPerWeek,
    int? maxHoursPerWeek,
    int? workDaysPerWeek,
    String? projectDuration,
    DateTime? seasonalStartDate,
    DateTime? seasonalEndDate,
    double? hourlyRate,
    double? dailyRate,
    double? projectBudget,
    bool? isSeasonal,
    bool? isUrgent,
    List<dynamic>? workSchedules,
    List<dynamic>? skills,
  }) {
    return JobPostingModel(
      idJobPost: idJobPost ?? this.idJobPost,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      salary: salary ?? this.salary,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      workType: workType ?? this.workType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      idCompany: idCompany ?? this.idCompany,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      benefits: benefits ?? this.benefits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postStatus: postStatus ?? this.postStatus,
      isFeatured: isFeatured ?? this.isFeatured,
      company: company ?? this.company,
      idCategory: idCategory ?? this.idCategory,
      jobCategory: jobCategory ?? this.jobCategory,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      workSchedule: workSchedule ?? this.workSchedule,
      minHoursPerWeek: minHoursPerWeek ?? this.minHoursPerWeek,
      maxHoursPerWeek: maxHoursPerWeek ?? this.maxHoursPerWeek,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      projectDuration: projectDuration ?? this.projectDuration,
      seasonalStartDate: seasonalStartDate ?? this.seasonalStartDate,
      seasonalEndDate: seasonalEndDate ?? this.seasonalEndDate,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      projectBudget: projectBudget ?? this.projectBudget,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      isUrgent: isUrgent ?? this.isUrgent,
      workSchedules: workSchedules ?? this.workSchedules,
      skills: skills ?? this.skills,
    );
  }

  @override
  String toString() => 'JobPostingModel($idJobPost - $title)';
}

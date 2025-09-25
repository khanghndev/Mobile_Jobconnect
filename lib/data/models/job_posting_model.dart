import 'company_model.dart';

class JobPosting {
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
  final String idCompany;
  final DateTime? applicationDeadline;
  final String? benefits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String postStatus;
  final int isFeatured;
  final Company company;

  JobPosting({
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
    required this.idCompany,
    this.applicationDeadline,
    this.benefits,
    required this.createdAt,
    required this.updatedAt,
    required this.postStatus,
    required this.isFeatured,
    required this.company,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
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
      applicationDeadline:
          json['applicationDeadline'] != null
              ? DateTime.parse(json['applicationDeadline'])
              : null,
      benefits: json['benefits'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      postStatus: json['postStatus'],
      isFeatured: json['isFeatured'] ?? 0,
      company: Company.fromJson(json['company']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'company': company.toJson(),
    };
  }

  @override
  String toString() {
    return 'JobPosting(idJobPost: $idJobPost, title: $title, description: $description, requirements: $requirements, salary: $salary, location: $location, latitude: $latitude, longitude: $longitude, workType: $workType, experienceLevel: $experienceLevel, ' +
        'idCompany: $idCompany, applicationDeadline: $applicationDeadline, benefits: $benefits, createdAt: $createdAt, updatedAt: $updatedAt, postStatus: $postStatus, isFeatured: $isFeatured, company: $company)';
  }
}

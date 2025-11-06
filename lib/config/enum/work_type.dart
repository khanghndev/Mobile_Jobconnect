enum WorkType {
  fulltime,
  parttime,
  freelancer,
  remote,
  internship,
  fresher,
  senior,
  junior,
  contract,
  hourly,        // Làm theo giờ
  daily,         // Làm theo ngày
  seasonal,      // Thời vụ
  projectBased,  // Theo dự án
  event,         // Sự kiện
  onDemand       // Theo nhu cầu
}

extension WorkTypeExtension on WorkType {
  String get value {
    switch (this) {
      case WorkType.fulltime:
        return 'fulltime';
      case WorkType.parttime:
        return 'parttime';
      case WorkType.freelancer:
        return 'freelancer';
      case WorkType.remote:
        return 'remote';
      case WorkType.internship:
        return 'internship';
      case WorkType.fresher:
        return 'fresher';
      case WorkType.senior:
        return 'senior';
      case WorkType.junior:
        return 'junior';
      case WorkType.contract:
        return 'contract';
      case WorkType.hourly:
        return 'hourly';
      case WorkType.daily:
        return 'daily';
      case WorkType.seasonal:
        return 'seasonal';
      case WorkType.projectBased:
        return 'project_based';
      case WorkType.event:
        return 'event';
      case WorkType.onDemand:
        return 'on_demand';
    }
  }

  static WorkType? fromString(String? str) {
    if (str == null) return null;
    switch (str) {
      case 'fulltime':
        return WorkType.fulltime;
      case 'parttime':
        return WorkType.parttime;
      case 'freelancer':
        return WorkType.freelancer;
      case 'remote':
        return WorkType.remote;
      case 'internship':
        return WorkType.internship;
      case 'fresher':
        return WorkType.fresher;
      case 'senior':
        return WorkType.senior;
      case 'junior':
        return WorkType.junior;
      case 'contract':
        return WorkType.contract;
      case 'hourly':
        return WorkType.hourly;
      case 'daily':
        return WorkType.daily;
      case 'seasonal':
        return WorkType.seasonal;
      case 'project_based':
        return WorkType.projectBased;
      case 'event':
        return WorkType.event;
      case 'on_demand':
        return WorkType.onDemand;
      default:
        return null;
    }
  }
}

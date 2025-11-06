enum EmployerType {
  company,
  individual,
  organization,
}

extension EmployerTypeExtension on EmployerType {
  String get value {
    switch (this) {
      case EmployerType.company:
        return 'company';
      case EmployerType.individual:
        return 'individual';
      case EmployerType.organization:
        return 'organization';
    }
  }

  static EmployerType? fromString(String? str) {
    if (str == null) return null;
    switch (str) {
      case 'company':
        return EmployerType.company;
      case 'individual':
        return EmployerType.individual;
      case 'organization':
        return EmployerType.organization;
      default:
        return null;
    }
  }
}

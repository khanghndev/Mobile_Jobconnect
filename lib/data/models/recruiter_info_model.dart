class RecruiterInfo {
  final String idUser;
  final String title;
  final String? idCompany;
  final String? department;
  final String? description;

  RecruiterInfo({
    required this.idUser,
    required this.title,
    this.idCompany,
    this.department,
    this.description,
  });

  factory RecruiterInfo.fromJson(Map<String, dynamic> json) {
    return RecruiterInfo(
      idUser: json['idUser'],
      title: json['title'],
      idCompany: json['idCompany'],
      department: json['department'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idUser': idUser,
    'title': title,
    'idCompany': idCompany,
    'department': department,
    'description': description,
  };
}

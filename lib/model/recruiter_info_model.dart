class RecruiterInfoModel {
  final String idUser;
  final String title;
  final String? idCompany;
  final String? department;
  final String? description;

  RecruiterInfoModel({
    required this.idUser,
    required this.title,
    this.idCompany,
    this.department,
    this.description,
  });

  factory RecruiterInfoModel.fromJson(Map<String, dynamic> json) => RecruiterInfoModel(
        idUser: json['idUser'],
        title: json['title'],
        idCompany: json['idCompany'],
        department: json['department'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'idUser': idUser,
        'title': title,
        'idCompany': idCompany,
        'department': department,
        'description': description,
      };

  RecruiterInfoModel copyWith({
    String? idUser,
    String? title,
    String? idCompany,
    String? department,
    String? description,
  }) {
    return RecruiterInfoModel(
      idUser: idUser ?? this.idUser,
      title: title ?? this.title,
      idCompany: idCompany ?? this.idCompany,
      department: department ?? this.department,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'RecruiterInfoModel($idUser - $title)';
}

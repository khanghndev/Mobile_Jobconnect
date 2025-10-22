class JobSavedModel {
  final String idJobPost;
  final String idUser;

  JobSavedModel({
    required this.idJobPost,
    required this.idUser,
  });

  factory JobSavedModel.fromJson(Map<String, dynamic> json) => JobSavedModel(
        idJobPost: json['idJobPost'],
        idUser: json['idUser'],
      );

  Map<String, dynamic> toJson() => {
        'idJobPost': idJobPost,
        'idUser': idUser,
      };

  JobSavedModel copyWith({
    String? idJobPost,
    String? idUser,
  }) {
    return JobSavedModel(
      idJobPost: idJobPost ?? this.idJobPost,
      idUser: idUser ?? this.idUser,
    );
  }

  @override
  String toString() => 'JobSavedModel($idJobPost - $idUser)';
}
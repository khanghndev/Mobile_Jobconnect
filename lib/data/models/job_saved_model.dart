class JobSaved {
  final String idJobPost;
  final String idUser;

  JobSaved({required this.idJobPost, required this.idUser});

  factory JobSaved.fromJson(Map<String, dynamic> json) {
    return JobSaved(
      idJobPost: json['idJobPost'] as String,
      idUser: json['idUser'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'idJobPost': idJobPost, 'idUser': idUser};
}

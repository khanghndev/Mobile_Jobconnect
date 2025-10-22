class SocialLikeModel {
  final String idPost;
  final String idUser;
  final DateTime createdAt;

  SocialLikeModel({
    required this.idPost,
    required this.idUser,
    required this.createdAt,
  });

  factory SocialLikeModel.fromJson(Map<String, dynamic> json) => SocialLikeModel(
        idPost: json['idPost'],
        idUser: json['idUser'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idUser': idUser,
        'createdAt': createdAt.toIso8601String(),
      };

  SocialLikeModel copyWith({
    String? idPost,
    String? idUser,
    DateTime? createdAt,
  }) {
    return SocialLikeModel(
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SocialLikeModel(idPost: $idPost, idUser: $idUser)';
}

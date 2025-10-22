class SocialPostTagModel {
  final String idPost;
  final String idTag;

  SocialPostTagModel({
    required this.idPost,
    required this.idTag,
  });

  factory SocialPostTagModel.fromJson(Map<String, dynamic> json) =>
      SocialPostTagModel(
        idPost: json['idPost'],
        idTag: json['idTag'],
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idTag': idTag,
      };

  SocialPostTagModel copyWith({
    String? idPost,
    String? idTag,
  }) {
    return SocialPostTagModel(
      idPost: idPost ?? this.idPost,
      idTag: idTag ?? this.idTag,
    );
  }

  @override
  String toString() => 'SocialPostTagModel($idPost, $idTag)';
}

class GroupPostTagModel {
  final String idPost;
  final String idTag;

  GroupPostTagModel({
    required this.idPost,
    required this.idTag,
  });

  factory GroupPostTagModel.fromJson(Map<String, dynamic> json) => GroupPostTagModel(
        idPost: json['idPost'],
        idTag: json['idTag'],
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idTag': idTag,
      };

  GroupPostTagModel copyWith({
    String? idPost,
    String? idTag,
  }) {
    return GroupPostTagModel(
      idPost: idPost ?? this.idPost,
      idTag: idTag ?? this.idTag,
    );
  }

  @override
  String toString() => 'GroupPostTagModel($idPost, $idTag)';
}

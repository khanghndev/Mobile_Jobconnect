class GroupCommentModel {
  final String idComment;
  final String idPost;
  final String idUser;
  final String content;
  final DateTime createdAt;

  GroupCommentModel({
    required this.idComment,
    required this.idPost,
    required this.idUser,
    required this.content,
    required this.createdAt,
  });

  factory GroupCommentModel.fromJson(Map<String, dynamic> json) => GroupCommentModel(
        idComment: json['idComment'],
        idPost: json['idPost'],
        idUser: json['idUser'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idComment': idComment,
        'idPost': idPost,
        'idUser': idUser,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  GroupCommentModel copyWith({
    String? idComment,
    String? idPost,
    String? idUser,
    String? content,
    DateTime? createdAt,
  }) {
    return GroupCommentModel(
      idComment: idComment ?? this.idComment,
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'GroupCommentModel($idComment on $idPost)';
}

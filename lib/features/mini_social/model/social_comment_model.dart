class SocialCommentModel {
  final String idComment;
  final String idPost;
  final String idUser;
  final String? parentComment;
  final String content;
  final DateTime createdAt;

  SocialCommentModel({
    required this.idComment,
    required this.idPost,
    required this.idUser,
    this.parentComment,
    required this.content,
    required this.createdAt,
  });

  factory SocialCommentModel.fromJson(Map<String, dynamic> json) =>
      SocialCommentModel(
        idComment: json['idComment'],
        idPost: json['idPost'],
        idUser: json['idUser'],
        parentComment: json['parentComment'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idComment': idComment,
        'idPost': idPost,
        'idUser': idUser,
        'parentComment': parentComment,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  SocialCommentModel copyWith({
    String? idComment,
    String? idPost,
    String? idUser,
    String? parentComment,
    String? content,
    DateTime? createdAt,
  }) {
    return SocialCommentModel(
      idComment: idComment ?? this.idComment,
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      parentComment: parentComment ?? this.parentComment,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'SocialCommentModel(idComment: $idComment, idPost: $idPost, idUser: $idUser)';
}

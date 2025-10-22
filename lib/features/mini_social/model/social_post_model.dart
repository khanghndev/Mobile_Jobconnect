class SocialPostModel {
  final String idPost;
  final String idUser;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialPostModel({
    required this.idPost,
    required this.idUser,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.visibility = 'public',
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) => SocialPostModel(
        idPost: json['idPost'],
        idUser: json['idUser'],
        content: json['content'],
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        visibility: json['visibility'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idUser': idUser,
        'content': content,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'visibility': visibility,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  SocialPostModel copyWith({
    String? idPost,
    String? idUser,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPostModel(
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'SocialPostModel(idPost: $idPost, idUser: $idUser, content: $content)';
}

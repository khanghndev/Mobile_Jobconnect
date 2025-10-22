class GroupPostModel {
  final String idPost;
  final String idGroup;
  final String idUser;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final bool isApproved;
  final DateTime createdAt;

  GroupPostModel({
    required this.idPost,
    required this.idGroup,
    required this.idUser,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.isApproved = true,
    required this.createdAt,
  });

  factory GroupPostModel.fromJson(Map<String, dynamic> json) => GroupPostModel(
        idPost: json['idPost'],
        idGroup: json['idGroup'],
        idUser: json['idUser'],
        content: json['content'],
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        isApproved: json['isApproved'] == 1 || json['isApproved'] == true,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idGroup': idGroup,
        'idUser': idUser,
        'content': content,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'isApproved': isApproved ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };

  GroupPostModel copyWith({
    String? idPost,
    String? idGroup,
    String? idUser,
    String? content,
    String? imageUrl,
    String? videoUrl,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return GroupPostModel(
      idPost: idPost ?? this.idPost,
      idGroup: idGroup ?? this.idGroup,
      idUser: idUser ?? this.idUser,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'GroupPostModel($idPost in $idGroup)';
}

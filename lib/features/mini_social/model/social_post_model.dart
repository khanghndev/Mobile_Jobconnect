class SocialPostModel {
  final String idPost;
  final String idUser;
  final String? userName;
  final String? avatarUrl;
  final String? idGroup;
  final String? groupName;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final String visibility;
  final String? postType;
  final List<String>? hashtags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isSaved;
  final Map<String, int>? reactionsSummary;
  final String? currentUserReaction;

  SocialPostModel({
    required this.idPost,
    required this.idUser,
    this.userName,
    this.avatarUrl,
    this.idGroup,
    this.groupName,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.visibility = 'public',
    this.postType,
    this.hashtags,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isSaved = false,
    this.reactionsSummary,
    this.currentUserReaction,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) => SocialPostModel(
        idPost: json['idPost'] ?? '',
        idUser: json['idUser'] ?? '',
        userName: json['userName'] ?? '',
        avatarUrl: json['avatarUrl'],
        idGroup: json['idGroup'],
        groupName: json['groupName'],
        content: json['content'] ?? '',
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        visibility: json['visibility'] ?? 'public',
        postType: json['postType'],
        hashtags: json['hashtags'] != null
            ? List<String>.from(json['hashtags'])
            : [],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        likesCount: json['likesCount'] ?? 0,
        commentsCount: json['commentsCount'] ?? 0,
        sharesCount: json['sharesCount'] ?? 0,
        isSaved: json['isSaved'] ?? false,
        reactionsSummary: json['reactionsSummary'] != null
            ? Map<String, int>.from(json['reactionsSummary'])
            : {},
        currentUserReaction: json['currentUserReaction'],
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idUser': idUser,
        'userName': userName,
        'avatarUrl': avatarUrl,
        'idGroup': idGroup,
        'groupName': groupName,
        'content': content,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'visibility': visibility,
        'postType': postType,
        'hashtags': hashtags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'sharesCount': sharesCount,
        'isSaved': isSaved,
        'reactionsSummary': reactionsSummary,
        'currentUserReaction': currentUserReaction,
      };

  SocialPostModel copyWith({
    String? idPost,
    String? idUser,
    String? userName,
    String? avatarUrl,
    String? idGroup,
    String? groupName,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? visibility,
    String? postType,
    List<String>? hashtags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isSaved,
    Map<String, int>? reactionsSummary,
    String? currentUserReaction,
  }) {
    return SocialPostModel(
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      idGroup: idGroup ?? this.idGroup,
      groupName: groupName ?? this.groupName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      visibility: visibility ?? this.visibility,
      postType: postType ?? this.postType,
      hashtags: hashtags ?? this.hashtags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isSaved: isSaved ?? this.isSaved,
      reactionsSummary: reactionsSummary ?? this.reactionsSummary,
      currentUserReaction: currentUserReaction ?? this.currentUserReaction,
    );
  }

  @override
  String toString() =>
      'SocialPostModel(idPost: $idPost, userName: $userName, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
}

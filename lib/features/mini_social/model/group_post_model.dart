class GroupPostModel {
  final String idPost;
  final String idGroup;
  final String idUser;
  final String userName;
  final String userAvatar;
  final String content;
  final String? mediaUrl;
  final String? postType;
  final String approvalStatus;
  final DateTime createdAt;
  final int commentCount;
  final int reactionCount;
  final bool isLikedByUser;
  final String? userReaction;

  GroupPostModel({
    required this.idPost,
    required this.idGroup,
    required this.idUser,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.mediaUrl,
    this.postType,
    required this.approvalStatus,
    required this.createdAt,
    this.commentCount = 0,
    this.reactionCount = 0,
    this.isLikedByUser = false,
    this.userReaction,
  });

  factory GroupPostModel.fromJson(Map<String, dynamic> json) => GroupPostModel(
        idPost: json['idPost'] ?? '',
        idGroup: json['idGroup'] ?? '',
        idUser: json['idUser'] ?? '',
        userName: json['userName'] ?? '',
        userAvatar: json['userAvatar'] ?? '',
        content: json['content'] ?? '',
        mediaUrl: json['mediaUrl'],
        postType: json['postType'],
        approvalStatus: json['approvalStatus'] ?? 'pending',
        createdAt: DateTime.parse(json['createdAt']),
        commentCount: json['commentCount'] ?? 0,
        reactionCount: json['reactionCount'] ?? 0,
        isLikedByUser: json['isLikedByUser'] ?? false,
        userReaction: json['userReaction'],
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idGroup': idGroup,
        'idUser': idUser,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'mediaUrl': mediaUrl,
        'postType': postType,
        'approvalStatus': approvalStatus,
        'createdAt': createdAt.toIso8601String(),
        'commentCount': commentCount,
        'reactionCount': reactionCount,
        'isLikedByUser': isLikedByUser,
        'userReaction': userReaction,
      };

  GroupPostModel copyWith({
    String? idPost,
    String? idGroup,
    String? idUser,
    String? userName,
    String? userAvatar,
    String? content,
    String? mediaUrl,
    String? postType,
    String? approvalStatus,
    DateTime? createdAt,
    int? commentCount,
    int? reactionCount,
    bool? isLikedByUser,
    String? userReaction,
  }) {
    return GroupPostModel(
      idPost: idPost ?? this.idPost,
      idGroup: idGroup ?? this.idGroup,
      idUser: idUser ?? this.idUser,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      postType: postType ?? this.postType,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      reactionCount: reactionCount ?? this.reactionCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      userReaction: userReaction ?? this.userReaction,
    );
  }

  @override
  String toString() => 'GroupPostModel($idPost by $userName in $idGroup)';
}

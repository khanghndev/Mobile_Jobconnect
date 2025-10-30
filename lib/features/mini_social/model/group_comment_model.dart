import 'package:job_connect/features/mini_social/model/group_reaction_model.dart';

class GroupCommentModel {
  final String idComment;
  final String idPost;
  final String idUser;
  final String userName;
  final String userAvatar;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final int replyCount;
  final int reactionCount;
  final List<GroupReactionModel> reactions;
  final List<String> replies;
  final bool isLikedByUser;
  final String? userReaction;

  GroupCommentModel({
    required this.idComment,
    required this.idPost,
    required this.idUser,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.replyCount,
    required this.reactionCount,
    required this.reactions,
    required this.replies,
    required this.isLikedByUser,
    this.userReaction,
  });

  factory GroupCommentModel.fromJson(Map<String, dynamic> json) {
    return GroupCommentModel(
      idComment: json['idComment'] ?? '',
      idPost: json['idPost'] ?? '',
      idUser: json['idUser'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parentId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      replyCount: json['replyCount'] ?? 0,
      reactionCount: json['reactionCount'] ?? 0,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => GroupReactionModel.fromJson(e))
              .toList() ??
          [],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isLikedByUser: json['isLikedByUser'] ?? false,
      userReaction: json['userReaction'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idComment': idComment,
        'idPost': idPost,
        'idUser': idUser,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'parentId': parentId,
        'createdAt': createdAt.toIso8601String(),
        'replyCount': replyCount,
        'reactionCount': reactionCount,
        'reactions': reactions.map((e) => e.toJson()).toList(),
        'replies': replies,
        'isLikedByUser': isLikedByUser,
        'userReaction': userReaction,
      };

  GroupCommentModel copyWith({
    String? idComment,
    String? idPost,
    String? idUser,
    String? userName,
    String? userAvatar,
    String? content,
    String? parentId,
    DateTime? createdAt,
    int? replyCount,
    int? reactionCount,
    List<GroupReactionModel>? reactions,
    List<String>? replies,
    bool? isLikedByUser,
    String? userReaction,
  }) {
    return GroupCommentModel(
      idComment: idComment ?? this.idComment,
      idPost: idPost ?? this.idPost,
      idUser: idUser ?? this.idUser,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      replyCount: replyCount ?? this.replyCount,
      reactionCount: reactionCount ?? this.reactionCount,
      reactions: reactions ?? this.reactions,
      replies: replies ?? this.replies,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      userReaction: userReaction ?? this.userReaction,
    );
  }

  @override
  String toString() => 'GroupCommentModel($idComment - $userName)';
}
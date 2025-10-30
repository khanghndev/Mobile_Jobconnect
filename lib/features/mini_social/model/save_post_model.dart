import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class SavedPostModel {
  final String idPost;
  final String idUser;
  final DateTime savedAt;
  final String folderName;
  final String note;
  final SocialPostModel? post;

  SavedPostModel({
    required this.idPost,
    required this.idUser,
    required this.savedAt,
    required this.folderName,
    required this.note,
    this.post,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) => SavedPostModel(
        idPost: json['idPost'] as String,
        idUser: json['idUser'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        folderName: json['folderName'] as String,
        note: json['note'] as String,
        post: SocialPostModel.fromJson(json['post'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'idPost': idPost,
        'idUser': idUser,
        'savedAt': savedAt.toIso8601String(),
        'folderName': folderName,
        'note': note,
        'post': post?.toJson(),
      };
}
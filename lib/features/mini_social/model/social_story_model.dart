class SocialStoryModel {
  final String idStory;
  final String idUser;
  final String? mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  SocialStoryModel({
    required this.idStory,
    required this.idUser,
    this.mediaUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
  });

  factory SocialStoryModel.fromJson(Map<String, dynamic> json) => SocialStoryModel(
        idStory: json['idStory'],
        idUser: json['idUser'],
        mediaUrl: json['mediaUrl'],
        caption: json['caption'],
        createdAt: DateTime.parse(json['createdAt']),
        expiresAt: DateTime.parse(json['expiresAt']),
      );

  Map<String, dynamic> toJson() => {
        'idStory': idStory,
        'idUser': idUser,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  SocialStoryModel copyWith({
    String? idStory,
    String? idUser,
    String? mediaUrl,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return SocialStoryModel(
      idStory: idStory ?? this.idStory,
      idUser: idUser ?? this.idUser,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() => 'SocialStoryModel($idStory, $idUser)';
}

class SocialTagModel {
  final String idTag;
  final String tagName;
  final DateTime createdAt;

  SocialTagModel({
    required this.idTag,
    required this.tagName,
    required this.createdAt,
  });

  factory SocialTagModel.fromJson(Map<String, dynamic> json) => SocialTagModel(
        idTag: json['idTag'],
        tagName: json['tagName'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idTag': idTag,
        'tagName': tagName,
        'createdAt': createdAt.toIso8601String(),
      };

  SocialTagModel copyWith({
    String? idTag,
    String? tagName,
    DateTime? createdAt,
  }) {
    return SocialTagModel(
      idTag: idTag ?? this.idTag,
      tagName: tagName ?? this.tagName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SocialTagModel($tagName)';
}

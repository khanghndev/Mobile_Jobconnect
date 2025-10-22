class GroupTagModel {
  final String idTag;
  final String tagName;
  final DateTime createdAt;

  GroupTagModel({
    required this.idTag,
    required this.tagName,
    required this.createdAt,
  });

  factory GroupTagModel.fromJson(Map<String, dynamic> json) => GroupTagModel(
        idTag: json['idTag'],
        tagName: json['tagName'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'idTag': idTag,
        'tagName': tagName,
        'createdAt': createdAt.toIso8601String(),
      };

  GroupTagModel copyWith({
    String? idTag,
    String? tagName,
    DateTime? createdAt,
  }) {
    return GroupTagModel(
      idTag: idTag ?? this.idTag,
      tagName: tagName ?? this.tagName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'GroupTagModel($tagName)';
}

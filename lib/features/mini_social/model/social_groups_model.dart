class SocialGroupsModel {
  final String idGroup;
  final String groupName;
  final String? description;
  final String privacy;
  final String? coverImageUrl;
  final bool requirePostApproval;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialGroupsModel({
    required this.idGroup,
    required this.groupName,
    this.description,
    this.privacy = 'public',
    this.coverImageUrl,
    this.requirePostApproval = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialGroupsModel.fromJson(Map<String, dynamic> json) =>
      SocialGroupsModel(
        idGroup: json['idGroup'],
        groupName: json['groupName'],
        description: json['description'],
        privacy: json['privacy'],
        coverImageUrl: json['coverImageUrl'],
        requirePostApproval:
            json['requirePostApproval'] == 1 || json['requirePostApproval'] == true,
        createdBy: json['createdBy'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'idGroup': idGroup,
        'groupName': groupName,
        'description': description,
        'privacy': privacy,
        'coverImageUrl': coverImageUrl,
        'requirePostApproval': requirePostApproval ? 1 : 0,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  SocialGroupsModel copyWith({
    String? idGroup,
    String? groupName,
    String? description,
    String? privacy,
    String? coverImageUrl,
    bool? requirePostApproval,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialGroupsModel(
      idGroup: idGroup ?? this.idGroup,
      groupName: groupName ?? this.groupName,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      requirePostApproval: requirePostApproval ?? this.requirePostApproval,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'SocialGroupsModel($groupName - $privacy)';
}

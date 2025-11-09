class SocialGroupsModel {
  final String idGroup;
  final String groupName;
  final String? description;
  final String privacy;
  final String? coverImageUrl;
  final String? avatarUrl;
  final String? createdBy;
  final String creatorName;
  final DateTime createdAt;
  final int memberCount;
  final int postCount;
  final List<String> tags;
  final bool requirePostApproval;
  final String? userRole;
  final String? userStatus;

  SocialGroupsModel({
    required this.idGroup,
    required this.groupName,
    this.description,
    this.privacy = 'public',
    this.coverImageUrl,
    this.avatarUrl,
    this.createdBy,
    required this.creatorName,
    required this.createdAt,
    this.memberCount = 0,
    this.postCount = 0,
    this.tags = const [],
    this.requirePostApproval = true,
    this.userRole,
    this.userStatus,
  });

  factory SocialGroupsModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(json['createdAt'] ?? '');
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return SocialGroupsModel(
      idGroup: json['idGroup'] ?? '',
      groupName: json['groupName'] ?? '',
      description: json['description'],
      privacy: json['privacy'] ?? 'public',
      coverImageUrl: json['coverImageUrl'],
      avatarUrl: json['avatarUrl'],
      createdBy: json['createdBy'] ?? '', // parse createdBy
      creatorName: json['creatorName'] ?? '',
      createdAt: parsedCreatedAt,
      memberCount: json['memberCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      requirePostApproval: json['requirePostApproval'] == true,
      userRole: json['userRole'],
      userStatus: json['userStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idGroup': idGroup,
        'groupName': groupName,
        'description': description,
        'privacy': privacy,
        'coverImageUrl': coverImageUrl,
        'avatarUrl': avatarUrl,
        'createdBy': createdBy, // thêm vào toJson
        'creatorName': creatorName,
        'createdAt': createdAt.toIso8601String(),
        'memberCount': memberCount,
        'postCount': postCount,
        'tags': tags,
        'requirePostApproval': requirePostApproval,
        'userRole': userRole,
        'userStatus': userStatus,
      };

  SocialGroupsModel copyWith({
    String? idGroup,
    String? groupName,
    String? description,
    String? privacy,
    String? coverImageUrl,
    String? avatarUrl,
    String? createdBy,
    String? creatorName,
    DateTime? createdAt,
    int? memberCount,
    int? postCount,
    List<String>? tags,
    bool? requirePostApproval,
    String? userRole,
    String? userStatus,
  }) {
    return SocialGroupsModel(
      idGroup: idGroup ?? this.idGroup,
      groupName: groupName ?? this.groupName,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy, // copyWith
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      postCount: postCount ?? this.postCount,
      tags: tags ?? this.tags,
      requirePostApproval: requirePostApproval ?? this.requirePostApproval,
      userRole: userRole ?? this.userRole,
      userStatus: userStatus ?? this.userStatus,
    );
  }

  @override
  String toString() => 'SocialGroupsModel($groupName - $privacy)';
}
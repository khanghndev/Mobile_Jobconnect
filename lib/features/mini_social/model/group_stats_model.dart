class GroupStatsModel {
  final int totalGroups;
  final int joinedGroups;
  final int createdGroups;

  GroupStatsModel({
    required this.totalGroups,
    required this.joinedGroups,
    required this.createdGroups,
  });

  factory GroupStatsModel.fromJson(Map<String, dynamic> json) => GroupStatsModel(
        totalGroups: json['totalGroups'] ?? 0,
        joinedGroups: json['joinedGroups'] ?? 0,
        createdGroups: json['createdGroups'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalGroups': totalGroups,
        'joinedGroups': joinedGroups,
        'createdGroups': createdGroups,
      };

  @override
  String toString() =>
      'GroupStatsModel(totalGroups: $totalGroups, joinedGroups: $joinedGroups, createdGroups: $createdGroups)';
}

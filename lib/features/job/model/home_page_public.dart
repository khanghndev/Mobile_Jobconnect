class HomePagePublic {
  final List<String> trendingSkills;
  final List<String> popularLocations;
  final String? message;

  HomePagePublic({
    required this.trendingSkills,
    required this.popularLocations,
    this.message,
  });

  factory HomePagePublic.fromJson(Map<String, dynamic> json) {
    return HomePagePublic(
      trendingSkills: List<String>.from(json['trendingSkills'] ?? []),
      popularLocations: List<String>.from(json['popularLocations'] ?? []),
      message: json['message'],
    );
  }
}

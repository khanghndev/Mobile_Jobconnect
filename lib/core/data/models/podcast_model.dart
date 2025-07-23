class Podcast {
  final String idPodcast;
  final String title;
  final int duration;
  final String? description;
  final String? host;
  final String? audioUrl;
  final String? coverImageUrl;
  final DateTime? publishDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Podcast({
    required this.idPodcast,
    required this.title,
    this.duration = 0,
    this.description,
    this.host,
    this.audioUrl,
    this.coverImageUrl,
    this.publishDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      idPodcast: json['idPodcast'],
      title: json['title'],
      duration: json['duration'] ?? 0,
      description: json['description'],
      host: json['host'],
      audioUrl: json['audioUrl'],
      coverImageUrl: json['coverImageUrl'],
      publishDate:
          json['publishDate'] != null
              ? DateTime.parse(json['publishDate'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPodcast': idPodcast,
      'title': title,
      'duration': duration,
      'description': description,
      'host': host,
      'audioUrl': audioUrl,
      'coverImageUrl': coverImageUrl,
      'publishDate': publishDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Podcast(idPodcast: $idPodcast, title: $title, duration: $duration, host: $host)';
  }
}

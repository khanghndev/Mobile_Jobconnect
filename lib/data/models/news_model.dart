class News {
  final int idNews;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final DateTime publishDate;
  final String? author;
  final bool isPublished;
  final String categoryName;
  final String targetAudience; // e.g. "All", "Candidate", "Employer"

  News({
    required this.idNews,
    required this.title,
    required this.content,
    this.summary,
    this.imageUrl,
    required this.publishDate,
    this.author,
    required this.isPublished,
    required this.categoryName,
    required this.targetAudience,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      idNews:        json['idNews']        as int,
      title:         json['title']         as String,
      content:       json['content']       as String,
      summary:       json['summary']       as String?,
      imageUrl:      json['imageUrl']      as String?,
      publishDate:   DateTime.parse(json['publishDate'] as String),
      author:        json['author']        as String?,
      isPublished:   json['isPublished']   as bool,
      categoryName:  json['categoryName']  as String,
      targetAudience:json['targetAudience']as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'idNews':         idNews,
        'title':          title,
        'content':        content,
        'summary':        summary,
        'imageUrl':       imageUrl,
        'publishDate':    publishDate.toIso8601String(),
        'author':         author,
        'isPublished':    isPublished,
        'categoryName':   categoryName,
        'targetAudience': targetAudience,
      };
}

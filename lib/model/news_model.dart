class NewsModel {
  final int idNews;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final DateTime publishDate;
  final String? author;
  final bool isPublished;
  final String categoryName;
  final String targetAudience;

  NewsModel({
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

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        idNews: json['idNews'],
        title: json['title'],
        content: json['content'],
        summary: json['summary'],
        imageUrl: json['imageUrl'],
        publishDate: DateTime.parse(json['publishDate']),
        author: json['author'],
        isPublished: json['isPublished'],
        categoryName: json['categoryName'],
        targetAudience: json['targetAudience'],
      );

  Map<String, dynamic> toJson() => {
        'idNews': idNews,
        'title': title,
        'content': content,
        'summary': summary,
        'imageUrl': imageUrl,
        'publishDate': publishDate.toIso8601String(),
        'author': author,
        'isPublished': isPublished,
        'categoryName': categoryName,
        'targetAudience': targetAudience,
      };

  NewsModel copyWith({
    int? idNews,
    String? title,
    String? content,
    String? summary,
    String? imageUrl,
    DateTime? publishDate,
    String? author,
    bool? isPublished,
    String? categoryName,
    String? targetAudience,
  }) {
    return NewsModel(
      idNews: idNews ?? this.idNews,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      publishDate: publishDate ?? this.publishDate,
      author: author ?? this.author,
      isPublished: isPublished ?? this.isPublished,
      categoryName: categoryName ?? this.categoryName,
      targetAudience: targetAudience ?? this.targetAudience,
    );
  }

  @override
  String toString() => 'NewsModel($idNews - $title)';
}
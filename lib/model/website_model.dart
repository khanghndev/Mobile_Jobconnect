class WebsiteModel {
  final String idWebsite;
  final String name;
  final String url;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebsiteModel({
    required this.idWebsite,
    required this.name,
    required this.url,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebsiteModel.fromJson(Map<String, dynamic> json) => WebsiteModel(
        idWebsite: json['idWebsite'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'idWebsite': idWebsite,
        'name': name,
        'url': url,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  WebsiteModel copyWith({
    String? idWebsite,
    String? name,
    String? url,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WebsiteModel(
      idWebsite: idWebsite ?? this.idWebsite,
      name: name ?? this.name,
      url: url ?? this.url,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'WebsiteModel(idWebsite: $idWebsite, name: $name, url: $url, isActive: $isActive)';
}
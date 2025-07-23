class Website {
  final String idWebsite;
  final String name;
  final String url;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Website({
    required this.idWebsite,
    required this.name,
    required this.url,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      idWebsite: json['idWebsite'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idWebsite': idWebsite,
      'name': name,
      'url': url,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Website(idWebsite: $idWebsite, name: $name, url: $url, isActive: $isActive)';
  }
}

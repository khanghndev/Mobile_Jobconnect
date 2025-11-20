class JobCategoryModel {
  final String? idCategory;
  final String? categoryName;
  final String? categoryCode;
  final String? description;
  final String? icon;
  final bool? isActive;
  final int? displayOrder;

  const JobCategoryModel({
    this.idCategory,
    this.categoryName,
    this.categoryCode,
    this.description,
    this.icon,
    this.isActive,
    this.displayOrder,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      idCategory: json['idCategory'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryCode: json['categoryCode'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool?,
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder']
          : int.tryParse(json['displayOrder']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': idCategory,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'description': description,
      'icon': icon,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  JobCategoryModel copyWith({
    String? idCategory,
    String? categoryName,
    String? categoryCode,
    String? description,
    String? icon,
    bool? isActive,
    int? displayOrder,
  }) {
    return JobCategoryModel(
      idCategory: idCategory ?? this.idCategory,
      categoryName: categoryName ?? this.categoryName,
      categoryCode: categoryCode ?? this.categoryCode,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
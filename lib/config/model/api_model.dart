class ApiModel<T> {
  final int? status;
  final String? message;
  final T? data;

  ApiModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiModel<T>(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value)? toJsonT) {
    return {
      'status': status,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }
}

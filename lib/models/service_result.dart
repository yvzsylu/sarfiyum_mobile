class ServiceResult<T> {
  final T? data;
  final bool isSuccess;
  final List<String>? errors;
  final int statusCode;

  ServiceResult({
    this.data,
    required this.isSuccess,
    this.errors,
    required this.statusCode,
  });

  factory ServiceResult.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    return ServiceResult<T>(
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      isSuccess: json['isSuccess'] ?? false,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
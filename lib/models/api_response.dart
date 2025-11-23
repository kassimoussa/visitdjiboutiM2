class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final String? errorCode;
  final int? remainingAttempts;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.errorCode,
    this.remainingAttempts,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'],
      errorCode: json['error_code'],
      remainingAttempts: json['remaining_attempts'],
    );
  }
}

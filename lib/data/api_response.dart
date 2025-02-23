class ApiResponse {
  final dynamic data;
  final bool isSuccessful;
  final String? message;
  int? code;

  ApiResponse({
    this.data,
    required this.isSuccessful,
    this.message,
    this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'],
      isSuccessful: false,
      message: json['message'] ?? json['error'],
    );
  }

  factory ApiResponse.timeout() {
    return ApiResponse(
      data: null,
      isSuccessful: false,
      message: 'Request timeout',
    );
  }

  factory ApiResponse.unknownError(int statusCode) {
    return ApiResponse(
      data: null,
      isSuccessful: false,
      message: 'Unknown error occurred',
      code: statusCode,
    );
  }
} 
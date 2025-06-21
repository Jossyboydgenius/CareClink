import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';

enum ApiStatus {
  success,
  failure,
}

class ApiResponse {
  dynamic code;
  dynamic data;
  dynamic others;
  bool isSuccessful;
  final bool? isTimeout;
  final String? message;
  final String? errorType;
  final String? errorCode;
  final String? token;
  final String? type;

  ApiResponse({
    this.code,
    this.data,
    this.others,
    required this.isSuccessful,
    this.isTimeout,
    this.message,
    this.token,
    this.errorType,
    this.errorCode,
    this.type,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('errorMessage') && json.containsKey('errorCode')) {
      String errorMessage = json['errorMessage'];
      String errorCode = json['errorCode'];

      if (errorCode == '32' && errorMessage.contains('not found')) {
        errorMessage = 'Email not found';
      }

      return ApiResponse(
        isSuccessful: false,
        message: errorMessage,
        errorCode: errorCode,
        errorType: json['httpStatus'],
      );
    }

    return ApiResponse(
      message: json['message'] ?? json['error'] ?? json['errorMessage'],
      errorType: json['type'],
      errorCode: json['code'],
      isSuccessful: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] is bool && json['data'] != false)
              ? json['data']
              : null
          : json['results'],
      token: json['token'],
    );
  }

  factory ApiResponse.timeout() {
    return ApiResponse(
      data: null,
      isSuccessful: false,
      others: 'timeout',
      isTimeout: true,
      message: 'Error occurred. Please try again later',
    );
  }

  factory ApiResponse.unknownError(int code) {
    return ApiResponse(
      isSuccessful: false,
      message: kReleaseMode
          ? 'Error occurred while Communication with our Server, please try again'
          : 'Error occurred while Communication with Server with StatusCode : $code',
    );
  }

  // Factory to create ApiResponse from HTTP response
  factory ApiResponse.fromHttpResponse(Response response) {
    final responseBody = response.body;
    debugPrint('Response body: $responseBody');

    // For type errors, we need to check raw string content
    if (responseBody
            .contains("type 'String' is not a subtype of type 'Map<String") ||
        responseBody.contains("Failed to fetch timesheets") ||
        responseBody.contains("Failed to clock in")) {
      // Type errors are often related to permission issues / interpreter-only features
      debugPrint(
          'Detected type error, likely due to interpreter-only feature restriction');
      return ApiResponse(
        isSuccessful: false,
        code: 403,
        message:
            'This app is designed for interpreters only. Please sign in with an interpreter account.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic decodedJson;
      String? message;

      if (responseBody.isNotEmpty &&
          (responseBody.startsWith('{') || responseBody.startsWith('['))) {
        try {
          decodedJson = jsonDecode(responseBody);
          if (decodedJson is Map) {
            message = decodedJson['message'];
          }
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
          // Just use the response body as is
          decodedJson = responseBody;
        }
      }

      return ApiResponse(
        isSuccessful: true,
        data: decodedJson,
        message: message ?? 'success',
      );
    } else if (response.statusCode == 204) {
      return ApiResponse(
        isSuccessful: true,
        message: 'success',
      );
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      if (responseBody.isNotEmpty) {
        try {
          // Try to decode the JSON response
          final responseBodyDecoded = jsonDecode(responseBody);

          // Check specifically for role-based access restrictions
          if (response.statusCode == 403 ||
              responseBody.toLowerCase().contains("role") ||
              responseBody.toLowerCase().contains("permission") ||
              (responseBodyDecoded is Map &&
                  (responseBodyDecoded['message']
                              ?.toString()
                              .toLowerCase()
                              .contains("role") ==
                          true ||
                      responseBodyDecoded['message']
                              ?.toString()
                              .toLowerCase()
                              .contains("permission") ==
                          true))) {
            debugPrint('Detected role-based access restriction');
            return ApiResponse(
              isSuccessful: false,
              code: 403,
              message:
                  'You do not have permission to access this feature. Please sign in with the appropriate account.',
            );
          }

          // Handle common type errors that indicate permission issues
          if (responseBody
              .contains("type 'String' is not a subtype of type 'Map<String")) {
            debugPrint('Detected potential type error with permission issue');
            return ApiResponse(
              isSuccessful: false,
              code: 403,
              message:
                  'This app is designed for interpreters only. Please sign in with an interpreter account.',
            );
          }

          final responseModel = ApiResponse.fromJson(responseBodyDecoded);
          responseModel.code = response.statusCode;
          return responseModel;
        } catch (e) {
          debugPrint('Error decoding error response: $e');

          // Check raw response for role/permission-related terms
          if (responseBody.toLowerCase().contains('role') ||
              responseBody.toLowerCase().contains('permission')) {
            return ApiResponse(
              isSuccessful: false,
              code: 403,
              message:
                  'You do not have permission to access this feature. Please sign in with the appropriate account.',
            );
          }

          // Check for type errors in the raw response (often permission issues)
          if (responseBody
              .contains("type 'String' is not a subtype of type 'Map<String")) {
            return ApiResponse(
              isSuccessful: false,
              code: 403,
              message:
                  'You do not have permission to access this feature. Please sign in with the appropriate account.',
            );
          }

          // Return a generic error response
          return ApiResponse(
            isSuccessful: false,
            code: response.statusCode,
            message: 'Error: $responseBody',
          );
        }
      }
      return ApiResponse.unknownError(response.statusCode);
    } else {
      return ApiResponse(
        isSuccessful: false,
        message: kReleaseMode
            ? 'Error occurred'
            : 'Error occurred: ${response.statusCode}',
      );
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../../../app/flavor_config.dart';
import '../../../app/locator.dart';
import '../local_storage_service.dart';

import 'api_response.dart';

class Api {
  final AppFlavorConfig _config = locator<AppFlavorConfig>();
  static const bool useStaging = false;
  String get baseUrl => _config.apiBaseUrl;
  String? _token;
  final LocalStorageService localStorageService =
      locator<LocalStorageService>();

  void updateToken(String? token) {
    _token = token;
    debugPrint('API token updated: $_token');
  }

  Map<String, String> get _headers {
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      debugPrint('Adding authorization header: Bearer $_token');
    } else {
      debugPrint('No token available for headers');
    }

    return headers;
  }

  Future<ApiResponse> postData(
    String url,
    dynamic body, {
    bool hasHeader = false,
    bool isMultiPart = false,
    File? fileList,
    String? customBaseUrl,
  }) async {
    try {
      final fullUrl = customBaseUrl ?? _config.apiBaseUrl + url;
      final request = Request('POST', Uri.parse(fullUrl));

      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> patchData(
    String url,
    body, {
    bool hasHeader = false,
  }) async {
    try {
      Request request = Request('PATCH', Uri.parse(_config.apiBaseUrl + url));

      debugPrint(
          'PATCH request to ${_config.apiBaseUrl + url} with body: $body');
      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('$e');
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> getData(
    String url, {
    body,
    bool hasHeader = false,
    String? key,
    bool retry = false,
  }) async {
    Request request;
    try {
      request = Request(
        'GET',
        Uri.parse(_config.apiBaseUrl + url),
      );

      debugPrint('GET request to ${request.url}  ');
      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error signing in with: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> deleteData(String url,
      {body, bool hasHeader = false, String? key}) async {
    Request request;
    try {
      request = Request(
        'DELETE',
        Uri.parse(_config.apiBaseUrl + url),
      );

      debugPrint('DELETE request to ${request.url}  ');
      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error signing in with: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> putData(
    String url,
    Map<String, dynamic> body, {
    bool hasHeader = true,
  }) async {
    try {
      final request = Request('PUT', Uri.parse(_config.apiBaseUrl + url));

      // Always try in-memory token first - most reliable for both remember me and non-remember me cases
      if (_token != null && _token!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_token';
        debugPrint('Using in-memory token for PUT request: $_token');
      }
      // Only try storage if in-memory token is not available and auth is needed
      else if (hasHeader) {
        final userValue = await localStorageService
            .getStorageValue(LocalStorageKeys.accessToken);
        if (userValue != null && userValue.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $userValue';
          debugPrint('Using stored token for PUT request: $userValue');

          // Update in-memory token for consistency
          updateToken(userValue);
        } else {
          debugPrint(
              'No token available for PUT request - this may cause auth errors');
        }
      }

      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(body);

      debugPrint('PUT request to ${_config.apiBaseUrl + url} with body: $body');

      final streamedResponse = await request.send();
      final response = await Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse(
          isSuccessful: true,
          data: responseData,
          message:
              responseData?['message'] ?? 'Clock-out time successfully updated',
        );
      } else {
        return ApiResponse(
          isSuccessful: false,
          message: 'Failed with status code: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> _sendRequest(
    Request request,
    bool hasHeader, {
    dynamic body,
  }) async {
    try {
      // Always add authorization header if in-memory token exists
      // This is critical for non-remember me sessions to work properly
      if (_token != null && _token!.isNotEmpty) {
        request.headers.addAll({
          'Authorization': 'Bearer $_token',
        });
        debugPrint('Using in-memory token for request: $_token');
      }
      // Only fall back to storage if we need to and don't have a token in memory
      else if (hasHeader) {
        // Try to get from local storage
        final storedToken = await localStorageService
            .getStorageValue(LocalStorageKeys.accessToken);
        if (storedToken != null && storedToken.isNotEmpty) {
          request.headers.addAll({
            'Authorization': 'Bearer $storedToken',
          });
          debugPrint('Using stored token for request: $storedToken');

          // Update the in-memory token to keep consistency
          updateToken(storedToken);
        } else {
          debugPrint(
              'No token available for request - this may cause auth errors');
        }
      } else {
        debugPrint('Request made without authentication header');
      }

      // Add other headers
      if (hasHeader) {
        request.headers.addAll(_headers);
      } else {
        // Add minimal headers without authentication
        request.headers.addAll({
          'accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        });
      }

      // Add body if provided
      if (body != null) {
        request.body = jsonEncode(body);
      }

      debugPrint('Sending ${request.method} request to ${request.url}');

      // Get the response
      final streamedResponse = await Client().send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );
      final response = await Response.fromStream(streamedResponse);

      debugPrint('Got response with status: ${response.statusCode}');

      // Handle different status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        return ApiResponse.fromHttpResponse(response);
      } else if (response.statusCode == 401) {
        // Unauthorized - possibly token expired
        debugPrint('401 Unauthorized response: ${response.body}');

        // Check if this is "Remember Me" state issue
        final rememberMe = await localStorageService.getRememberMe();
        if (!rememberMe) {
          // This is expected, user didn't want to be remembered but token expired
          debugPrint('Token expired - Remember Me was not checked');
        }

        return ApiResponse.fromHttpResponse(response);
      } else {
        // Other errors
        return ApiResponse.fromHttpResponse(response);
      }
    } catch (e) {
      debugPrint('Error in _sendRequest: $e');
      rethrow;
    }
  }
}

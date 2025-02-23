import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../app/flavor_config.dart';
import '../app/locator.dart';

import 'api_response.dart';

class Api {
  final AppFlavorConfig _config = locator<AppFlavorConfig>();
  Map<String, String> headers = {
    HttpHeaders.acceptHeader: 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

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

  Future<ApiResponse> _sendRequest(
    Request request,
    bool hasHeader, {
    Map<String, dynamic>? body,
  }) async {
    if (body != null) {
      request.body = json.encode(body);
    }
    log('body: $body');
    
    request.headers.addAll(headers);
    debugPrint(
        '${request.method.toUpperCase()} request to ${request.url}  ==> body: $body ');
    
    final response = await request.send();
    return await _response(response);
  }

  Future<ApiResponse> _response(StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();
    debugPrint('Response body: $responseBody');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic decodedJson;
      String? message;
      
      if (responseBody.isNotEmpty &&
          (responseBody.startsWith('{') || responseBody.startsWith('['))) {
        decodedJson = jsonDecode(responseBody);
        if (decodedJson is Map) {
          message = decodedJson['message'];
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
        final responseBodyDecoded = jsonDecode(responseBody);
        final responseModel = ApiResponse.fromJson(responseBodyDecoded);
        responseModel.code = response.statusCode;
        return responseModel;
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
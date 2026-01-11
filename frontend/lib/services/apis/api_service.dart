import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:league_music_player/core/constants/app_constants.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1';
  static const Duration _defaultTimeout = Duration(seconds: 5);

  @protected
  Uri? buildUri(String endpoint) {
    if (port == 0) return null; // backend not ready
    final normalized = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return Uri.parse('$_baseUrl:$port/$normalized');
  }

  Future<http.Response?> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = buildUri(endpoint);
    if (uri == null) return null;
    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(timeout ?? _defaultTimeout);
      return response;
    } catch (e) {
      debugPrint('GET ${uri.toString()} failed: $e');
      return null;
    }
  }

  Future<http.Response?> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final uri = buildUri(endpoint);
    if (uri == null) return null;
    try {
      final mergedHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      };
      final response = await http
          .patch(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
            encoding: encoding,
          )
          .timeout(timeout ?? _defaultTimeout);
      return response;
    } catch (e) {
      debugPrint('PATCH ${uri.toString()} failed: $e');
      return null;
    }
  }

  Future<http.Response?> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final uri = buildUri(endpoint);
    if (uri == null) return null;
    try {
      final mergedHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
        if (headers != null) ...headers,
      };
      final response = await http
          .put(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
            encoding: encoding,
          )
          .timeout(timeout ?? _defaultTimeout);
      return response;
    } catch (e) {
      debugPrint('PUT ${uri.toString()} failed: $e');
      return null;
    }
  }

  @protected
  bool isOk(http.Response? response) =>
      response != null &&
      response.statusCode >= 200 &&
      response.statusCode < 300;
}

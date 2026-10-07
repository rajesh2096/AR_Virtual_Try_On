import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'api_exception.dart';

class ApiClient {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server at ${AppConfig.baseUrl}. Please verify the server is running and reachable.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server at ${AppConfig.baseUrl}. Please verify the server is running and reachable.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server at ${AppConfig.baseUrl}. Please check network connection.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  static MediaType _getMediaTypeForFile(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    return MediaType('image', 'jpeg');
  }

  static Future<dynamic> uploadMultipart({
    required String endpoint,
    required String fileField,
    required File file,
    Map<String, String>? fields,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      if (requireAuth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final mediaType = _getMediaTypeForFile(file.path);
      request.files.add(await http.MultipartFile.fromPath(
        fileField,
        file.path,
        contentType: mediaType,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot connect to server at ${AppConfig.baseUrl}. Please check network connection.');
    } on http.ClientException catch (e) {
      throw ApiException('Upload failed: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('File upload error: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String message = 'Request failed with status code ${response.statusCode}';
      if (body is Map && body.containsKey('detail')) {
        message = body['detail'].toString();
      }
      throw ApiException(message, response.statusCode);
    }
  }
}

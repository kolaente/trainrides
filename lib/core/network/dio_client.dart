import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  http.Client? _client;
  String? _authToken;

  http.Client get client => _client ??= http.Client();

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, String>> get _headers async {
    await _ensureTokenLoaded();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Token $_authToken',
    };
  }

  Future<void> _ensureTokenLoaded() async {
    if (_authToken == null) {
      await getAuthToken();
    }
  }

  Future<http.Response> get(String url) async {
    try {
      final headers = await _headers;
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } catch (e) {
      throw NetworkException('Request failed: ${e.toString()}');
    }
  }

  Future<http.Response> post(String url, {required String body}) async {
    try {
      final headers = await _headers;
      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConstants.requestTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } catch (e) {
      throw NetworkException('Request failed: ${e.toString()}');
    }
  }

  Future<http.Response> put(String url, {required String body}) async {
    try {
      final headers = await _headers;
      final response = await client.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConstants.requestTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } catch (e) {
      throw NetworkException('Request failed: ${e.toString()}');
    }
  }

  Future<http.Response> patch(String url, {required String body}) async {
    try {
      final headers = await _headers;
      final response = await client.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(ApiConstants.requestTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } catch (e) {
      throw NetworkException('Request failed: ${e.toString()}');
    }
  }

  Future<http.Response> delete(String url) async {
    try {
      final headers = await _headers;
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.requestTimeout);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network error occurred');
    } catch (e) {
      throw NetworkException('Request failed: ${e.toString()}');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    
    switch (response.statusCode) {
      case 401:
        throw const AuthException('Unauthorized - Invalid token');
      case 403:
        throw const AuthException('Forbidden - Access denied');
      case 404:
        throw const ApiException('Resource not found');
      case 429:
        throw const ApiException('Too many requests - Rate limited');
      case 500:
        throw const ApiException('Internal server error');
      default:
        throw ApiException(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() {
    _client?.close();
    _client = null;
  }
}
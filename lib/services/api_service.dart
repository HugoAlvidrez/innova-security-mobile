import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Determine default API base URL depending on platform
  String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3001';
      }
    } catch (_) {}
    return 'http://127.0.0.1:3001';
  }

  late String baseUrl = defaultBaseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, dynamic>? _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _unwrapApiData(Map<String, dynamic> body) {
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  String? _extractAccessToken(Map<String, dynamic> payload) {
    final tokens = payload['tokens'] ?? payload;
    if (tokens is Map<String, dynamic>) {
      return tokens['accessToken']?.toString() ??
          tokens['access_token']?.toString() ??
          tokens['token']?.toString();
    }
    return null;
  }

  /// Check backend connection status (/api/status)
  Future<Map<String, dynamic>?> checkStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/api/status');
      final response = await http.get(uri, headers: _getHeaders()).timeout(
        const Duration(seconds: 5),
      );

      return _decodeBody(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('ApiService checkStatus error: $e');
      }
    }
    return null;
  }

  /// Authenticate user (/api/auth/login)
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/login');
      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final body = _decodeBody(response.body);
        if (body == null) return null;

        final data = _unwrapApiData(body);
        final accessToken = _extractAccessToken(data);
        if (accessToken != null) {
          setAuthToken(accessToken);
        }

        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        print('ApiService login error: $e');
      }
    }
    return null;
  }

  /// Register user (/api/auth/register)
  Future<Map<String, dynamic>?> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/register');
      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode({
              'full_name': fullName,
              'email': email,
              'password': password,
              'phone_number': phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = _decodeBody(response.body);
        if (body == null) return null;

        final data = _unwrapApiData(body);
        final accessToken = _extractAccessToken(data);
        if (accessToken != null) {
          setAuthToken(accessToken);
        }

        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        print('ApiService register error: $e');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getChatMessages(String eventId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/chat/$eventId');
      final response = await http.get(uri, headers: _getHeaders()).timeout(
        const Duration(seconds: 7),
      );
      return _decodeBody(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('ApiService getChatMessages error: $e');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendChatMessage(
    String eventId,
    String message,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/chat/send');
      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode({'eventId': eventId, 'message': message}),
          )
          .timeout(const Duration(seconds: 7));
      return _decodeBody(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('ApiService sendChatMessage error: $e');
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getEvents() async {
    try {
      final uri = Uri.parse('$baseUrl/api/events');
      final response = await http.get(uri, headers: _getHeaders()).timeout(
        const Duration(seconds: 7),
      );
      final body = _decodeBody(response.body);
      if (body != null && body['success'] == true) {
        final data = body['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map<String, dynamic> && data['events'] is List) {
          return List<Map<String, dynamic>>.from(data['events']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ApiService getEvents error: $e');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getEventMedia(String eventId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/evidence/$eventId');
      final response = await http.get(uri, headers: _getHeaders()).timeout(
        const Duration(seconds: 7),
      );
      final body = _decodeBody(response.body);
      if (body == null) return null;

      final data = _unwrapApiData(body);
      if (data['media'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['media']);
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('ApiService getEventMedia error: $e');
      }
    }
    return null;
  }

  /// Send emergency alert (/api/emergency-events)
  Future<bool> sendEmergencyAlert({
    required String alertType,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/emergency-events');
      final response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode({
          'alert_type': alertType,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('ApiService sendEmergencyAlert error: $e');
      }
      return false;
    }
  }
}

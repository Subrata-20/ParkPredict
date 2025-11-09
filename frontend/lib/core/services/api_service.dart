import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl;
  ApiService._internal(this.baseUrl);
  static final ApiService instance = ApiService._internal(dotenv.env['API_BASE_URL'] ?? 'https://api.example.com');

  Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      };

  Future<dynamic> get(String path, {Map<String,String>? params}) async {
    final uri = Uri.parse('\$baseUrl\$path').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers());
    return _process(res);
  }

  Future<dynamic> post(String path, Map body) async {
    final uri = Uri.parse('\$baseUrl\$path');
    final res = await http.post(uri, headers: _headers(), body: jsonEncode(body));
    return _process(res);
  }

  Future<dynamic> patch(String path, Map body) async {
    final uri = Uri.parse('\$baseUrl\$path');
    final res = await http.patch(uri, headers: _headers(), body: jsonEncode(body));
    return _process(res);
  }

  dynamic _process(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    } else {
      throw ApiException(res.statusCode, res.body);
    }
  }
}

class ApiException implements Exception {
  final int status;
  final String body;
  ApiException(this.status, this.body);
  @override
  String toString() => 'ApiException(status: \$status, body: \$body)';
}
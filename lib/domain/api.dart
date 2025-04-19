import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://45.155.207.23:4000/api';

  static Future<String> fetchHello() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      print('Получены данные: ${response.body}');
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    return response;
  }
}


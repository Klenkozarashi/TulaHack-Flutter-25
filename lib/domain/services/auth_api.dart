import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://45.155.207.23:4000/api';

  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print(response.headers);

      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final sessionToken = _parseSessionToken(rawCookie);
        if (sessionToken != null) {
          await prefs.setString('sessionToken', sessionToken);
          print('Сохранён токен: $sessionToken');
        }}

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        await prefs.setString('sessionToken', data['token']);
        final token = prefs.getString('sessionToken');
        print(token);
        return {
          'message': data['message'],
        };
      } else {
        throw Exception('Некорректный ответ от сервера');
      }
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }

  static String? _parseSessionToken(String rawCookie) {
    try {
      final parts = rawCookie.split(';');
      final sessionPart = parts
          .firstWhere((element) => element.trim().startsWith('sessionToken='));
      final token = sessionPart.split('=').last;
      return token;
    } catch (e) {
      print('Ошибка парсинга токена: $e');
      return null;
    }
  }
}

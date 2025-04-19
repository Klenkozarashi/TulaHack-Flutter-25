import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserApiService {
  static const String _baseUrl = 'http://45.155.207.23:4000/api';

  static Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load user (${response.statusCode}): ${response.body}');
    }
  }

  Future<http.Response> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final headers = {'Content-Type': 'application/json'};
    final body = user.toJson();

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }
}

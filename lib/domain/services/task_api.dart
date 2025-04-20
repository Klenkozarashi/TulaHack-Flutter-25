import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flut/domain/models/task.dart';

class TaskApi {
  TaskApi();
  static const String _baseUrl = 'http://localhost:4000/api';

  Future<ApiResponse> executeTask({
    required int subTaskId,
    required String query,
  }) async {
    final url = Uri.parse('$_baseUrl/sql/execute-task');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('sessionToken');

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'sessionToken=ee01e9db-ffce-4957-a044-3fd44de1b4db'
    };

    final body = jsonEncode({
      'subTaskId': subTaskId,
      'query': query,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        return ApiSuccessResponse.fromJson(data);
      } else {
        return ApiErrorResponse.fromJson(data);
      }
    } else {
      throw Exception('Failed to execute task: ${response.statusCode}');
    }
  }

  Future<List<Task>> getAllTasks() async {
    final url = Uri.parse('$_baseUrl/task/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Map<String, dynamic>> getTask(int id) async {
    final url = Uri.parse('$_baseUrl/task/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Не удалось загрузить задание: ${response.statusCode}');
    }
  }
}

abstract class ApiResponse {}

class ApiSuccessResponse extends ApiResponse {
  final bool success;
  final bool isCorrect;
  final List<QueryResult> userResult;
  final List<QueryResult> correctResult;
  final int executionTimeMs;

  ApiSuccessResponse({
    required this.success,
    required this.isCorrect,
    required this.userResult,
    required this.correctResult,
    required this.executionTimeMs,
  });

  factory ApiSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ApiSuccessResponse(
      success: json['success'],
      isCorrect: json['isCorrect'],
      userResult: (json['userResult'] as List)
          .map((e) => QueryResult.fromJson(e))
          .toList(),
      correctResult: (json['correctResult'] as List)
          .map((e) => QueryResult.fromJson(e))
          .toList(),
      executionTimeMs: json['executionTimeMs'],
    );
  }
}

class ApiErrorResponse extends ApiResponse {
  final bool success;
  final String error;

  ApiErrorResponse({
    required this.success,
    required this.error,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      success: json['success'],
      error: json['error'],
    );
  }
}

class QueryResult {
  final List<String> columns;
  final List<List<dynamic>> values;

  QueryResult({
    required this.columns,
    required this.values,
  });

  factory QueryResult.fromJson(Map<String, dynamic> json) {
    return QueryResult(
      columns: List<String>.from(json['columns']),
      values: (json['values'] as List)
          .map((row) => List<dynamic>.from(row))
          .toList(),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api.dart';

class SubTask {
  final int id;
  final String name;
  final String? description;
  final String solution;
  final int taskId;
  final Task task;

  SubTask({
    required this.id,
    required this.name,
    this.description,
    required this.solution,
    required this.taskId,
    required this.task,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      solution: json['solution'],
      taskId: json['taskId'],
      task: Task.fromJson(json['task']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'solution': solution,
      'taskId': taskId,
      'task': task.toJson(),
    };
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final String sqlSchema;
  final String fillData;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.sqlSchema,
    required this.fillData,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sqlSchema: json['sqlSchema'],
      fillData: json['fillData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sqlSchema': sqlSchema,
      'fillData': fillData,
    };
  }
}

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
  final String level;
  final String table;
  final List<String> columns; // изменили Array на List<String>

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.sqlSchema,
    required this.fillData,
    required this.level,
    required this.table,
    required this.columns,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sqlSchema: json['sqlSchema'],
      fillData: json['fillData'],
      level: json['level'],
      table: json['table'],
      columns: List<String>.from(json['columns']), // важно сконвертировать
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sqlSchema': sqlSchema,
      'fillData': fillData,
      'level': level,
      'table': table,
      'columns': columns,
    };
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final String sqlSchema;
  final String fillData;
  final String level;
  final String table;
  final List<String> columns;
  final List<SubTask> subTasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.sqlSchema,
    required this.fillData,
    required this.level,
    required this.table,
    required this.columns,
    required this.subTasks,
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
      columns: List<String>.from(json['columns']),
      subTasks: (json['subTask'] as List<dynamic>?)?.map((e) => SubTask.fromJson(e)).toList() ?? [],
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
      'subTask': subTasks.map((e) => e.toJson()).toList(),
    };
  }
}

class SubTask {
  final int id;
  final String name;
  final String? description;
  final String solution;

  SubTask({
    required this.id,
    required this.name,
    this.description,
    required this.solution,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      solution: json['solution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'solution': solution,
    };
  }
}
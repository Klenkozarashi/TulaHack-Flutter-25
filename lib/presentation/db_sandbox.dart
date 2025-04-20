import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flut/domain/models/task.dart';
import 'package:test_flut/domain/services/task_api.dart';
import 'package:test_flut/presentation/tasks_list.dart';
import 'dart:convert';

class SQLTrainerPage extends StatefulWidget {
  final int taskId;

  const SQLTrainerPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _SQLTrainerPageState createState() => _SQLTrainerPageState();
}

class _SQLTrainerPageState extends State<SQLTrainerPage> {
  final TextEditingController _queryController = TextEditingController();
  final TaskApi taskApi = TaskApi();

  List<SubTask> _subTasks = [];
  SubTask? _selectedSubTask;

  void _selectSubtask(int index) {
    setState(() {
      _selectedSubTask = _subTasks[index];
    });
  }

  String _currentTaskTitle = '';
  String _currentTaskDescription = '';
  List<Map<String, dynamic>> _initialTable = [];
  List<Map<String, dynamic>> _resultTable = [];

  String _currentTask = 'Выберите задание из списка ниже';
  List<Map<String, dynamic>> _table = [];
  String _currentTable = 'employees';
  bool _isLoading = false;
  bool _hasError = false;
  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _resultText = '';
    });

    try {
      final taskData = await taskApi.getTask(widget.taskId);

      final task = Task.fromJson(taskData);

      setState(() {
        _isLoading = false;
        _columns = task.columns;
        _currentTable = task.table;
        _subTasks = task.subTasks;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _resultText = 'Ошибка загрузки задания: $e';
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(39, 41, 39, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(39, 41, 39, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TaskListPage()),
            );
          },
        ),
        title: SvgPicture.asset(
          "assets/svg/SQL2-01.svg",
          height: 50,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Таблица: $_currentTable',
                    style: const TextStyle(
                        color: Color.fromRGBO(183, 88, 255, 1),
                        fontFamily: "Jost",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _columns.isEmpty
                        ? const Center(
                            child: Text('Нет данных для отображения'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: _columns
                                    .map((col) => DataColumn(
                                            label: Text(
                                          col,
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  183, 88, 255, 1)),
                                        )))
                                    .toList(),
                                rows: _table.map((row) {
                                  return DataRow(
                                    cells: _columns
                                        .map((col) => DataCell(Text(
                                            row[col]?.toString() ?? '',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1)))))
                                        .toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      ..._subTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subTask = entry.value;
                        return Column(
                          children: [
                            _buildSubtaskButton(index, subTask.name),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _queryController,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'SQL запрос',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(183, 88, 255, 1)),
                      border: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(183, 88, 255, 1), width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(183, 88, 255, 1),
                              width: 3)),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: _executeQuery,
                      ),
                    ),
                    onSubmitted: (_) => _executeQuery(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Результат:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(183, 88, 255, 1)),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(60, 62, 60, 1),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _buildResultArea(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Map<String, dynamic>> get _currentData {
    return _table;
  }

  List<String> _columns = [];

  void _executeQuery() async {
    final query = _queryController.text.trim();

    if (_selectedSubTask == null) {
      setState(() {
        _resultText = 'Выберите подзадачу перед выполнением запроса';
      });
      return;
    }

    if (query.isEmpty) {
      setState(() {
        _resultText = 'Введите SQL запрос';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    try {
      final response = await taskApi.executeTask(
        subTaskId: _selectedSubTask!.id,
        query: query,
      );

      if (response is ApiSuccessResponse) {
        final userResult = response.userResult;

        if (userResult != null && userResult.isNotEmpty) {
          final firstResult = userResult.first;
          final columns = List<String>.from(firstResult['columns']);
          final values = List<List<dynamic>>.from(firstResult['values']);

          setState(() {
            _isLoading = false;
            _columns = columns;
            _resultTable = values.map((row) {
              return Map<String, dynamic>.fromIterables(
                columns,
                row,
              );
            }).toList();
            _resultText = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _resultText = 'Нет данных для отображения';
          });
        }
      } 
      //else if (response is ApiErrorResponse) {
      //   setState(() {
      //     _isLoading = false;
      //     _resultText = response.message ?? 'Неизвестная ошибка';
      //   });
      // }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = 'Ошибка выполнения запроса: $e';
      });
    }
  }

  Widget _buildResultArea() {
    if (_resultText.isNotEmpty) {
      return SingleChildScrollView(
        child: Text(
          _resultText,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      );
    } else if (_resultTable.isNotEmpty) {
      final columns = _resultTable.first.keys.toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns
              .map((col) => DataColumn(
                    label: Text(col,
                        style: const TextStyle(
                            color: Color.fromRGBO(183, 88, 255, 1))),
                  ))
              .toList(),
          rows: _resultTable.map((row) {
            return DataRow(
              cells: columns
                  .map((col) => DataCell(
                        Text(row[col]?.toString() ?? '',
                            style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
            );
          }).toList(),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Нет результата для отображения',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildSubtaskButton(int index, String label) {
    final bool isSelected =
        _selectedSubTask != null && _subTasks[index].id == _selectedSubTask!.id;

    return ElevatedButton(
      onPressed: () => _selectSubtask(index),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color.fromRGBO(183, 88, 255, 1) : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : const Color.fromRGBO(183, 88, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color.fromRGBO(183, 88, 255, 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child:
          Text(label, style: const TextStyle(fontFamily: 'Jost', fontSize: 16)),
    );
  }
}

class ApiSuccessResponse implements ApiResponse {
  final bool success;
  final bool isCorrect;
  final List<dynamic>? userResult;
  final List<dynamic>? correctResult;
  final int? executionTimeMs;

  ApiSuccessResponse({
    required this.success,
    required this.isCorrect,
    this.userResult,
    this.correctResult,
    this.executionTimeMs,
  });

  factory ApiSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ApiSuccessResponse(
      success: json['success'],
      isCorrect: json['isCorrect'],
      userResult: json['userResult'],
      correctResult: json['correctResult'],
      executionTimeMs: json['executionTimeMs'],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flut/domain/models/task.dart';
import 'package:test_flut/domain/services/task_api.dart';
import 'package:test_flut/presentation/tasks_list.dart';

class SQLTrainerPage extends StatefulWidget {
  final int taskId;

  const SQLTrainerPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _SQLTrainerPageState createState() => _SQLTrainerPageState();
}

class _SQLTrainerPageState extends State<SQLTrainerPage> {
  final TextEditingController _queryController = TextEditingController();
  final TaskApi taskApi = TaskApi();

  int _selectedSubtaskIndex = -1;

  void _selectSubtask(int index) {
    setState(() {
      _selectedSubtaskIndex = index;
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
        _columns = task.columns;
        _currentTable = task.table;
        _isLoading = false;
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
                      _buildSubtaskButton(0, 'Вывести всех сотрудников'),
                      const SizedBox(height: 10),
                      _buildSubtaskButton(
                          1, 'Увеличить зарплату IT-сотрудников на 10%'),
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

  void _executeQuery() {
    final query = _queryController.text.trim();

    setState(() {
      if (query.isEmpty) {
        _resultText = 'Введите SQL запрос';
      } else {
        _resultText = 'Режим выполнения запроса еще не реализован.';
      }
    });
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
    final bool isSelected = _selectedSubtaskIndex == index;

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

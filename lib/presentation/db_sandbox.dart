import 'package:flutter/material.dart';

class SQLTrainerPage extends StatefulWidget {
  const SQLTrainerPage({super.key});

  @override
  _SQLTrainerPageState createState() => _SQLTrainerPageState();
}

class _SQLTrainerPageState extends State<SQLTrainerPage> {
  final TextEditingController _queryController = TextEditingController();
  String _currentTask = 'Выберите задание из списка ниже';

  List<Map<String, dynamic>> _employees = [];
  String _currentTable = 'employees';
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Тренажер'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // : _hasError || _columns.isEmpty
          //     ? Center(
          //         child: Text(
          //           _resultText.isNotEmpty ? _resultText : 'Нет данных для отображения',
          //           style: const TextStyle(color: Colors.red),
          //           textAlign: TextAlign.center,
          //         ),
          //       )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Таблица: $_currentTable',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: _columns.map((col) => DataColumn(label: Text(col))).toList(),
                            rows: _currentData.take(10).map((row) {
                              return DataRow(
                                cells: _columns.map((col) => DataCell(Text(row[col].toString()))).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _queryController,
                        decoration: InputDecoration(
                          labelText: 'SQL запрос',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: _executeQuery,
                          ),
                        ),
                        onSubmitted: (_) => _executeQuery(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Результат:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _resultText,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<Map<String, dynamic>> get _currentData {
    return _currentTable == 'employees' ? _employees : [];
  }

  List<String> get _columns {
    if (_currentData.isEmpty) return [];
    return _currentData.first.keys.toList();
  }

  String _resultText = '';

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
}

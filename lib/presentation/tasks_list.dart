import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_flut/presentation/db_sandbox.dart';
import '../domain/services/task_api.dart';
import '../domain/models/task.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Widget> _buildDifficultyDots(String level) {
    int count;
    Color color;

    switch (level) {
      case 'EASY':
        count = 1;
        color = Color.fromRGBO(77, 167, 118, 1);
        break;
      case 'MEDIUM':
        count = 2;
        color = Color.fromRGBO(245, 119, 62, 1);
        break;
      case 'HARD':
        count = 3;
        color = Color.fromRGBO(183, 88, 255, 1);
        break;
      default:
        count = 1;
        color = Colors.grey;
    }

    return List.generate(
      count,
      (index) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  late Future<List<Task>> _tasksFuture;
  late TaskApi _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskApi();
    _tasksFuture = _taskService.getAllTasks();
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'EASY':
        return Color.fromRGBO(77, 167, 118, 1);
      case 'MEDIUM':
        return Color.fromRGBO(245, 119, 62, 1);
      case 'HARD':
        return Color.fromRGBO(183, 88, 255, 1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(39, 41, 39, 1),
      appBar: AppBar(
        title: SvgPicture.asset(
          "assets/svg/SQL2-01.svg",
          height: 50,
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Заданий нет'));
          } else {
            final tasks = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Задания SQL тренажёра',
                    style: TextStyle(
                      color: Color.fromRGBO(183, 88, 255, 1),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Упражнения по SQL, приближенные  к реальным профессиональным задачам',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...tasks.map((task) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SQLTrainerPage(taskId: task.id),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _buildDifficultyDots(
                                task.level),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }
}

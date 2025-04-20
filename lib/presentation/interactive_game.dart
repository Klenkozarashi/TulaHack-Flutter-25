import 'package:flutter/material.dart';
import 'dart:math';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class DatabaseTable {
  String name;
  List<String> columns;
  Rect position;
  bool isSelected;
  String? selectedColumn;

  DatabaseTable(this.name, this.columns, this.position,
      {this.isSelected = false, this.selectedColumn});

  Offset getColumnPosition(String columnName) {
    final index = columns.indexOf(columnName);
    if (index == -1) return position.center;

    final columnHeight = position.height / (columns.length + 1);
    return Offset(
      position.right,
      position.top + (index + 1) * columnHeight,
    );
  }
}

class TableRelationship {
  DatabaseTable fromTable;
  String fromColumn;
  DatabaseTable toTable;
  String toColumn;
  bool isCorrect;

  TableRelationship(
    this.fromTable,
    this.fromColumn,
    this.toTable,
    this.toColumn,
    this.isCorrect,
  );

  Offset getStartPoint() => fromTable.getColumnPosition(fromColumn);
  Offset getEndPoint() => toTable.getColumnPosition(toColumn);
}

class DatabaseGameScreen extends StatefulWidget {
  const DatabaseGameScreen({super.key});

  @override
  State<DatabaseGameScreen> createState() => _DatabaseGameScreenState();
}

class _DatabaseGameScreenState extends State<DatabaseGameScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  List<DatabaseTable> tables = [
    DatabaseTable("Users", ["id", "name", "email"],
        const Rect.fromLTWH(50, 50, 150, 180)),
    DatabaseTable("Orders", ["id", "user_id", "product_id", "date"],
        const Rect.fromLTWH(300, 150, 150, 220)),
    DatabaseTable("Products", ["id", "name", "price"],
        const Rect.fromLTWH(550, 80, 150, 200)),
  ];

  List<TableRelationship> relationships = [];
  List<TableRelationship> correctRelationships = [
    TableRelationship(
      DatabaseTable("", [], Rect.zero),
      "user_id",
      DatabaseTable("", [], Rect.zero),
      "id",
      true,
    ),
    TableRelationship(
      DatabaseTable("", [], Rect.zero),
      "product_id",
      DatabaseTable("", [], Rect.zero),
      "id",
      true,
    ),
  ];

  TableRelationship? selectedRelationship;
  DatabaseTable? draggedTable;
  Offset? dragStartOffset;
  DatabaseTable? startTable;
  String? startColumn;
  Offset? currentArrowStart;
  Offset? currentArrowEnd;
  int score = 0;
  int attempts = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(39, 41, 39, 1),
          appBar: AppBar( backgroundColor: Color.fromRGBO(39, 41, 39, 1),
          title: Text("SQL тренажер базы данных", style: TextStyle(color: Color.fromRGBO(183, 88, 255, 1), fontFamily: "Jost", fontSize: 18),),
            actions: [
              IconButton(
            
                icon: const Icon(Icons.undo, color:  Color.fromRGBO(183, 88, 255, 1) ),
                tooltip: 'Undo last connection',
                onPressed: () {
                  if (relationships.isNotEmpty) {
                    setState(() {
                      relationships.removeLast();
                      score = max(0, score - 2);
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Score: $score',style: TextStyle(color: Color.fromRGBO(183, 88, 255, 1)), ),
                
              ),
            ],
           
          ),
    

        body: Stack(
            children: [
            
              Container(color: Colors.grey[100]),

              // Arrows (drawn behind tables)
              CustomPaint(
                painter: ArrowPainter(
                  relationships: relationships,
                  currentArrowStart: currentArrowStart,
                  currentArrowEnd: currentArrowEnd,
                ),
                size: Size.infinite,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final clickedPosition = details.globalPosition;
                  setState(() {
                    // Находим ближайшую стрелку к месту клика
                    selectedRelationship = relationships.firstWhereOrNull(
                      (rel) => _isPointNearLine(
                        clickedPosition,
                        rel.getStartPoint(),
                        rel.getEndPoint(),
                      ),
                    );
                  });
                },
                onTap: () {
                  if (selectedRelationship != null) {
                    setState(() {
                      relationships.remove(selectedRelationship);
                      selectedRelationship = null;
                      score = max(0, score - 2); // Штраф за удаление связи
                    });
                  }
                },
                child: Container(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  child: CustomPaint(
                    painter: ArrowPainter(
                      relationships: relationships,
                      currentArrowStart: currentArrowStart,
                      currentArrowEnd: currentArrowEnd,
                      selectedRelationship: selectedRelationship,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),

              // Tables
              ...tables.map((table) {
                
                return Positioned(
                  left: table.position.left,
                  top: table.position.top,
                  child: DatabaseTableWidget(
                       table: table,
                  
                       
                 
                    
                    onDragStart: (details) {
                      setState(() {
                        draggedTable = table;
                        dragStartOffset = details.globalPosition;
                      });
                    },
                    onDragUpdate: (details) {
                      setState(() {
                        if (draggedTable != null) {
                          final delta =
                              details.globalPosition - dragStartOffset!;
                          draggedTable!.position =
                              draggedTable!.position.shift(delta);
                          dragStartOffset = details.globalPosition;
                        }
                      });
                    },
                    onDragEnd: (details) {
                      setState(() {
                        draggedTable = null;
                      });
                    },
                    onColumnSelected: (column) {
                      setState(() {
                        if (startTable == null) {
                          // Первый выбор
                          startTable = table;
                          startColumn = column;
                          currentArrowStart = table.getColumnPosition(column);
                        } else {
                          // Второй выбор - создаем связь
                          final endTable = table;
                          final endColumn = column;

                          // Проверяем, не существует ли уже такая связь
                          if (!_relationshipExists(
                              startTable!, startColumn!, endTable, endColumn)) {
                            currentArrowEnd = table.getColumnPosition(column);

                            // Проверяем правильность связи
                            final isCorrect = correctRelationships.any((rel) =>
                                (rel.fromColumn == startColumn &&
                                    rel.toColumn == endColumn) ||
                                (rel.fromColumn == endColumn &&
                                    rel.toColumn == startColumn));

                            if (isCorrect) {
                              score += 10;
                            } else {
                              score = max(0, score - 5);
                            }
                            attempts++;

                            relationships.add(TableRelationship(
                              startTable!,
                              startColumn!,
                              endTable,
                              endColumn,
                              isCorrect,
                            ));
                          } else {
                            // Показываем сообщение о существующей связи
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Эта связь уже существует!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }

                          // Сбрасываем выбор
                          startTable = null;
                          startColumn = null;
                          currentArrowStart = null;
                          currentArrowEnd = null;
                        }
                      });
                    },
                  ),
                );
              }).toList(),

              // Instructions
             
            ],
          ),
        )
      );
  }

  void _showErrorMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _relationshipExists(DatabaseTable fromTable, String fromColumn,
      DatabaseTable toTable, String toColumn) {
    return relationships.any((rel) =>
        (rel.fromTable == fromTable &&
            rel.fromColumn == fromColumn &&
            rel.toTable == toTable &&
            rel.toColumn == toColumn) ||
        (rel.fromTable == toTable &&
            rel.fromColumn == toColumn &&
            rel.toTable == fromTable &&
            rel.toColumn == fromColumn));
  }
}

class DatabaseTableWidget extends StatelessWidget {
  final DatabaseTable table;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final Function(String) onColumnSelected;

  const DatabaseTableWidget({
    super.key,
    required this.table,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onColumnSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      onPanEnd: onDragEnd,
      child: Container(
        width: table.position.width,
        height: table.position.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: table.isSelected ? Color.fromRGBO(183, 88, 255, 1) : const Color.fromARGB(255, 255, 255, 255),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(183, 88, 255, 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              child: Text(
                table.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Columns
            ...table.columns.map((column) {
              return GestureDetector(
                onTap: () => onColumnSelected(column),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: table.selectedColumn == column
                        ?Color.fromRGBO(183, 88, 255, 1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: Text(column),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final List<TableRelationship> relationships;
  final Offset? currentArrowStart;
  final Offset? currentArrowEnd;
  final TableRelationship? selectedRelationship;

  ArrowPainter({
    required this.relationships,
    this.currentArrowStart,
    this.currentArrowEnd,
    this.selectedRelationship,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final rel in relationships) {
      // Выделяем выбранную стрелку
      if (rel == selectedRelationship) {
        paint.color = Colors.orange;
        paint.strokeWidth = 4;
      } else {
        paint.color = rel.isCorrect ? const Color.fromARGB(255, 175, 194, 176) : const Color.fromARGB(255, 212, 142, 137);
        paint.strokeWidth = 2;
      }

      final start = rel.getStartPoint();
      final end = rel.getEndPoint();

      canvas.drawLine(start, end, paint);
      drawArrowhead(canvas, start, end, paint);
    }

    if (currentArrowStart != null && currentArrowEnd != null) {
      paint.color = Colors.blue.withOpacity(0.5);
      paint.strokeWidth = 3;
      canvas.drawLine(currentArrowStart!, currentArrowEnd!, paint);
      drawArrowhead(canvas, currentArrowStart!, currentArrowEnd!, paint);
    }
  }

  void drawArrowhead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowSize = 10.0;

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * cos(angle - pi / 6),
        end.dy - arrowSize * sin(angle - pi / 6),
      )
      ..lineTo(
        end.dx - arrowSize * cos(angle + pi / 6),
        end.dy - arrowSize * sin(angle + pi / 6),
      )
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

bool _isPointNearLine(Offset point, Offset lineStart, Offset lineEnd) {
  const tolerance = 15.0;

  // Упрощённая проверка расстояния от точки до отрезка
  final lineLength = (lineEnd - lineStart).distance;
  final lineVector = (lineEnd - lineStart) / lineLength;

  final pointVector = point - lineStart;
  final projection =
      pointVector.dx * lineVector.dx + pointVector.dy * lineVector.dy;

  if (projection < 0 || projection > lineLength) {
    return false;
  }

  final perpendicularDistance =
      (pointVector.dy * lineVector.dx - pointVector.dx * lineVector.dy).abs();
  return perpendicularDistance < tolerance;
}

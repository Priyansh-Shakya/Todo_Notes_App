import 'package:todo_notes/Data/Models/todoModel.dart';

class TodoEntity {
  final int? id;

  final String task;
  final bool isComplete;
  final String? createdAt;

  TodoEntity({
    this.id,

    required this.task,
    required this.isComplete,
    this.createdAt,
  });

  TodoModel toTodoModel() {
    return TodoModel(task: task, isComplete: isComplete, createdAt: createdAt);
  }

  
  TodoEntity copyWith({
    int? id,

    String? task,
    bool? isComplete,
    String? createdAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,

      task: task ?? this.task,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


import 'package:todo_notes/Data/Models/notiModel.dart';
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

class TodoReadEntity {
  final int? id;

  final String task;
  final bool isComplete;
  final String createdAt;

  final List<NotificationModel> notification;

  TodoReadEntity({
    this.id,
    required this.task,
    required this.createdAt,
    required this.isComplete,
    required this.notification,
  });

  TodoReadModel toTodoReadModel() {
    return TodoReadModel(
      id: id,
      task: task,
      isComplete: isComplete,
      createdAt: createdAt,
      notifications: notification,
    );
  }

  TodoReadEntity copyWith({
    int? id,

    String? task,
    bool? isComplete,
    String? createdAt,
    List<NotificationModel>? notification,
  }) {
    return TodoReadEntity(
      id: id ?? this.id,

      task: task ?? this.task,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      notification: notification ?? this.notification,
    );
  }
}

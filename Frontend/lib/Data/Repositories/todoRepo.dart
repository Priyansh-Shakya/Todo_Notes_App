import 'package:todo_notes/Data/DataSources/RemoteSources/notificationService.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/todoApiService.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Data/Models/todoModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';

class TodoRepo {
  final TodoService api;
  final Notificationservice notification;
  TodoRepo({required this.api, required this.notification});

  Future<List<TodoEntity>> getAll() async {
    // Add local OR remote logic above
    final model = await api.getAllTodos();
    return model.map((e) => e.toTodoEntity()).toList();
  }

  Future<TodoEntity> writeT({
    required TodoModel todo,
    NotificationModel? noti,
  }) async {
    final model = await api.createTodo(todo: todo);
    if (noti != null) {
      await notification.sendTaskNotification(noti, model.id!);
    }
    return model.toTodoEntity();
  }

  Future<TodoEntity> updateT({required TodoModel todo, required int id}) async {
    final model = await api.updateTodo(todo: todo, id: id);
    return model.toTodoEntity();
  }

  Future<void> deleteT({required int id}) async {
    return await api.deleteTodo(id: id);
  }
}

import 'package:todo_notes/Data/DataSources/RemoteSources/todoApiService.dart';
import 'package:todo_notes/Data/Models/todoModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';

class TodoRepo {
  final TodoService api;
  TodoRepo({required this.api});

  Future<List<TodoEntity>> getAll() async {
    // Add local OR remote logic above
    final model = await api.getAllTodos();
    return model.map((e) => e.toTodoEntity()).toList();
  }

  Future<TodoEntity> writeT({required TodoModel todo}) async {
    final model = await api.createTodo(todo: todo);
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

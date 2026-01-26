import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_notes/Data/Models/todoModel.dart';

class TodoService {
  final Dio dio;
  TodoService({required this.dio});

  //Helper
  Exception handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception("Request Timeout");
    } else if (e.response != null) {
      return Exception(
        "Server error: ${e.response?.statusCode} ${e.response?.data}",
      );
    } else {
      return Exception("Network Error: ${e.message}");
    }
  }

  //get All Todos
  Future<List<TodoModel>> getAllTodos() async {
    try {
      final response = await dio.get('/readtodos');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          

          return data
              .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Invalid list JSON');
        }
      } else {
        throw Exception('Failed to fetch items: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  //create todo
  Future<TodoModel> createTodo({required TodoModel todo}) async {
    try {
      final response = await dio.post('/writetodo', data: todo.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TodoModel.fromJson(Map<String, dynamic>.from(response.data));
      } else {
        throw Exception("Failed to create todo : ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<TodoModel> updateTodo({
    required TodoModel todo,
    required int id,
  }) async {
    try {
      final response = await dio.put('/updatetodo/$id', data: todo.toJson());
      // More robust way to check for success
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return TodoModel.fromJson(Map<String, dynamic>.from(response.data));
      } else {
        throw Exception("Failed to update todo: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> deleteTodo({required int id}) async {
    try {
      final response = await dio.delete('/deletetodo/$id');
      if (response.statusCode == 200 || response.statusCode == 204) return;
      throw Exception("Failed to delete todo: ${response.statusCode}");
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

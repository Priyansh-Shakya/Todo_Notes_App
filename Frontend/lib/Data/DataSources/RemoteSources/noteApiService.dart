import 'package:dio/dio.dart';
import 'package:todo_notes/Data/Models/notesModel.dart';

class NoteService {
  final Dio dio;
  NoteService({required this.dio});

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

  Future<List<NoteModel>> readAllNotes() async {
    try {
      final response = await dio.get('/readnotes');
      if (response.statusCode == 200) {
        final data = response.data;
        for (var n in data) {
          print(
            '${n['id']} - pinned: ${n['pinned']} - createdAt: ${n['createdAt']}',
          );
        }

        if (data is List) {
          return data
              .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception("Invalid list json");
        }
      } else {
        throw Exception("Failed to get notes: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<NoteModel> writeNote({required NoteModel note}) async {
    try {
      final res = await dio.post('/writenote', data: note.toJson());
      print(">>> response status: ${res.statusCode}, data: ${res.data}");
      if (res.statusCode == 200 || res.statusCode == 201) {
        return NoteModel.fromJson(Map<String, dynamic>.from(res.data));
      } else {
        throw Exception("Failed to write note: ${res.statusCode}");
      }
    } on DioException catch (e) {
      print(">>> dio error: ${e.response?.statusCode} ${e.response?.data}");
      throw handleDioError(e);
    }
  }

  Future<NoteModel> updateNote({
    required NoteModel note,
    required int id,
  }) async {
    try {
      final res = await dio.put('/updatenote/$id', data: note.toJson());
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return NoteModel.fromJson(Map<String, dynamic>.from(res.data));
      } else {
        throw Exception("Failed to update note: ${res.statusCode}");
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> deleteNote({required List<int> ids}) async {
    try {
      final res = await dio.delete(
        '/deletenotes',
        queryParameters: {'ids': ids},
      );
      if (res.statusCode == 200 || res.statusCode == 204) return;
      throw Exception("Failed to delete note: ${res.statusCode}");
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

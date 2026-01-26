import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';

class Notificationservice {
  final Dio dio;
  Notificationservice({required this.dio});

  Future<NotificationModel> sendTaskNotification(
    NotificationModel noti,
    int taskId,
  ) async {
    final payload = noti.copyWith(taskId: taskId);
    final response = await dio.post('/setnoti', data: payload.toJson());
    debugPrint('Notification Sent: ${noti.toJson()}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return NotificationModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } else {
      throw Exception('Failed to send notification: ${response.statusCode}');
    }
  }

  Future<List<NotificationModel>> getTaskNotification() async {
    final response = await dio.get('/getnoti');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid list JSON');
      }
    } else {
      throw Exception('Failed to get notification: ${response.statusCode}');
    }
  }
}

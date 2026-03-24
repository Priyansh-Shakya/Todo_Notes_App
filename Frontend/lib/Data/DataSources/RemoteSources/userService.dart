import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_notes/Data/Models/userModel.dart';

class UserService {
  final Dio dio;

  UserService({required this.dio});

  Future<UserModel> createUser({required UserModel user}) async {
    debugPrint("User Model From Service Layer:");
    debugPrint(user.email);
    debugPrint(user.userId);
    debugPrint(user.fcmDeviceToken);
    debugPrint(user.accCreatedAt);
    try {
      final response = await dio.post('/createuser', data: user.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(Map<String, dynamic>.from(response.data));
      } else {
        throw Exception("Failed to create user");
      }
    } catch (e) {
      throw Exception("Some Error Occured: $e");
    }
  }

  Future<UserModel> updateUser({
    required UserModel user,
    required String user_id,
  }) async {
    try {
      final response = await dio.put(
        '/updateuser/$user_id',
        data: user.toJson(),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return UserModel.fromJson(Map<String, dynamic>.from(response.data));
      } else {
        throw Exception("Failed to update user");
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}

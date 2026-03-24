import 'package:flutter/foundation.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/userService.dart';
import 'package:todo_notes/Domain/Entities/userEntity.dart';

class UserRepo {
  UserService api;
  UserRepo({required this.api});

  Future<void> createUser({required UserEntity user}) async {
    user.createdAt = DateTime.now().toString();
    final dto = user.toUserModel();
    debugPrint("Token from repo from User MODEL: ${dto.fcmDeviceToken}");
    await api.createUser(user: dto);
  }

  Future<void> updateUser({
    required UserEntity user,
    required String id,
  }) async {
    final dto = user.toUserModel();
    await api.updateUser(user: dto, user_id: id);
  }
}

import 'package:todo_notes/Data/Models/userModel.dart';

class UserEntity {
  String? uId;
  String? email;
  String? fcmToken;
  String? createdAt;

  UserEntity({
    required this.uId,
    required this.email,
    required this.fcmToken,
   
  });

  UserModel toUserModel() {
    return UserModel(
      userId: uId,
      email: email,
      fcmDeviceToken: fcmToken,
      accCreatedAt: createdAt,
      
    );
  }
}

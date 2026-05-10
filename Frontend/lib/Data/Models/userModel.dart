import 'package:todo_notes/Domain/Entities/userEntity.dart';

class UserModel {
  String? userId;
  String? email;
  String? fcmDeviceToken;
  String? accCreatedAt;
  
  UserModel({this.userId, this.email, this.fcmDeviceToken, this.accCreatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    fcmDeviceToken = json['fcm_device_token'];
    accCreatedAt = json['acc_created_at'];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['email'] = this.email;
    data['fcm_device_token'] = this.fcmDeviceToken;
    data['acc_created_at'] = this.accCreatedAt;
    
    return data;
  }

  UserEntity toUserEntity() {
    return UserEntity(uId: userId, email: email, fcmToken: fcmDeviceToken);
  }
}

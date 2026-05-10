import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Core/Fcm_Service/tokenProvider.dart';
import 'package:todo_notes/Domain/Entities/userEntity.dart';
import 'package:todo_notes/Presentation/Providers/userProvider.dart';

final userNotifierProvider = AsyncNotifierProvider<UserNotifier, void>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No need to return anything, we just want to trigger a rebuild when the user changes
    return;
  }

  Future<void> createUser() async {
    debugPrint("Create User called");

    User? user;

    // Wait until Supabase gives user

    user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint("User still null after waiting");
      return;
    }

    debugPrint("Signed in as: ${user.email}");

    final repo = ref.read(userRepoProvider);

    // Getfcm token
    final token = ref.read(fcmTokenProvider);
    debugPrint(
      "-------------------------------- FCM token from notifier: $token",
    );
    final userEntity = UserEntity(
      uId: user.id,
      email: user.email,
      fcmToken: token,
    );

    await repo.createUser(user: userEntity);
  }

  Future<void> updateFcmToken({required String token}) async {
    User? user;

    // Wait until Supabase gives user

    user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint("User still null after waiting");
      return;
    }
    final id = user.id;
    debugPrint("Signed in as: ${user.email}");

    final repo = ref.read(userRepoProvider);

    debugPrint(
      "-------------------------------- FCM token from notifier: $token",
    );
    final userEntity = UserEntity(
      uId: user.id,
      email: user.email,
      fcmToken: token,
    );

    await repo.updateUser(id: id, user: userEntity);
  }

  Future<void> updateNotificationTone(String tone) async {
    User? user = Supabase.instance.client.auth.currentUser;
    final repo = ref.read(userRepoProvider);
    if (user == null) {
      throw Exception('User not logged in');
    }
    return await repo.updateNotificationTone(tone, user.id);
  }

  Future<void> updateUserInfo(String userInfo) async {
    User? user = Supabase.instance.client.auth.currentUser;
    final repo = ref.read(userRepoProvider);
    if (user == null) {
      throw Exception('User not logged in');
    }
    return await repo.updateUserInfo(userInfo, user.id);
  }
}

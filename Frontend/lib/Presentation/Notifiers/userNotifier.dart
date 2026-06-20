import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Core/Fcm_Service/tokenProvider.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Domain/Entities/userEntity.dart';
import 'package:todo_notes/Presentation/Providers/userProvider.dart';

final userNotifierProvider = AsyncNotifierProvider<UserNotifier, String>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    // Return cached userInfo for the currently signed-in user (device fallback when no user)
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;
    final info = await getUserInfo(userId: userId);
    debugPrint("From Notifier build -------------- $info (userId=$userId)");
    return info;
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

    // update locally in pref (user-scoped if logged in)
    await setNotificationTone(tone, userId: user?.id);
    if (user == null) {
      throw Exception('User not logged in');
    }
    return await repo.updateNotificationTone(tone, user.id);
  }

  Future<void> updateUserInfo(String userInfo) async {
    User? user = Supabase.instance.client.auth.currentUser;
    final repo = ref.read(userRepoProvider);
    // update locally in pref (user-scoped if logged in)
    await setUserInfo(userInfo, userId: user?.id);
    if (user == null) {
      throw Exception('User not logged in');
    }
    return await repo.updateUserInfo(userInfo, user.id);
  }

  Future<String> notificationTone() async {
    final user = Supabase.instance.client.auth.currentUser;
    final tone = await getNotificationTone(userId: user?.id);
    return tone;
  }

  Future<String> userInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    final info = await getUserInfo(userId: user?.id);
    return info;
  }

  Future<void> fetchUserPersonalization() async {
    try {
      final userServiceProvider_ = ref.read(userServiceProvider);
      final data = await userServiceProvider_.getUserPersonalization();

      final userInfo = data['userInfo'] ?? '{}';
      final notificationTone = data['notificationTone'] ?? 'funny';

      debugPrint(
        "From notifier - Fetched user personalization: userInfo: $userInfo, notificationTone: $notificationTone",
      );
      // Store in SharedPrefs using current user id (device fallback if not signed in)
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;
      await setUserInfo(userInfo, userId: userId);
      await setNotificationTone(notificationTone, userId: userId);

      state = AsyncValue.data(userInfo);

      debugPrint("✅ User personalization fetched and cached");
    } catch (e) {
      debugPrint("❌ Error fetching user personalization: $e");
    }
  }
}

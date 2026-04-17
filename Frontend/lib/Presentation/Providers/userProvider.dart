import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/userService.dart';
import 'package:todo_notes/Data/Repositories/userRepo.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';
import 'package:todo_notes/Presentation/Providers/authProvider.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio: dio);
});

final userRepoProvider = Provider<UserRepo>((ref) {
  final api = ref.watch(userServiceProvider);
  return UserRepo(api: api);
});

// Sends a create user api whenever auth state changes.
final authListenerProvider = Provider<void>((ref) {
  final authRepo = ref.read(authRepoProvider);

  authRepo.getAuthState().listen((data) async {
    final session = data.session;

    if (session != null) {
      final user = session.user;

      debugPrint("🔥 Signed in: ${user.email}");

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await ref
            .read(userNotifierProvider.notifier)
            .updateFcmToken(token: token);

        debugPrint(
          "✅ --------------------------------------------------- Token synced after login: $token",
        );
      }
    }
  });
});

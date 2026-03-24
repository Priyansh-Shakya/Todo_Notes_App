import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/userService.dart';
import 'package:todo_notes/Data/Repositories/userRepo.dart';
import 'package:todo_notes/Presentation/Providers/authProvider.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';

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
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;

      debugPrint("🔥 GLOBAL LISTENER: Signed in as ${user.email}");
      
      await ref.read(userNotifierProvider.notifier).createUser();
    }
  });
});

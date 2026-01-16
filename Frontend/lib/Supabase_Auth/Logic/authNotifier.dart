import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Supabase_Auth/Logic/abstractRepo.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

class AuthNotifier extends AsyncNotifier<Session?> {
  late final AuthenticationRepo repo;
  StreamSubscription<AuthState>? sub;

  @override
  Future<Session?> build() async {
    repo = ref.read(authRepoProvider); // initialize once
    final completer = Completer<Session?>();

    sub = repo.getAuthState().listen((authState) async {
      final session = authState.session;

      // 🔑 Refresh token if needed
      Session? refreshedSession = session;
      if (session != null &&
          session.expiresAt != null &&
          DateTime.now().isAfter(
            DateTime.fromMillisecondsSinceEpoch(
              session.expiresAt! * 1000,
            ).subtract(const Duration(minutes: 2)),
          )) {
        refreshedSession =
            (await Supabase.instance.client.auth.refreshSession()).session;
      }

      // ✅ Update state with latest session
      state = AsyncValue.data(refreshedSession);

      // ✅ Refresh dependent data providers
      ref.read(todoNotifierProvider.notifier).refreshList();
      ref.read(noteNotifierProvider.notifier).refreshList();
      debugPrint("♻️ Data providers refreshed due to auth state change.");

      // Complete the future for build() only once
      if (!completer.isCompleted) {
        completer.complete(refreshedSession);
      }
    });

    ref.onDispose(() => sub?.cancel());
    return completer.future;
  }

  Future<void> signUpWithEmail(AuthData data) async {
    state = const AsyncLoading();
    await repo.signUpWithEmail(data);
  }

  Future<void> signInWithEmail(AuthData data) async {
    state = const AsyncLoading();
    await repo.signInWithEmail(data);
  }

  Future<void> signInWithGoogle() async {
    await repo.signInWithGoogle();
  }

  Future<void> signOut() async {
    await repo.signOut();
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Supabase_Auth/Logic/abstractRepo.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

class AuthNotifier extends AsyncNotifier<Session?> {
  late final AuthenticationRepo repo;
  StreamSubscription<AuthState>? sub;

  String? formError;

  @override
  Future<Session?> build() async {
    repo = ref.read(authRepoProvider);

    sub = repo.getAuthState().listen((authState) {
      state = AsyncValue.data(authState.session);
    });

    ref.onDispose(() => sub?.cancel());

    return repo.currentSession;
  }

  Future<void> signUpWithEmail(AuthData data) async {
    state = const AsyncLoading();
    formError = null;

    try {
      await repo.signUpWithEmail(data);
    } on AuthException catch (e) {
      // 👇 THIS is the key
      formError = e.message;
      state = const AsyncData(null); // ⬅️ DO NOT use AsyncError
    } catch (e) {
      // truly fatal errors only
      formError = e.toString();
      state = AsyncData(null);
    }
  }

  Future<void> signInWithEmail(AuthData data) async {
    state = const AsyncLoading();
    formError = null;

    try {
      await repo.signInWithEmail(data);
    } on AuthException catch (e) {
      // 👇 THIS is the key
      formError = e.message;
      state = const AsyncData(null); // ⬅️ DO NOT use AsyncError
    } catch (e) {
      // truly fatal errors only
      formError = e.toString();
      state = AsyncData(null);
    }
  }

  Future<void> signInWithGoogle() async {
    await repo.signInWithGoogle();
  }

  Future<void> signOut() async {
    await repo.signOut();
    // listener will emit null session
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Supabase_Auth/Logic/abstractRepo.dart';

class AuthRepo implements AuthenticationRepo {
  final SupabaseClient client;
  AuthRepo({SupabaseClient? cli}) : client = cli ?? Supabase.instance.client;
  @override
  Future<User?> signUpWithEmail(AuthData data) async {
    try {
      final res = await client.auth.signUp(
        email: data.email,
        password: data.pass,
      );
      return res.user;
    } catch (_) {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<User?> signInWithEmail(AuthData data) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: data.email,
        password: data.pass,
      );
      return res.user;
    } catch (_) {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.example.todo_notes://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  Stream<AuthState> getAuthState() {
    return client.auth.onAuthStateChange;
  }

  @override
  Stream<Session?> get currentSession =>
      Supabase.instance.client.auth.onAuthStateChange
          .map((event) => event.session);
}

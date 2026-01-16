import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Supabase_Auth/Logic/abstractRepo.dart';

class AuthRepo implements AuthenticationRepo {
  final SupabaseClient client;
  AuthRepo({SupabaseClient? cli}) : client = cli ?? Supabase.instance.client;
  @override
  Future<User?> signUpWithEmail(AuthData data) async {
    final res = await client.auth.signUp(
      password: data.pass,
      email: data.email,
    );
    return res.user;
  }

  @override
  Future<User?> signInWithEmail(AuthData data) async {
    final res = await client.auth.signInWithPassword(
      password: data.pass,
      email: data.email,
    );
    return res.user;
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
  Session? get currentSession => client.auth.currentSession;
}

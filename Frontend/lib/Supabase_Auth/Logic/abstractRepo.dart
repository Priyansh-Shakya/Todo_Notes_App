import 'package:supabase_flutter/supabase_flutter.dart';

typedef AuthData = ({String email, String pass});

abstract class AuthenticationRepo {
  Future<User?> signUpWithEmail(AuthData data);
  Future<User?> signInWithEmail(AuthData data);
  Future<void> signInWithGoogle();
  Future<void> signOut();

  Stream<AuthState> getAuthState();

  Stream<Session?> get currentSession;
}

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Supabase_Auth/Logic/abstractRepo.dart';

class MockAuthRepo implements AuthenticationRepo {
  final _controller = StreamController<AuthState>.broadcast();

  final Map<String, String> _users = {}; // email → password
  Session? _session;

  @override
  Session? get currentSession => _session;

  // -------------------------------
  // Auth State Stream
  // -------------------------------
  @override
  Stream<AuthState> getAuthState() => _controller.stream;

  // -------------------------------
  // Email Sign Up
  // -------------------------------
  @override
  Future<User?> signUpWithEmail(AuthData data) async {
    if (_users.containsKey(data.email)) {
      throw AuthException('User already exists');
    }

    _users[data.email] = data.pass;

    _session = _createSession(data.email);

    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));

    return _session!.user;
  }

  // -------------------------------
  // Email Sign In
  // -------------------------------
  @override
  Future<User?> signInWithEmail(AuthData data) async {
    if (!_users.containsKey(data.email)) {
      throw AuthException('User not found');
    }

    if (_users[data.email] != data.pass) {
      throw AuthException('Invalid password');
    }

    _session = _createSession(data.email);

    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));

    return _session!.user;
  }

  // -------------------------------
  // Google Sign In (Simulated)
  // -------------------------------
  @override
  Future<void> signInWithGoogle() async {
    const email = 'google_user@test.com';

    _users.putIfAbsent(email, () => 'google-auth');

    _session = _createSession(email);

    _controller.add(AuthState(AuthChangeEvent.signedIn, _session));
  }

  // -------------------------------
  // Sign Out
  // -------------------------------
  @override
  Future<void> signOut() async {
    _session = null;

    _controller.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  // -------------------------------
  // Helpers
  // -------------------------------
  Session _createSession(String email) {
    return Session(
      accessToken: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      tokenType: 'bearer',
      user: User(
        id: email.hashCode.toString(),
        email: email,
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        appMetadata: {},
        userMetadata: {},
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}

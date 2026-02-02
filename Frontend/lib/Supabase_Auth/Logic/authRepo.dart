import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  Future<AuthResponse> signInWithGoogle() async {
    
    // get web clientId per project/App
    const webClientId =
        '270376679264-uman5onorrigndsvk4ifssss9nm19kch.apps.googleusercontent.com';

    final GoogleSignIn signIn = GoogleSignIn.instance;

    // At the start of your app, initialize the GoogleSignIn instance
    unawaited(signIn.initialize(serverClientId: webClientId));

    // Perform the sign in
    final googleAccount = await signIn.authenticate();
    final googleAuthorization = await googleAccount.authorizationClient
        .authorizationForScopes(['email', 'profile']);

    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    final accessToken = googleAuthorization?.accessToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }
    debugPrint('Google ID Token: $idToken');
    debugPrint('Google Access Token: $accessToken');

    return client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
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
  Stream<Session?> get currentSession => Supabase
      .instance
      .client
      .auth
      .onAuthStateChange
      .map((event) => event.session);
}

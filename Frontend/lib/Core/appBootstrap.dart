import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const AppInitializer({required this.child, super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint("⚠️ ---------------------------------------------------- User not logged in yet, skipping token send -------------------------");
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      debugPrint("🔥--------------------------------------------------- Sending token: $token");

      await ref
          .read(userNotifierProvider.notifier)
          .updateFcmToken(token: token);
      debugPrint("-------------------------------------------------------------------Token sent to backend: $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

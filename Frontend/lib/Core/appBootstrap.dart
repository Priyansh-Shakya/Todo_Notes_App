import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Core/Connectivity/checkInternet.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';

//! Global key for scaffold messenger
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final navigatorKey = GlobalKey<NavigatorState>();

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
    _init().catchError((e, st) => debugPrint('AppInitializer error: $e'));
  }

  Future<void> _init() async {
    // checking internet connection
    await Future.delayed(
      const Duration(seconds: 2),
    ); //? To get proper connection status after app launch
    final bool isConn = await checkInternetConnection();
    debugPrint("Checking internet connection...$isConn");

    if (!isConn) {
      // ignore: use_build_context_synchronously
      showRefreshNoInternetBanner();
    }

    //? Adding android notification high importance setup

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      debugPrint(
        "⚠️ ---------------------------------------------------- User not logged in yet, skipping token send -------------------------",
      );
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      debugPrint(
        "🔥--------------------------------------------------- Sending token: $token",
      );

      await ref
          .read(userNotifierProvider.notifier)
          .updateFcmToken(token: token);
      debugPrint(
        "-------------------------------------------------------------------Token sent to backend: $token",
      );
    }

    final info = await getUserInfo();
    debugPrint(
      " ========================================= User Info from init: $info",
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Widget showUserInfoAddBanner({
  required BuildContext context,
  VoidCallback? onDontShowAgain,
}) {
  return AlertDialog(
    title: Text(
      'Personalize Your Notifications',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    content: Text(
      'Add a short description about yourself in the Personalization section of Settings. '
      'This helps us provide more personalized notifications.'
      'The more context you provide, the better we can customize your experience.',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    actions: [
      TextButton(
        onPressed: () {
          onDontShowAgain?.call();
          Navigator.of(context).pop();
        },
        child: const Text("Don't show again"),
      ),
      FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('OK'),
      ),
    ],
  );
}

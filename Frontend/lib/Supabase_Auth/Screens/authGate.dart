import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Presentation/Screens/mainScreen_bottomBar.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

import 'authScreen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: authState.when(
        data: (session) {
          if (session == null) {
            return const AuthScreen();
          } else {
            return const MainScreen();
          }
        },
        loading: () => const ShimmerLoadingWidget(),
        error: (e, _) => Center(child: Text('Auth error: $e')),
      ),
    );
  }
}

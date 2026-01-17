import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppTheme/appTheme.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Supabase_Auth/Helpers/initilizeSupabase.dart';
import 'package:todo_notes/Supabase_Auth/Screens/authGate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSupabase();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode: ref.watch(themeProvider),
      // A widget which will be started on application startup
      home: AuthGate(),
    );
  }
}

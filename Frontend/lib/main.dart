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
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Application name
      title: 'Flutter Hello World',
      // Application theme data, you can set the colors for the application as
      // you want
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme,
      // A widget which will be started on application startup
      home: const AuthGate(),
    );
  }
}

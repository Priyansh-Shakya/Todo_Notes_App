import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';
import 'package:todo_notes/Supabase_Auth/Screens/authScreen.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                // color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dark Mode",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Switch(
                      activeThumbColor: Colors.green,
                      value: isDark,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          OutlinedButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text("Log-Out", style: TextStyle(color: Colors.red)),
          ),
          SizedBox(height: 50),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            child: Text("Sign-in/up", style: TextStyle(color: Colors.red)),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

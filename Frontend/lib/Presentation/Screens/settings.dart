import 'package:dio/dio.dart';
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
                color: Theme.of(context).cardColor,
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
          OutlinedButton(
            onPressed: () async {
              final token =
                  "eyJhbGciOiJIUzI1NiIsImtpZCI6Ildqd1MzOVJGSUVBZGNWVGkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NkcnluZXZ1ZHR6cXZsaGttZG9oLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI3NGViMWRmMC01YjA3LTQ1NTAtYTE5ZS04ODE3NTBjYTNlMDYiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzY3ODg1MjY0LCJpYXQiOjE3Njc4ODE2NjQsImVtYWlsIjoiZXh0cmFwdXJwb3NlNDNAZ21haWwuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwidXNlcl9tZXRhZGF0YSI6eyJlbWFpbCI6ImV4dHJhcHVycG9zZTQzQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaG9uZV92ZXJpZmllZCI6ZmFsc2UsInN1YiI6Ijc0ZWIxZGYwLTViMDctNDU1MC1hMTllLTg4MTc1MGNhM2UwNiJ9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNzY3ODgxNjY0fV0sInNlc3Npb25faWQiOiJlMmIyNjUyMC0xY2YxLTRjYzMtODcwOC1lMjJmZGRkNDRmNGYiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.6Aps2mbTzAVVUyiMGNyBV_L58sc9WjNVjXy7W3y35uU";
              Dio dio = Dio();
              dio.options.headers["authorization"] = "Bearer $token";
              final response = await dio.get('http://127.0.0.1:8000/me');
              if (response.statusCode == 200) {
                final data = response.data;
                final user = data['user'];
                print(user['email']);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Request Successful')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Request Un-Successful')),
                );
              }
            },
            child: Text("Test request", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

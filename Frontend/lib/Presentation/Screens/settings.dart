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
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─────────────────── Appearance ───────────────────
          _SettingsCard(
            child: ListTile(
              title: Text(
                "Dark Mode",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: Switch(
                value: isDark,
                focusColor: Colors.green,
                inactiveThumbColor: Colors.red,
                activeTrackColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow,
                activeThumbColor: Colors.green,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────── Account ───────────────────
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(
                    user?.email ?? "Not signed in",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                if (user != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Log out",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      ref.read(authNotifierProvider.notifier).signOut();
                      ref.read(googleAuthLoadingProvider.notifier).state =
                          false;
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────── Auth Action ───────────────────
          if (user == null)
            _SettingsCard(
              child: ListTile(
                leading: const Icon(Icons.login, color: Colors.red),
                title: const Text(
                  "Sign in / Sign up",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'About notification tones',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => showInfoPannel(context),
                      );
                    },
                  ),
                ),

                const Divider(),

                // Placeholder for future tone/mood options
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Notification tone'),
                    subtitle: const Text('Default'),
                    onTap: () {
                      // Open bottom sheet / picker later
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// Reusable settings card
class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

Widget showInfoPannel(BuildContext context) {
  return AlertDialog(
    title: const Text('Notification tone & mood'),
    content: const Text(
      'Choose the tone or mood you want for notifications.\n\n'
      'This will be used as the default for all notifications. '
      'You can override it for individual tasks from the task details screen.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Got it'),
      ),
    ],
  );
}

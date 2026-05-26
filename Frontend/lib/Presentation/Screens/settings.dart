import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Core/permissions.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';
import 'package:todo_notes/Supabase_Auth/Screens/authScreen.dart';

// Add this provider somewhere appropriate
final notificationToneProvider = StateProvider<String>((ref) => 'Funny');

class Settings extends ConsumerWidget {
  Settings({super.key});

  final controller = TextEditingController(); //! User info controler

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(notificationPermissionProvider);

    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final user = ref.watch(userProvider);

    bool isEditing = false; //! for enabling textfield of user info

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

          //? notification enable
          // ─────────────────── Notifications ───────────────────
          _SettingsCard(
            child: ListTile(
              title: Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: permissionAsync.when(
                // Data loaded state: Show the switch based on permission status
                data: (status) {
                  final isNoti = status.isGranted;
                  return Switch(
                    value: isNoti,
                    focusColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    activeTrackColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    activeThumbColor: Colors.green,
                    onChanged: (value) async {
                      if (value) {
                        // Request permission if they turned it ON
                        final newStatus = await Permission.notification
                            .request();
                        if (newStatus.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                      } else {
                        // Guide them to turn it off in settings (OS limitation)
                        await openAppSettings();
                      }
                      // Refresh the provider to update the UI switch state
                      ref.invalidate(notificationPermissionProvider);
                    },
                  );
                },
                // Loading state: Show a tiny spinner while checking OS permission
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                // Error state: Fallback disabled switch
                error: (err, stack) =>
                    const Switch(value: false, onChanged: null),
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

          //* ─────────────────── Auth Action ───────────────────
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

          //* For Notifications
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

                // ───── Mood Selection ─────
                Builder(
                  builder: (context) {
                    final selectedTone = ref.watch(notificationToneProvider);

                    final tones = [
                      'Funny',
                      'Sarcastic',
                      'Motivational',
                      'Serious',
                    ];

                    return Column(
                      children: tones.map((tone) {
                        return RadioListTile<String>(
                          value: tone,
                          groupValue: selectedTone,
                          title: Text(tone),
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            ref.read(notificationToneProvider.notifier).state =
                                value!;

                            var dbVal = value.toLowerCase();
                            if (dbVal == 'sarcastic') {
                              dbVal = 'scarcastic';
                            } else if (dbVal == 'serious') {
                              dbVal = 'strict';
                            }
                            ref
                                .read(userNotifierProvider.notifier)
                                .updateNotificationTone(dbVal);
                            debugPrint("Selected tone: $value"); // Debug print
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                // ───── Old Default Tone Widget (kept for later) ─────
                /*
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
      */
              ],
            ),
          ),
          SizedBox(height: 10),
          _SettingsCard(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Advance Settings",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          SizedBox(height: 15),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Personalization',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'About personalization',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Personalized Notifications'),
                          content: const Text(
                            'Add details about yourself so notifications can feel '
                            'more relevant and personalized.'
                            'Add Basic Information about yourself , such as:\n\n'
                            'Name: Jhon\nAge: 20\nOccupation: Engineer\nLanguages i speak: English , Hindi\nHobbies: Sports and Action movies\nEtc.'
                            '\nSpecifying what languages you speak will help us send you notifications in those languages, if supported.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // TextField + Submit
                StatefulBuilder(
                  builder: (context, setState) {
                    int wordCount(String text) {
                      if (text.trim().isEmpty) return 0;

                      return text.trim().split(RegExp(r'\s+')).length;
                    }

                    final currentWordCount = wordCount(controller.text);

                    final isOverLimit = currentWordCount > 100;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditing) ...[
                          TextField(
                            controller: controller,
                            minLines: 3,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            enableInteractiveSelection: true,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Name: Jhon\nAge: 20\nOccupation: Engineer\nLanguages i speak: English , Hindi\nHobbies: Sports and Action movies\nEtc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),

                        // Word Counter
                        if (isEditing)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$currentWordCount/100 words',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isOverLimit ? Colors.red : null,
                                  ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // If currently viewing static text,
                              // unlock editing mode
                              if (!isEditing) {
                                setState(() {
                                  isEditing = true;
                                });
                                return;
                              }

                              // Validation
                              if (isOverLimit ||
                                  controller.text.trim().isEmpty) {
                                return;
                              }

                              final userInfo = controller.text.trim();

                              debugPrint("Submitted info: $userInfo");

                              await ref
                                  .read(userNotifierProvider.notifier)
                                  .updateUserInfo(userInfo);

                              setState(() {
                                isEditing = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Information saved successfully',
                                  ),
                                ),
                              );
                            },

                            child: isEditing ? Text('Submit') : Text("Update"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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

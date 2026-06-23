import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Core/permissions.dart';
import 'package:todo_notes/Presentation/Notifiers/userNotifier.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';
import 'package:todo_notes/Supabase_Auth/Screens/authScreen.dart';

// Notification Tone Provider - Loads per-user from SharedPrefs (falls back to device-level)
final notificationToneProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(userProvider);
  final userId = user?.id;
  return await getNotificationTone(userId: userId);
});

// User Info Provider - Loads per-user from SharedPrefs (falls back to device-level)
final userInfoProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(userProvider);
  final userId = user?.id;
  return await getUserInfo(userId: userId);
});

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  bool isEditing =
      true; // Start in editing mode to allow user to input info immediately
  final TextEditingController _controller = TextEditingController();
  bool _controllerInitialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(notificationPermissionProvider);
    final themeMode = ref.watch(themeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);
    final user = ref.watch(userProvider);

    // Sync controller ONCE when data first arrives, never while editing
    final userInfoAsync = ref.watch(userInfoProvider);
    userInfoAsync.whenData((info) {
      debugPrint("From settings , above -------- $info");
      if (!_controllerInitialized && info.isNotEmpty) {
        _controller.text = info;
        _controllerInitialized = true;
      }
    });
    debugPrint("----------- Controller: ${_controller.text}");
    if (_controller.text == '{}') {
      _controller.text = '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─────────────────── Appearance ───────────────────
          SettingsCard(
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

          // ─────────────────── Notifications ───────────────────
          SettingsCard(
            child: ListTile(
              title: Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: permissionAsync.when(
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
                        final newStatus = await Permission.notification
                            .request();
                        if (newStatus.isPermanentlyDenied) {
                          await openAppSettings();
                        }
                      } else {
                        await openAppSettings();
                      }
                      ref.invalidate(notificationPermissionProvider);
                    },
                  );
                },
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) =>
                    const Switch(value: false, onChanged: null),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────── Account ───────────────────
          SettingsCard(
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
            SettingsCard(
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

          // ─────────────────── Notification Tone ───────────────────
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Builder(
                  builder: (context) {
                    final selectedToneAsync = ref.watch(
                      notificationToneProvider,
                    );
                    final toneOptions = {
                      'funny': 'Funny',
                      'sarcastic': 'Sarcastic',
                      'motivational': 'Motivational',
                      'strict': 'Serious',
                    };
                    return selectedToneAsync.when(
                      data: (selectedTone) {
                        return Column(
                          children: toneOptions.entries.map((entry) {
                            return RadioListTile<String>(
                              value: entry.key,
                              groupValue: selectedTone,
                              title: Text(entry.value),
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              onChanged: (value) async {
                                if (value == null) return;
                                await ref
                                    .read(userNotifierProvider.notifier)
                                    .updateNotificationTone(value);
                                ref.invalidate(notificationToneProvider);
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SettingsCard(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Advance Settings",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ─────────────────── Personalization ───────────────────
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // ─── TextField + Submit ───
                StatefulBuilder(
                  builder: (context, setLocalState) {
                    int wordCount(String text) {
                      if (text.trim().isEmpty) return 0;
                      return text.trim().split(RegExp(r'\s+')).length;
                    }

                    final currentWordCount = wordCount(_controller.text);
                    final isOverLimit = currentWordCount > 100;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditing) ...[
                          TextField(
                            controller: _controller,
                            minLines: 3,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            enableInteractiveSelection: true,
                            onChanged: (_) => setLocalState(() {}),
                            decoration: InputDecoration(
                              hintText:
                                  'Name: Jhon\nAge: 20\nOccupation: Engineer\nLanguages i speak: English , Hindi\nHobbies: Sports and Action movies\nEtc.',
                              hintStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.4),
                                  ),
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
                              (_controller.text.isEmpty ||
                                      _controller.text == '{}')
                                  ? 'No info added yet.'
                                  : _controller.text,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _controller.text.isEmpty
                                        ? Colors.grey
                                        : null,
                                  ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!isEditing) {
                                setState(
                                  () => isEditing = true,
                                ); // setState from State class
                                return;
                              }
                              if (isOverLimit ||
                                  _controller.text.trim().isEmpty)
                                return;

                              await ref
                                  .read(userNotifierProvider.notifier)
                                  .updateUserInfo(_controller.text.trim());
                              ref.invalidate(userInfoProvider);
                              setState(() {
                                isEditing = false;
                              });
                              ScaffoldMessenger.of(context).showMaterialBanner(
                                MaterialBanner(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  surfaceTintColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.1),

                                  content: Text(
                                    'Information saved successfully',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentMaterialBanner();
                                      },
                                    ),
                                  ],
                                ),
                              );

                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentMaterialBanner();
                                }
                              });
                            },
                            child: isEditing
                                ? const Text('Submit')
                                : const Text('Update'),
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
class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({super.key, required this.child});

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

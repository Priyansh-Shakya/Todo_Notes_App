import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppTheme/appTheme.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Core/Fcm_Service/firebase_options.dart';
import 'package:todo_notes/Core/Fcm_Service/tokenProvider.dart';
import 'package:todo_notes/Core/appBootstrap.dart';
import 'package:todo_notes/Presentation/Providers/userProvider.dart';
import 'package:todo_notes/Supabase_Auth/Helpers/initilizeSupabase.dart';
import 'package:todo_notes/Supabase_Auth/Screens/authGate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //FCM
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //SUPABASE
  await initSupabase();
  FlutterError.onError = (details) {
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack.toString());
  };

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  //! Android notification channel setup
  // Create the channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // ✅ Initialize local notifications
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  // ✅ THIS IS THE KEY MISSING PART
  // Listen to foreground FCM messages and show them manually
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  runApp(ProviderScope(child: AppInitializer(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // To create User
    ref.watch(authListenerProvider);

    // To get fcm token
    ref.watch(fcmInitProvider);
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

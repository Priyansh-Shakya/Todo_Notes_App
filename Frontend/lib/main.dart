import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppTheme/appTheme.dart';
import 'package:todo_notes/Core/AppTheme/themeNotifier.dart';
import 'package:todo_notes/Core/Fcm_Service/fcm_service.dart';
import 'package:todo_notes/Core/Fcm_Service/firebase_options.dart';
import 'package:todo_notes/Core/Fcm_Service/tokenProvider.dart';
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
  runApp(ProviderScope(child: MyApp()));
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

import 'package:todo_notes/Core/Fcm_Service/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

//This function is used by firebase directly, if our app is in background , not currently active, this function is used to trigger notification , firebase runs a small flutter isolate to run it in background.

// This function is invoked by Firebase when a background message is received.
// It runs in a separate Flutter isolate.
// MUST be a top-level function (not inside a class).

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint("Background Message: ${msg.messageId}");
}

/*
Firebase FCM works in 2 main states:

1 - Background / Terminated:
   When app is minimized or not actively open.
   onBackgroundMessage() handles data messages in this state.

2 - Foreground:
   When app is open and active.
   onMessage.listen() handles messages.
*/

// Note: FCM Token are not JWT like token which expire after hours - they are token per device, expires within a month!
class FcmService {
  FcmService._();

  static Future<String?> init() async {
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    ); // the function is not called here "withhout parenthesis" , it is passed to firebase.

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();

    debugPrint(
      "-------------------------------------FCM Token: $token---------------------------------",
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      debugPrint("Foreground Message received: ${msg.messageId}");
    });

    return token;
  }
}

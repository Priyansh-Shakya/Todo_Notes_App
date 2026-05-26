import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationPermissionProvider = FutureProvider<PermissionStatus>((ref) async {
  return await Permission.notification.status;
});

Future<PermissionStatus> checkNotificationPermission() async {
  // 1. Check the current status
  PermissionStatus status = await Permission.notification.status;

  if (status.isGranted) {
    // Permission is already allowed
    debugPrint("Notification permission granted.");
  } 
  else if (status.isDenied) {
    // Permission has not been requested yet or was previously denied
    debugPrint("Permission denied. Requesting now...");
    
    // 2. Request the permission
    PermissionStatus newStatus = await Permission.notification.request();
    
    if (newStatus.isGranted) {
      debugPrint("Permission granted by user.");
    } else {
      debugPrint("Permission denied by user.");
    }
  } 
  else if (status.isPermanentlyDenied) {
    // The user opted to "Don't ask again" (Android) or denied it globally (iOS)
    debugPrint("Permission permanently denied. Directing to settings...");
    
    // 3. Open system app settings so the user can enable it manually
    await openAppSettings();
  }

  return status;
}

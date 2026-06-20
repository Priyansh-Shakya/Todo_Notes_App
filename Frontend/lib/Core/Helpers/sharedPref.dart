import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeSelectedScreen(int index) async {
  final pref = await SharedPreferences.getInstance();
  await pref.setInt('SelectedScreen', index);
}

Future<int?> getStoredScreen() async {
  final pref = await SharedPreferences.getInstance();
  return pref.getInt('SelectedScreen');
}

Future<void> setPannelInfoShown() async {
  final pref = await SharedPreferences.getInstance();
  await pref.setBool('pannelInfoShown', true);
}

Future<bool?> showPannelInfoShown() async {
  final pref = await SharedPreferences.getInstance();
  return pref.getBool('pannelInfoShown');
}

// User-scoped SharedPrefs helpers: accept optional userId. If userId is null,
// fall back to device-level keys for backwards compatibility.
Future<void> setNotificationTone(String tone, {String? userId}) async {
  final pref = await SharedPreferences.getInstance();
  final key = userId == null ? 'notificationTone' : 'notificationTone_\$userId';
  await pref.setString(key, tone);
}

Future<String> getNotificationTone({String? userId}) async {
  final pref = await SharedPreferences.getInstance();
  final key = userId == null ? 'notificationTone' : 'notificationTone_\$userId';
  return pref.getString(key) ?? 'funny';
}

Future<void> setUserInfo(String info, {String? userId}) async {
  final pref = await SharedPreferences.getInstance();
  final key = userId == null ? 'userInfo' : 'userInfo_\$userId';
  await pref.setString(key, info);
}

Future<String> getUserInfo({String? userId}) async {
  final pref = await SharedPreferences.getInstance();
  final key = userId == null ? 'userInfo' : 'userInfo_\$userId';
  final info = pref.getString(key) ?? '';
  debugPrint("Retrieved user info from SharedPreferences (key=\$key): $info");
  return info;
}

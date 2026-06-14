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

Future<void> setNotificationTone(String tone) async {
  final pref = await SharedPreferences.getInstance();
  await pref.setString('notificationTone', tone);
}

Future<String> getNotificationTone() async {
  final pref = await SharedPreferences.getInstance();
  return pref.getString('notificationTone') ?? 'funny';
}

Future<void> setUserInfo(String info) async {
  final pref = await SharedPreferences.getInstance();
  await pref.setString('userInfo', info);
}

Future<String> getUserInfo() async {
  final pref = await SharedPreferences.getInstance();
  final info = pref.getString('userInfo') ?? '';
  debugPrint("Retrieved user info from SharedPreferences: $info");
  return info;
}

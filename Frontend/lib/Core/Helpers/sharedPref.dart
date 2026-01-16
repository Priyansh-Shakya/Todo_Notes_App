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

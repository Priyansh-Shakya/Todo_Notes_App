import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<bool> checkInternetConnection() async {
  final bool isConnected = await InternetConnection().hasInternetAccess;
  debugPrint("Internet Connection: $isConnected");
  return isConnected;
}

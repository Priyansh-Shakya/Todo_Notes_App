//* Refresh screen function
import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Connectivity/checkInternet.dart';
import 'package:todo_notes/Presentation/Notifiers/todoNotifier.dart';

//? Internet not available banner
Widget showInternetBanner() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.red.shade600,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: const Row(
      children: [
        Icon(Icons.wifi_off_rounded, color: Colors.white),

        SizedBox(width: 10),

        Expanded(
          child: Text(
            "No internet connection",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> refreshScreen(TodoNotifier notifier) async {
  final bool isConnected = await checkInternetConnection();
  if (isConnected) {
    showInternetBanner();
  }
  notifier.refreshList();
}

import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';

Future<bool?> showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // close dialog

            child: Text("Yes", style: Theme.of(context).textTheme.bodySmall),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // just close the dialog
            child: Text("Cancel", style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      );
    },
  );
}

String createdAtSliced(String? timeString) {
  // If null or empty, use current time
  final time = (timeString != null && timeString.isNotEmpty)
      ? DateTime.tryParse(timeString)
      : DateTime.now();

  final t = time ?? DateTime.now(); // fallback if parsing fails

  final day = t.day.toString().padLeft(2, '0');
  final month = t.month.toString().padLeft(2, '0');
  final year = t.year.toString();

  return '$day/$month/$year';
}

void showInfoOnce(BuildContext context) async {
  final bool? show = await showPannelInfoShown();
  if (show != null && show == true) return;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Information Pannel'),
        content: Text('Tap on Task Card to open more information pannel.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      );
    },
  );
  await setPannelInfoShown();
}

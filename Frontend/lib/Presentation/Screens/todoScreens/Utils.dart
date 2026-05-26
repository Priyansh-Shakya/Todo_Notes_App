import 'package:flutter/material.dart';
import 'package:todo_notes/Core/AppSounds/soundManager.dart';
import 'package:todo_notes/Core/Connectivity/checkInternet.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Presentation/Notifiers/todoNotifier.dart';

Future<bool?> showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () {
              SoundManager.playDeleteSound();
              Navigator.of(context).pop(true);
            }, // close dialog

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

String formatTimes(List<String>? times) {
  if (times == null || times.isEmpty) return 'Not Set';

  return times
      .map((t) {
        final parts = t.split(':');
        if (parts.length < 2) return t;

        final hour24 = int.tryParse(parts[0]);
        final minute = parts[1];

        if (hour24 == null) return t;

        final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
        final amPm = hour24 >= 12 ? 'PM' : 'AM';

        return '$hour12:$minute $amPm';
      })
      .join(', ');
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

Widget showCard(String label, Widget trailing, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        ),
      ),
    ),
  );
}

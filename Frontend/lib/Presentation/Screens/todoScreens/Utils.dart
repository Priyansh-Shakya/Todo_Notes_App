import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Helpers/sharedPref.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';

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

String formatTimes(List<String>? times) {
  if (times == null || times.isEmpty) return 'Not Set';

  return times
      .map((t) {
        final dt = DateTime.tryParse(t);
        if (dt == null) return t;

        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';

        return '$hour:$minute $amPm';
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

Widget showCard(String label, Widget trailing) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

void showNotificationSheet({
  required BuildContext context,
  required TodoReadEntity todo,
  required NotificationModel? notification,
}) {
  const List<String> weekDayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  bool isNotiOn = notification != null;

  final String task = todo.task;
  final bool isComp = todo.isComplete;
  final String date = createdAtSliced(todo.createdAt);

  final String notiType = notification?.scheduleType ?? 'none';
  final String? notiDate = notification?.scheduledDate;
  final List<int>? weekDays = notification?.weekdays;
  final List<String>? time = notification?.times;

  debugPrint(notiType);
  debugPrint(notiDate);
  debugPrint(weekDays.toString());
  debugPrint(time.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  // Drag handle
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Task Notification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          showCard(
                            "Task",
                            Text(task, textAlign: TextAlign.end),
                          ),

                          showCard(
                            "Completed",
                            Text(isComp ? "Completed" : "Not Yet"),
                          ),

                          showCard("Created At", Text(date)),

                          showCard(
                            "Notifications",
                            Switch(
                              value: isNotiOn,
                              focusColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              activeTrackColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                              activeThumbColor: Colors.green,
                              onChanged: (val) {
                                setModalState(() {
                                  isNotiOn = val;
                                });
                              },
                            ),
                          ),

                          if (isNotiOn)
                            showCard(
                              "Notification Type",
                              Text(notiType == 'date' ? 'Date' : 'Weekly'),
                            ),

                          if (isNotiOn &&
                              notiType == 'date' &&
                              notiDate != null)
                            showCard("Notification Date", Text(notiDate)),

                          if (isNotiOn &&
                              notiType == 'weekly' &&
                              weekDays != null)
                            showCard(
                              "Week Days",
                              Text(
                                weekDays.map((d) => weekDayNames[d]).join(', '),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          if (isNotiOn)
                            showCard(
                              'Times',
                              Text(formatTimes(time), textAlign: TextAlign.end),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/Utils.dart';

class TodoBottomSheet extends ConsumerStatefulWidget {
  final TodoEntity todo;

  const TodoBottomSheet({super.key, required this.todo});

  @override
  ConsumerState<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends ConsumerState<TodoBottomSheet> {
  final List<String> weekDayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context) {
    final asyncNoti = ref.watch(notificationNotifierProvider);

    return asyncNoti.when(
      loading: () => const ShimmerLoadingWidget(),
      error: (err, st) => Text("Error: $err"),
      data: (notifications) {
        // 🔥 Find the SINGLE notification you want
        final notification = notifications
            .where((e) => e.taskId == widget.todo.id)
            .cast<NotificationModel?>()
            .firstOrNull;

        final isNotiOn = notification != null;
        bool isActiveNoti = isNotiOn;
        final task = widget.todo.task;
        final isComp = widget.todo.isComplete;
        final date = createdAtSliced(widget.todo.createdAt);

        final notiType = notification?.scheduleType ?? 'none';
        final notiDate = createdAtSliced(notification?.scheduledDate);
        final weekDays = notification?.weekdays;
        final time = notification?.times;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
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
                const Text(
                  'Task Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        showCard("Task", Text(task), context),
                        showCard(
                          "Completed",
                          Text(isComp ? "Completed" : "Not Yet"),
                          context,
                        ),
                        showCard("Created At", Text(date), context),

                        SizedBox(
                          height: 70,
                          child: showCard(
                            "Notifications",
                            Switch(
                              value: isActiveNoti,
                              focusColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              activeTrackColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                              activeThumbColor: Colors.green,
                              onChanged: (val) {
                                setState(() {
                                  isActiveNoti = val;
                                });
                              },
                            ),
                            context,
                          ),
                        ),

                        if (isNotiOn)
                          showCard(
                            "Notification Type",
                            Text(notiType == 'date' ? 'Date' : 'Weekly'),
                            context,
                          ),

                        if (isNotiOn && notiType == 'date')
                          showCard(
                            "Notification Date",
                            Text(notiDate),
                            context,
                          ),

                        if (isNotiOn &&
                            notiType == 'weekly' &&
                            weekDays != null)
                          showCard(
                            "Week Days",
                            Text(
                              weekDays.map((d) => weekDayNames[d]).join(', '),
                            ),
                            context,
                          ),

                        if (isNotiOn)
                          showCard('Times', Text(formatTimes(time)), context),
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
  }
}

void showTodoBottomSheet({
  required TodoEntity todo,
  required BuildContext context,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return TodoBottomSheet(todo: todo);
    },
  );
}

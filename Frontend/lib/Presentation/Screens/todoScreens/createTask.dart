import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiStateProviders.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiWidget.dart';

class CreateTask extends ConsumerStatefulWidget {
  const CreateTask({super.key});

  @override
  ConsumerState<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends ConsumerState<CreateTask> {
  late final TextEditingController taskCtr;
  final NotificationData notiData = NotificationData();

  @override
  void initState() {
    super.initState();
    taskCtr = TextEditingController();
  }

  @override
  void dispose() {
    taskCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(weeklyNoti);

    void saveTaskAndNoti() {
      final todo = TodoEntity(
        task: taskCtr.text,
        createdAt: DateTime.now.toString(),
        isComplete: false,
      );

      print("Task : ${taskCtr.text}");

      final ready = notiData.isReady(type);
      if (!ready) {
        if (type == NotificationType.weekly) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please Select Week Days and Time for Notification",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please Select Date and Time for Notification"),
            ),
          );
        }

        debugPrint(notiData.pickedDate.toString());

        debugPrint(notiData.selectedDays.toString());

        debugPrint(notiData.pickedTimes.toString());
      }
      if (ready) {
        debugPrint(notiData.pickedDate.toString());
        debugPrint(notiData.selectedDays.toString());
        debugPrint(notiData.pickedTimes.toString());

        Navigator.of(context).pop();
        ref.read(todoNotifierProvider.notifier).createTodo(payload: todo);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Task",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: saveTaskAndNoti, icon: Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 18),
              Text("Task", style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 10),
              TextField(
                controller: taskCtr,
                maxLines: null,
                minLines: 1,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
              SizedBox(height: 35),
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              NotificationScreen(notiData: notiData),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';

class CreateTask extends ConsumerWidget {
  const CreateTask({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController titleCtr = TextEditingController();
    TextEditingController taskCtr = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Task",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final todo = TodoEntity(
                task: taskCtr.text,
                createdAt: DateTime.now.toString(),
                isComplete: false,
              );
              print("Title: ${titleCtr.text}");
              print("Task : ${taskCtr.text}");

              Navigator.of(context).pop();
              ref.read(todoNotifierProvider.notifier).createTodo(payload: todo);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text("Title", style: Theme.of(context).textTheme.headlineMedium),

            SizedBox(height: 18),
            Text("Task", style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 10),
            TextField(
              controller: taskCtr,
              maxLines: null,
              minLines: 1,
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Notifications",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

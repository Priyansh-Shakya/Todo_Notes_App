import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppSounds/soundManager.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/Utils.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/bottomSheet.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/createTask.dart';

class MainTodoScreen extends ConsumerStatefulWidget {
  const MainTodoScreen({super.key});

  @override
  ConsumerState<MainTodoScreen> createState() => _MainTodoScreenState();
}

class _MainTodoScreenState extends ConsumerState<MainTodoScreen> {
  bool _infoShown = false;

  @override
  Widget build(BuildContext context) {
    final todoAsync = ref.watch(todoNotifierProvider);
    final notifier = ref.read(todoNotifierProvider.notifier);

    todoAsync.whenOrNull(
      data: (todos) {
        if (todos.isNotEmpty && !_infoShown) {
          _infoShown = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showInfoOnce(context);
          });
        }
      },
    );

    final Widget todos = todoAsync.when(
      data: (todo) {
        if (todo.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 96,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withAlpha(68),
                ),
                Text(
                  "No Tasks yet, create new",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withAlpha(200),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => refreshScreen(notifier),

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: todo.length,
            itemBuilder: (context, index) {
              final oneTodo = todo[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                child: GestureDetector(
                  onTap: () {
                    showTodoBottomSheet(todo: oneTodo, context: context);
                  },
                  child: Card(
                    elevation: 2,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: ListTile(
                        leading: Text(
                          "${index + 1}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        title: Text(
                          oneTodo.task.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    // when checked — red background
                                    return Colors.blue;
                                  } // when unchecked — light grey (optional)
                                  return Colors.red;
                                },
                              ),
                              checkColor: const Color(
                                0xff39ff40,
                              ), // ✅ tick mark color ),
                              value: oneTodo.isComplete,
                              onChanged: (bool? newVal) {
                                SoundManager.playPopUpSound();
                                final updateTodo = TodoEntity(
                                  id: oneTodo.id,
                                  task: oneTodo.task,
                                  isComplete: newVal ?? false,
                                );
                                debugPrint(
                                  "Update Todo main screen : ID${oneTodo.id} ${updateTodo.task} , ${updateTodo.isComplete}",
                                );
                                notifier.updateTodo(
                                  id: oneTodo.id!,
                                  todo: updateTodo,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () async {
                                bool? result = await showDeleteDialog(context);
                                if (result == true) {
                                  await notifier.deleteTodo(id: oneTodo.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (err, st) {
        print(err);
        return Text("Error : $err");
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text("Tasks", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: todos,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: 30, color: Colors.blue),
        onPressed: () {
          SoundManager.playPopUpSound();
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => CreateTask()));
        },
      ),
    );
  }
}

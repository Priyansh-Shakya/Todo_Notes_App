// ============================================================================
// ASSUMPTIONS MADE (adjust if they don't match your codebase):
//
// 1. NotificationModel.scheduledDate is a nullable DateTime.
// 2. NotificationModel.weekdays is a nullable List<int> (0 = Sun ... 6 = Sat),
//    matching the indexing already used in the original file.
// 3. NotificationModel.times is a nullable List<TimeOfDay>.
//    -> If you actually persist times as strings ("HH:mm") or minute-ints,
//       convert to/from TimeOfDay in _hydrateFromNotification() and
//       _persistNotification() below.
// 4. There are real provider methods to create/update/delete a
//    NotificationModel and to update a TodoEntity's task text — these are
//    NOT guessed at directly. They're left as commented TODOs in
//    _persistTaskText() and _persistNotification() so you can wire them to
//    whatever your actual notifiers expose.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Data/Models/todoModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/Utils.dart';

class TodoBottomSheet extends ConsumerStatefulWidget {
  final TodoEntity todo;
  final bool isEditMode;
  const TodoBottomSheet({
    super.key,
    required this.todo,
    required this.isEditMode,
  });

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

  late TextEditingController _taskController;

  bool _isNotiOn = false;
  String? _selectedType; // 'date' or 'weekly'
  String? _selectedDate;
  final Set<int> _selectedWeekDays = {};
  final List<String> _selectedTimes = [];

  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.todo.task);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Pulls existing notification data into editable local state.
  // Guarded by _hydrated so user edits aren't clobbered on rebuild.
  void _hydrateFromNotification(NotificationModel? notification) {
    if (_hydrated) return;
    _hydrated = true;

    _isNotiOn = notification != null;
    if (notification == null) return;

    _selectedType = notification.scheduleType;
    _selectedDate = notification.scheduledDate;

    if (notification.weekdays != null) {
      // ensure values are in 0..6 range
      _selectedWeekDays.addAll(
        notification.weekdays!.where((d) => d >= 0 && d <= 6),
      );
    }

    // times from backend may be ISO-like strings (e.g. "10:30:00"); store as-is
    // Normalize times: backend may send a list of strings or a single comma-separated string.
    for (final raw in notification.times) {
      // remove surrounding brackets or quotes if any, then split by comma
      final cleaned = raw.toString().replaceAll(RegExp(r'[\[\]\"]'), '');
      if (cleaned.contains(',')) {
        final parts = cleaned.split(',');
        for (final p in parts) {
          final t = p.trim();
          if (t.isNotEmpty) _selectedTimes.add(t);
        }
      } else {
        final t = cleaned.trim();
        if (t.isNotEmpty) _selectedTimes.add(t);
      }
    }
    // dedupe while preserving order
    final seen = <String>{};
    final deduped = <String>[];
    for (final t in _selectedTimes) {
      if (seen.add(t)) deduped.add(t);
    }
    _selectedTimes
      ..clear()
      ..addAll(deduped);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateTime.parse(_selectedDate!)
          : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        // store canonical ISO date, e.g. "2026-07-15" — this is what the backend gets
        _selectedDate = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // Convert TimeOfDay to backend-friendly HH:MM:SS (e.g., "10:30:00")
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final formatted = '$hour:$minute:00';
      setState(() => _selectedTimes.add(formatted));
    }
  }

  void _removeTime(String time) {
    setState(() => _selectedTimes.remove(time));
  }

  void _toggleWeekDay(int index) {
    setState(() {
      if (_selectedWeekDays.contains(index)) {
        _selectedWeekDays.remove(index);
      } else {
        _selectedWeekDays.add(index);
      }
    });
  }

  // --------------------------------------------------------------------
  // Wire these to your actual data layer.
  // --------------------------------------------------------------------
  Future<void> _persistTaskText(String newTask) async {
    if (newTask == widget.todo.task) return;
    if (widget.todo.id == null) return;
    try {
      final repo = ref.read(todoRepoProvider);
      final todoModel = TodoModel(
        task: newTask,
        isComplete: widget.todo.isComplete,
        id: widget.todo.id,
        createdAt: widget.todo.createdAt,
      );
      // Use editT to call backend /edittodo (supports richer edit semantics)
      await repo.editT(todo: todoModel, id: widget.todo.id!);

      // refresh todo list
      await ref.read(todoNotifierProvider.notifier).refreshList();
    } catch (e) {
      _showSnack('Failed to update task');
    }
  }
  

  Future<void> _persistNotification(NotificationModel? existing) async {
    if (!_isNotiOn) {
      if (existing != null) {
        // TODO: await ref.read(notificationNotifierProvider.notifier)
        //           .deleteNotification(existing.id);
      }
      return;
    }

    final service = ref.read(notificcationServiceProvider);

    final payload = NotificationModel(
      taskId: widget.todo.id,
      scheduleType: _selectedType!,
      times: _selectedTimes,
      timezone: 'UTC',
      isActive: true,
      scheduledDate: _selectedType == 'date' ? _selectedDate : null,
      weekdays: _selectedType == 'weekly' ? _selectedWeekDays.toList() : null,
    );

    try {
      // send (backend currently supports insert via /setnoti)
      if (widget.todo.id == null) return;
      await service.sendTaskNotification(payload, widget.todo.id!);

      // Refresh notification list
      await ref.read(notificationNotifierProvider.notifier).refreshList();
    } catch (e) {
      _showSnack('Failed to save notification');
    }
  }

  bool _validate() {
    if (_taskController.text.trim().isEmpty) {
      _showSnack("Task cannot be empty");
      return false;
    }

    if (!_isNotiOn) return true;

    if (_selectedType == null) {
      _showSnack("Please select a notification type");
      return false;
    }

    if (_selectedType == 'date') {
      if (_selectedDate == null || _selectedTimes.isEmpty) {
        _showSnack("Please Select Date and Time for Notification");
        return false;
      }
    } else if (_selectedType == 'weekly') {
      if (_selectedWeekDays.isEmpty || _selectedTimes.isEmpty) {
        _showSnack("Please Select Week Days and Time for Notification");
        return false;
      }
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onSave(NotificationModel? existing) async {
    if (!_validate()) return;

    await _persistTaskText(_taskController.text.trim());
    await _persistNotification(existing);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final asyncNoti = ref.watch(notificationNotifierProvider);

    return asyncNoti.when(
      loading: () => const ShimmerLoadingWidget(),
      error: (err, st) => Text("Error: $err"),
      data: (notifications) {
        final notification = notifications
            .where((e) => e.taskId == widget.todo.id)
            .cast<NotificationModel?>()
            .firstOrNull;

        if (widget.isEditMode) {
          _hydrateFromNotification(notification);
        }

        final isComp = widget.todo.isComplete;
        final date = createdAtSliced(widget.todo.createdAt);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
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
                Text(
                  widget.isEditMode ? 'Edit Task' : 'Task Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: widget.isEditMode
                        ? _buildEditBody(context, notification)
                        : _buildViewBody(notification, isComp, date),
                  ),
                ),

                if (widget.isEditMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          ref
                              .read(notificationNotifierProvider.notifier)
                              .refreshList();
                          _onSave(notification);
                        },
                        child: const Text('Save'),
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

  // -------------------- READ-ONLY VIEW (unchanged behaviour) --------------------
  Widget _buildViewBody(
    NotificationModel? notification,
    bool isComp,
    String date,
  ) {
    final isNotiOn = notification != null;
    final notiType = notification?.scheduleType ?? 'none';
    final notiDate = createdAtSliced(notification?.scheduledDate);
    final weekDays = notification?.weekdays;
    final time = notification?.times;

    debugPrint("Notification on: $isNotiOn");

    return Column(
      children: [
        showCard("Task", Text(widget.todo.task), context),
        showCard("Completed", Text(isComp ? "Completed" : "Not Yet"), context),
        showCard("Created At", Text(date), context),
        SizedBox(
          height: 70,
          child: showCard(
            "Notifications",
            IgnorePointer(
              child: Switch(
                value: isNotiOn,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
                onChanged: (_) {},
              ),
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
          showCard("Notification Date", Text(notiDate), context),
        if (isNotiOn && notiType == 'weekly' && weekDays != null)
          showCard(
            "Week Days",
            Text(weekDays.map((d) => weekDayNames[d]).join(', ')),
            context,
          ),
        if (isNotiOn) showCard('Times', Text(formatTimes(time)), context),
      ],
    );
  }

  // -------------------- EDITABLE VIEW --------------------
  Widget _buildEditBody(BuildContext context, NotificationModel? notification) {
    return Column(
      children: [
        showCard(
          "Task",
          TextField(
            controller: _taskController,
            textAlign: TextAlign.end,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'Task name',
            ),
          ),
          context,
        ),

        SizedBox(
          height: 70,
          child: showCard(
            "Notifications",
            Switch(
              value: _isNotiOn,
              focusColor: Colors.green,
              inactiveThumbColor: Colors.red,
              activeThumbColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  _isNotiOn = val;
                  if (!val) _selectedType = null;
                });
              },
            ),
            context,
          ),
        ),

        if (_isNotiOn) ...[
          const SizedBox(height: 6),
          _buildTypeSelector(),
          const SizedBox(height: 6),

          if (_selectedType == 'date')
            showCard(
              "Notification Date",
              TextButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? 'Pick date'
                      : createdAtSliced(
                          _selectedDate!,
                        ), // format exactly ONCE, on the canonical ISO value
                ),
              ),
              context,
            ),

          if (_selectedType == 'weekly')
            showCard("Week Days", _buildWeekDaySelector(), context),

          if (_selectedType != null)
            showCard("Times", _buildTimesSelector(context), context),
        ],
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Date-Based'),
            subtitle: const Text('Receive a notification on a specific date'),
            value: 'date',
            groupValue: _selectedType,
            onChanged: (val) {
              setState(() {
                _selectedType = val;
                _selectedWeekDays.clear();
              });
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Weekly'),
            subtitle: const Text('Receive a notification every week'),
            value: 'weekly',
            groupValue: _selectedType,
            onChanged: (val) {
              setState(() {
                _selectedType = val;
                _selectedDate = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(weekDayNames.length, (index) {
        final selected = _selectedWeekDays.contains(index);
        return FilterChip(
          label: Text(weekDayNames[index]),
          selected: selected,
          onSelected: (_) => _toggleWeekDay(index),
        );
      }),
    );
  }

  Widget _buildTimesSelector(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: [
        ..._selectedTimes.map((t) {
          String display;
          // If it's TimeOfDay.toString(), extract between parentheses
          final s = t.toString();
          final timeOfDayMatch = RegExp(
            r"TimeOfDay\((\d{1,2}:\d{2})\)",
          ).firstMatch(s);
          if (timeOfDayMatch != null) {
            display = timeOfDayMatch.group(1)!;
          } else {
            // Try to find HH:MM pattern anywhere (covers "10:30:00" or "10:30")
            final hhmm = RegExp(r"(\d{1,2}:\d{2})").firstMatch(s);
            display = hhmm?.group(1) ?? s;
          }

          return Chip(
            label: Text(display),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () => _removeTime(t),
          );
        }),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          onPressed: _addTime,
        ),
      ],
    );
  }
}

void showTodoBottomSheet({
  required TodoEntity todo,
  required bool isEditMode,
  required BuildContext context,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return TodoBottomSheet(todo: todo, isEditMode: isEditMode);
    },
  );
}

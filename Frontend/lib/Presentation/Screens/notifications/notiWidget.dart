import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiStateProviders.dart';
import 'package:todo_notes/Presentation/Screens/notifications/utils.dart';
import 'package:todo_notes/Presentation/Screens/todoScreens/Utils.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final NotificationData notiData;
  const NotificationScreen({super.key, required this.notiData});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _typeSelectionCard(),
        const SizedBox(height: 20),
        _configPanel(context),
      ],
    );
  }

  // ---------------- CARD 1 ----------------
  Widget _typeSelectionCard() {
    final selectedType = ref.watch(weeklyNoti);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          RadioListTile<NotificationType>(
            title: const Text('Date-Based'),
            subtitle: const Text('Receive notifications on specific dates'),
            value: NotificationType.dateBased,
            groupValue: selectedType,
            onChanged: (value) {
              if (value == null) return;

              ref.read(weeklyNoti.notifier).state = value;

              debugPrint("Changed to: $value");

              if (value == NotificationType.weekly) {
                widget.notiData.pickedDate = null;
              } else {
                widget.notiData.selectedDays.clear();
              }
            },
          ),

          const Divider(),

          RadioListTile<NotificationType>(
            title: const Text('Weekly'),
            subtitle: const Text('Receive notifications every week'),
            value: NotificationType.weekly,
            groupValue: selectedType,
            onChanged: (value) {
              if (value == null) return;

              ref.read(weeklyNoti.notifier).state = value;
              debugPrint("Changed to: $value");
            },
          ),
        ],
      ),
    );
  }

  // ---------------- CARD 2 ----------------
  Widget _configPanel(BuildContext context) {
    NotificationType selectedType = ref.watch(weeklyNoti);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Card(
        key: ValueKey(selectedType),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (selectedType == NotificationType.dateBased)
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await pickDate(context);
                    if (date != null) {
                      widget.notiData.pickedDate = date.toIso8601String();
                    }

                    setState(() {});
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    widget.notiData.pickedDate != null
                        ? createdAtSliced(widget.notiData.pickedDate!)
                        : "Select Date",
                  ),
                ),

              if (selectedType == NotificationType.weekly)
                WeekDaySelector(
                  selectedDays: widget.notiData.selectedDays,
                  onDayToggle: (day) {
                    setState(() {
                      if (widget.notiData.selectedDays.contains(day)) {
                        widget.notiData.selectedDays.remove(day);
                      } else {
                        widget.notiData.selectedDays.add(day);
                      }
                    });
                  },
                ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final apiTime = timeOfDayToApi(time); // "18:25"
                    final disTime = formatTimeOfDayAmPm(time); // "6:25 PM"

                    widget.notiData.pickedTimes.add(apiTime); // backend-safe
                    widget.notiData.displayTimes.add(disTime); // UI-only

                    setState(() {});
                  }
                },
                icon: const Icon(Icons.access_time),
                label: const Text('Select Time'),
              ),

              if (widget.notiData.displayTimes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    children: widget.notiData.displayTimes.map((time) {
                      return Chip(
                        label: Text(time),
                        onDeleted: () {
                          setState(
                            () => widget.notiData.pickedTimes.remove(time),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

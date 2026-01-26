import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiStateProviders.dart';
import 'package:todo_notes/Presentation/Screens/notifications/utils.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final NotificationData notiData;
  const NotificationScreen({super.key, required this.notiData});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  NotificationType _selectedType = NotificationType.weekly;

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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          RadioListTile<NotificationType>(
            title: const Text('Date-Based'),
            subtitle: const Text('Receive notifications on specific dates'),
            value: NotificationType.dateBased,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                ref.read(weeklyNoti.notifier).state = value;

                if (_selectedType == NotificationType.weekly) {
                  // clear date-based data
                  widget.notiData.pickedDate = null;
                } else {
                  // clear weekly data
                  widget.notiData.selectedDays.clear();
                }

                // optional: also clear time if your UX demands it
                // widget.notiData.pickedTimes.clear();
              });
            },
          ),
          const Divider(),
          RadioListTile<NotificationType>(
            title: const Text('Weekly'),
            subtitle: const Text('Receive notifications every week'),
            value: NotificationType.weekly,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                ref.read(weeklyNoti.notifier).state = value;
                debugPrint("Selected Type: $_selectedType");
                debugPrint("Provider Type: ${ref.watch(weeklyNoti)}");
              });
            },
          ),
        ],
      ),
    );
  }

  // ---------------- CARD 2 ----------------
  Widget _configPanel(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Card(
        key: ValueKey(_selectedType),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_selectedType == NotificationType.dateBased)
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
                        ? widget.notiData.pickedDate!
                        : "Select Date",
                  ),
                ),

              if (_selectedType == NotificationType.weekly)
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
                    final strTime = time.toString();
                    widget.notiData.pickedTimes.add(strTime);
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.access_time),
                label: const Text('Select Time'),
              ),

              if (widget.notiData.pickedTimes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    children: widget.notiData.pickedTimes.map((time) {
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

import 'package:flutter/material.dart';

Future<DateTime?> pickDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    firstDate: DateTime(2015),
    lastDate: DateTime(2100),
    initialDate: DateTime.now(),
    initialEntryMode: DatePickerEntryMode.calendar,
  );
  if (picked != null) {
    //send date to database
    //store it in a variable and let user pick time as well
    return picked;
  }
  return null;
}

Future<void> pickTime(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.dial,
  );
  if (picked != null) {
    //send time to database as well.
  }
}

// Week Days Row

class WeekDaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final Function(int day) onDayToggle;

  WeekDaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggle,
  });

  final List<String> days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        final bool isSelected = selectedDays.contains(index);

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
            foregroundColor: isSelected
                ? colorScheme.onPrimary
                : isDark
                ? colorScheme.onPrimary
                : colorScheme.primary,

            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
          ),
          onPressed: () => onDayToggle(index),
          child: Text(
            days[index],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }
}

String timeOfDayToApi(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m'; // ✅ 24-hour, backend-safe
}



String formatTimeOfDayAmPm(TimeOfDay t) {
  final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}





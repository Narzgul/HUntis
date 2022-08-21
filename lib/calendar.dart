
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat calendarFormat = CalendarFormat.week;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;


  @override
  Widget build(BuildContext context) {

    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2022, 8, 10),
      lastDay: DateTime.utc(2023, 6, 30),
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week',
        CalendarFormat.twoWeeks: 'Two Weeks',
        CalendarFormat.month: 'Month',
      },
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            selectedDay = selectedDay;
            focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (calendarFormat != format) {
          // Call `setState()` when updating calendar format
          setState(() {
            calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        focusedDay = focusedDay;
      },
    );
  }
}

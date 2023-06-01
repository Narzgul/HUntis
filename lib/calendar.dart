import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/period_list.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Period>> _selectedPeriods;
  CalendarFormat calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late Session untisSession;
  List<String> _mySubjects = [];

  List<Period> timetable = [];

  @override
  void initState() {
    super.initState();

    try {
      _initTimeTable().then(
        (value) {
          setState(() {
            timetable = value;
          });
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("An error has occurred: $e"),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    _selectedPeriods = ValueNotifier(_getEventsForDay(_focusedDay));
  }

  Future<List<Period>> _initTimeTable() async {
    GetIt getIt = GetIt.instance;
    untisSession = getIt<Session>();
    if (!untisSession.isLoggedIn) {
      await untisSession.login();
    }
    var userId = untisSession.userId;
    return await untisSession.getTimetable(
      userId!,
      startDate: DateTime(2022, 8, 22),
      endDate: DateTime(2023, 5, 30),
      useCache: true,
    );
  }

  Future<void> _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('mySubjects');
    if (list != null) {
      _mySubjects = list;
    }
  }

  List<Period> _getEventsForDay(DateTime day) {
    List<Period> periods = [];

    // Filter for relevant Subjects
    _loadSubjects();
    for (Period period in timetable) {
      if (isSameDay(period.startTime, day) &&
          _mySubjects.contains(period.name)) {
        periods.add(period);
      }
    }

    return periods;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Period>(
          focusedDay: _focusedDay,
          firstDay: DateTime(2022, 8, 10),
          lastDay: DateTime(2023, 6, 21),
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: calendarFormat,
          weekendDays: const [DateTime.saturday, DateTime.sunday],
          availableCalendarFormats: const {
            CalendarFormat.week: 'Week',
            CalendarFormat.twoWeeks: 'Two Weeks',
            CalendarFormat.month: 'Month',
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
              });
            }
            _selectedPeriods.value = _getEventsForDay(_selectedDay);
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
            _focusedDay = focusedDay;
          },
        ),
        Expanded(
          child: ValueListenableBuilder<List<Period>>(
            valueListenable: _selectedPeriods,
            builder: (context, selectedPeriods, _) {
              return PeriodList(
                periods: selectedPeriods,
              );
            },
          ),
        ),
      ],
    );
  }
}

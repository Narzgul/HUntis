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

    _initTimeTable().then(
      (value) {
        // Update values once they are ready
        setState(() {
          timetable = value;
          _selectedPeriods.value = _getEventsForDay(_selectedDay);
        });
      },
    );
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
      endDate: DateTime(2023, 6, 21),
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
            // Update timetable
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
            _focusedDay = focusedDay;
          },
        ),
        Expanded(
          child: GestureDetector(
            // Swipe to change day
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe left
                setState(() {
                  _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                });
              } else if (details.primaryVelocity! < 0) {
                // Swipe right
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 1));
                });
              }
              _focusedDay = _selectedDay;
              _selectedPeriods.value =
                  _getEventsForDay(_selectedDay); // Update timetable
            },
            child: ValueListenableBuilder<List<Period>>(
              valueListenable: _selectedPeriods,
              builder: (context, selectedPeriods, _) {
                if (selectedPeriods.isEmpty) {
                  if (timetable.isEmpty) {
                    // Waiting for values from API
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    // No lessons found for this day
                    return Container(
                      color: Colors.grey[300],
                      // Also makes whole area draggable
                      child: const Center(
                        child: Text("No lessons found for this day"),
                      ),
                    );
                  }
                } else {
                  return PeriodList(
                    periods: selectedPeriods,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

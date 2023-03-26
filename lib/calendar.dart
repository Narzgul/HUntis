import 'package:flutter/material.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    untisSession = await Session.init(
      prefs.getString('serverURL') ?? '',
      prefs.getString('school') ?? '',
      prefs.getString('username') ?? '',
      prefs.getString('password') ?? '',
    );
    untisSession.cacheDisposeTime = 15;
    untisSession.cacheLengthMaximum = 40; // Twice the default (?)
    var userId = untisSession.userId;
    return await untisSession.getTimetable(
      userId!,
      startDate: DateTime(2022, 8, 22),
      endDate: DateTime(2023, 5, 30),
      useCache: false,
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
          lastDay: DateTime(2023, 5, 30),
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
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  print(value[index].teacherIds);
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                      color: value[index].isCancelled ? Colors.blue : Colors.white,
                    ),
                    child: ListTile(
                      title: Text(value[index].name),
                      subtitle: Text(value[index].getStartEndTime()),
                      trailing: Text(value[index].teachername),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

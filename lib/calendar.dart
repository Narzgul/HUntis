import 'package:flutter/material.dart';
import 'package:huntis/untis.dart';
import 'package:huntis/untis_api.dart';
import 'package:huntis/auth/secrets.dart';
import 'package:table_calendar/table_calendar.dart';

import 'auth/my_subjects.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key, required this.untis}) : super(key: key);
  final Untis untis;

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Period>> _selectedPeriods;
  CalendarFormat calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Session untisSession;
  late List<Subject> allSubjects;

  List<Period> timetable = [];

  @override
  void initState() {
    super.initState();

    _initTimeTable().then(
      (value) {
        setState(() {
          timetable = value;
        });
      },
    );
    _selectedPeriods = ValueNotifier(_getEventsForDay(_focusedDay));
  }

  Future<List<Period>> _initTimeTable() async {
    untisSession = await Session.init(
        unitsCredentials['server']!,
        unitsCredentials['school']!,
        unitsCredentials['username']!,
        unitsCredentials['password']!);
    untisSession.cacheDisposeTime = 15;
    untisSession.cacheLengthMaximum = 40; // Twice the default (?)
    allSubjects = await untisSession.getSubjects(); // TODO: Move to own func
    var userId = untisSession.userId;
    return await untisSession.getTimetable(userId!,
        startDate: DateTime(2022, 8, 22),
        endDate: DateTime(2023, 5, 30),
        useCache: true);
  }

  String _getSubject(int id) {
    //Name of first Subject with matching ID
    return allSubjects.where((element) => element.id.id == id).first.name;
  }

  List<Period> _getEventsForDay(DateTime day) {
    List<Period> periods = [];

    for (Period period in timetable) {
      if (isSameDay(period.startTime, day) &&
          mySubjects.contains(_getSubject(period.subjectIds[0].id))) {
        periods.add(period);
      }
    }

    // Sort by time
    periods.sort((a, b) {
      return a.startTime.compareTo(b.startTime);
    });

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
          // eventLoader: untis,
          calendarFormat: calendarFormat,
          weekendDays: const [DateTime.saturday, DateTime.sunday],
          availableCalendarFormats: const {
            CalendarFormat.week: 'Woche',
            CalendarFormat.twoWeeks: 'Zwei Wochen',
            CalendarFormat.month: 'Monat',
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
                focusedDay = focusedDay;
              });
            }
            _selectedPeriods.value = _getEventsForDay(_selectedDay!);
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
        ),
        Expanded(
          child: ValueListenableBuilder<List<Period>>(
            valueListenable: _selectedPeriods,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(_getSubject(value[index].subjectIds[0].id)),
                      subtitle: Text(value[index].getStartEndTime()),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huntis/untis.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Period>> _selectedPeriods;
  CalendarFormat calendarFormat = CalendarFormat.week;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
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
    _selectedPeriods = ValueNotifier(_getEventsForDay(focusedDay));
  }

  Future<List<Period>> _initTimeTable() async {
    untisSession = await Session.init(
        'ajax.webuntis.com', // Server
        'lindengym-gummersbach', // School
        'GuittoTit', // Username
        '''<&5o'02d]CmimV"x-Z\$3\$1U~<\\7D;'''); // Password
    allSubjects = await untisSession.getSubjects(); // TODO: Move to own func
    var userId = untisSession.userId;
    return await untisSession.getTimetable(userId!,
        startDate: DateTime(2022, 8, 22), endDate: DateTime(2023, 5, 30));
  }

  String _getSubject(int id) {
    //Name of first Subject with matching ID
    return allSubjects.where((element) => element.id.id == id).first.name;
  }

  List<Period> _getEventsForDay(DateTime day) {
    List<Period> periods = [];

    for (Period period in timetable) {
      if (isSameDay(period.startTime, day)) {
        periods.add(period);
      }
    }

    //print("Periods for $day: $periods");
    return periods;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Period>(
          focusedDay: focusedDay,
          firstDay: DateTime(2022, 8, 10),
          lastDay: DateTime(2023, 5, 30),
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: _getEventsForDay,
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
            _selectedPeriods.value = _getEventsForDay(selectedDay);
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
                itemBuilder: (context, index) {
                  return Text(_getSubject(value[index].subjectIds[0].id));
                },
                shrinkWrap: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

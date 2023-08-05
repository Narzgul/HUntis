import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/period_list.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final Session untisSession;
  final Schoolyear schoolYear;
  final List<Period> timetable;
  final List<String> mySubjects;
  final Map<String, Color> mySubjectColors;
  final Map<String, String> mySubjectNames;

  const Calendar({
    Key? key,
    required this.untisSession,
    required this.schoolYear,
    required this.timetable,
    required this.mySubjects,
    required this.mySubjectColors,
    required this.mySubjectNames,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Period>> _selectedPeriods;
  CalendarFormat calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay, _selectedDay;

  @override
  void initState() {
    super.initState();

    // Set initial focused and selected day to within the school year
    if (DateTime.now().isAfter(widget.schoolYear.endDate)) {
      _focusedDay = widget.schoolYear.endDate;
      _selectedDay = widget.schoolYear.endDate;
    } else if (DateTime.now().isBefore(widget.schoolYear.startDate)) {
      _focusedDay = widget.schoolYear.startDate;
      _selectedDay = widget.schoolYear.startDate;
    } else {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    }

    // _selectedPeriods updates when _focusedDay changes
    _selectedPeriods = ValueNotifier(_getEventsForDay(_focusedDay));
  }

  List<Period> _getEventsForDay(DateTime day) {
    List<Period> periods = [];

    // Filter for Subjects on that day
    for (Period period in widget.timetable) {
      if (isSameDay(period.startTime, day)) {
        periods.add(period);
      }
    }

    return periods;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          TableCalendar<Period>(
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              weekendStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              outsideTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              defaultTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              weekNumberTextStyle: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonShowsNext: false,
              titleTextStyle: TextStyle(
                fontSize: 17,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            weekNumbersVisible: true,
            focusedDay: _focusedDay,
            firstDay: widget.schoolYear.startDate,
            lastDay: widget.schoolYear.endDate,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: calendarFormat,
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
                    _selectedDay =
                        _selectedDay.subtract(const Duration(days: 1));

                    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
                    if (prefs.getBool('skipWeekends') ?? false) {
                      // Skip weekends
                      while (_selectedDay.weekday == DateTime.saturday ||
                          _selectedDay.weekday == DateTime.sunday) {
                        _selectedDay =
                            _selectedDay.subtract(const Duration(days: 1));
                      }
                    }
                    if (_selectedDay.isBefore(widget.schoolYear.startDate)) {
                      _selectedDay = widget.schoolYear.startDate;
                    }
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe right
                  setState(() {
                    _selectedDay = _selectedDay.add(const Duration(days: 1));

                    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
                    if (prefs.getBool('skipWeekends') ?? false) {
                      // Skip weekends
                      while (_selectedDay.weekday == DateTime.saturday ||
                          _selectedDay.weekday == DateTime.sunday) {
                        _selectedDay =
                            _selectedDay.add(const Duration(days: 1));
                      }
                    }
                    if (_selectedDay.isAfter(widget.schoolYear.endDate)) {
                      _selectedDay = widget.schoolYear.endDate;
                    }
                  });
                }
                _focusedDay = _selectedDay;
                _selectedPeriods.value =
                    _getEventsForDay(_selectedDay); // Update timetable
              },
              child: ValueListenableBuilder<List<Period>>(
                valueListenable: _selectedPeriods,
                builder: (context, selectedPeriods, _) {
                  if (widget.mySubjects.isEmpty) {
                    // No subjects set
                    return Container(
                      color: Colors.red[300],
                      // Also makes whole area draggable
                      child: const Center(
                        child: Text("Set your subjects in the settings"),
                      ),
                    );
                  }
                  if (selectedPeriods.isEmpty) {
                    if (widget.timetable.isEmpty) {
                      // Got no date from the API
                      return Container(
                        color: Colors.red[300],
                        // Also makes whole area draggable
                        child: const Center(
                          child: Text("Got no data from the API"),
                        ),
                      );
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
                    // Got lessons for this day
                    return PeriodList(
                      periods: selectedPeriods,
                      mySubjectColors: widget.mySubjectColors,
                      mySubjectNames: widget.mySubjectNames,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

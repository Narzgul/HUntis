import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/components/period_list.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'components/time_bar.dart';

class Calendar extends StatefulWidget {
  final Session untisSession;
  final Schoolyear schoolYear;
  final List<Period> timetable;
  final TimeGrid timegrid;
  final List<String> mySubjects;
  final Map<String, Color> mySubjectColors;
  final Map<String, String> mySubjectNames;

  const Calendar({
    Key? key,
    required this.untisSession,
    required this.schoolYear,
    required this.timetable,
    required this.timegrid,
    required this.mySubjects,
    required this.mySubjectColors,
    required this.mySubjectNames,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<DateTime> _selectedDayChanged;
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

    // _selectedDayChanged updates when _focusedDay changes
    _selectedDayChanged = ValueNotifier(_focusedDay);
  }

  bool setDay(DateTime day) {
    if (day.isBefore(widget.schoolYear.startDate) ||
        day.isAfter(widget.schoolYear.endDate)) {
      return false;
    } else {
      setState(() {
        _selectedDay = day;
        _focusedDay = day;
        _selectedDayChanged.value = day;
      });
      return true;
    }
  }

  bool moveDay(int days) {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    bool didChange = setDay(_selectedDay.add(Duration(days: days)));
    if (prefs.getBool('skipWeekends') ?? false) {
      // Skip weekends
      while ((_selectedDay.weekday == DateTime.saturday ||
              _selectedDay.weekday == DateTime.sunday) &&
          didChange) {
        didChange = setDay(_selectedDay.add(Duration(days: days)));
      }
    }
    return didChange;
  }

  Future<List<Period>> _getEventsForDay(DateTime day) async {
    List<Period> periods = [];

    // Filter for Subjects on that day
    List<Period> allPeriodsForDay =
        await widget.untisSession.getPeriods(startDate: day);
    for (var period in allPeriodsForDay) {
      if (widget.mySubjects.contains(period.subject?.name)) {
        periods.add(period);
      }
    }

    return periods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Period>(
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
              weekendStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
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
              selectedTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              todayTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              weekendTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
              outsideTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
              defaultTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
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
            availableCalendarFormats: {
              CalendarFormat.week: 'calendar-page.week'.tr(),
              CalendarFormat.twoWeeks: 'calendar-page.two-weeks'.tr(),
              CalendarFormat.month: 'calendar-page.month'.tr(),
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setDay(selectedDay),
            onFormatChanged: (format) {
              if (calendarFormat != format) {
                setState(() {
                  calendarFormat = format;
                });
              }
            },
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Swipe to change day
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe left
                  moveDay(-1);
                } else if (details.primaryVelocity! < 0) {
                  // Swipe right
                  moveDay(1);
                }
              },
              child: ValueListenableBuilder<DateTime>(
                valueListenable: _selectedDayChanged,
                builder: (context, selectedDay, _) {
                  if (widget.mySubjects.isEmpty) {
                    // No subjects set
                    return Center(
                      child: Text("messages.set-subjects".tr()),
                    );
                  }
                  return FutureBuilder(
                    future: _getEventsForDay(selectedDay),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Period>> snapshot) {
                      if (snapshot.hasData) {
                        List<Period> selectedPeriods = snapshot.data!;
                        if (selectedPeriods.isEmpty) {
                          if (widget.timetable.isEmpty) {
                            // Got no date from the API
                            return Center(
                              child: Text("messages.no-api-data".tr()),
                            );
                          } else {
                            // No lessons found for this day
                            return Center(
                              child: Text("messages.no-lessons".tr()),
                            );
                          }
                        } else {
                          // Got lessons for this day
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: TimeBar(
                                        timeGrid: widget.timegrid,
                                        periods: selectedPeriods,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth - 50,
                                      child: PeriodList(
                                        periods: selectedPeriods,
                                        mySubjectColors: widget.mySubjectColors,
                                        mySubjectNames: widget.mySubjectNames,
                                        timeGrid: widget.timegrid,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      } else {
                        // Loading
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //onPressed: () => setDay(DateTime.now()),
        onPressed: () => GetIt.instance<Session>().logout(),
        tooltip: 'calendar-page.today'.tr(),
        child: const Icon(Icons.today),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

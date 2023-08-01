import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/calendar.dart';
import 'package:huntis/untis_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Session untisSession;
  late Schoolyear schoolYear;
  late List<Period> timetable;
  late List<String> mySubjects;
  late Map<String, Color> mySubjectColors;

  bool hasLoginData() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    return prefs.containsKey('serverURL') &&
        prefs.containsKey('school') &&
        prefs.containsKey('username') &&
        prefs.containsKey('password');
  }

  Future<void> _doAPICalls() async {
    GetIt getIt = GetIt.instance;
    untisSession = getIt<Session>();
    if (!untisSession.isLoggedIn) {
      await untisSession.login();
    }

    // Get latest school year
    var allSchoolYears = await untisSession.getSchoolyears();
    allSchoolYears.sort((a, b) => a.endDate.compareTo(b.endDate));
    schoolYear = allSchoolYears.last;

    timetable = await untisSession.getTimetable(
      untisSession.userId!,
      startDate: schoolYear.startDate,
      endDate: schoolYear.endDate,
      useCache: true,
    );

    mySubjects = _getMySubjects();
    // Filter Timetable for mySubjects
    timetable = timetable
        .where((element) => mySubjects.contains(element.name))
        .toList();

    mySubjectColors = _getSubjectColors();
  }

  Map<String, Color> _getSubjectColors() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String>? colors = prefs.getStringList('mySubjectColors');
    Map<String, Color> mySubjectColors = {
      for (var e in colors ?? [])
        e.split(':')[0]: Color(int.parse(e.split(':')[1], radix: 16))
    };
    return mySubjectColors;
  }

  List<String> _getMySubjects() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String>? mySubjects = prefs.getStringList('mySubjects');
    return mySubjects ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLoginData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your login data in the settings'),
        ),
      );
      return const Center(
        child: Text('No login data found'),

      );
    } else {
      return FutureBuilder(
      future: _doAPICalls(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Calendar(
            untisSession: untisSession,
            schoolYear: schoolYear,
            timetable: timetable,
            mySubjects: mySubjects,
            mySubjectColors: mySubjectColors,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
    }
  }
}

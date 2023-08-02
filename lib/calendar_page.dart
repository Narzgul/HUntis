import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:huntis/calendar.dart';
import 'package:huntis/components/login_button.dart';
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
    bool notNull = prefs.getString('serverURL') != null &&
        prefs.getString('school') != null &&
        prefs.getString('username') != null &&
        prefs.getString('password') != null;
    bool notEmpty = prefs.getString('serverURL') != '' &&
        prefs.getString('school') != '' &&
        prefs.getString('username') != '' &&
        prefs.getString('password') != '';
    return notNull && notEmpty;
  }

  Future<void> _doAPICalls() async {
    GetIt getIt = GetIt.instance;
    untisSession = getIt<Session>();
    await untisSession.login();

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
    GetIt getIt = GetIt.instance;
    if (!hasLoginData()) {
      return const Center(
        child: Text('No login data found'),
      );
    } else if (!getIt.isRegistered<Session>() || !getIt<Session>().isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are not logged in'),
            LoginButton(context: context),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Reload'),
            ),
          ],
        ),
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

import 'package:easy_localization/easy_localization.dart';
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
  late Timegrid timegrid;
  late List<String> mySubjects;
  late Map<String, Color> mySubjectColors;
  late Map<String, String> mySubjectNames;

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

    // Set startDate and endDate
    late DateTime startDate, endDate;
    if (DateTime.now()
        .add(const Duration(days: 30))
        .isAfter(schoolYear.endDate)) {
      // If today is after or within the last 30 days of the school year
      startDate = schoolYear.endDate.subtract(const Duration(days: 30));
      endDate = schoolYear.endDate;
    } else if (DateTime.now().subtract(const Duration(days: 30)).isBefore(schoolYear.startDate)) {
      // If today is before or within the first 30 days of the school year
      startDate = schoolYear.startDate;
      endDate = schoolYear.startDate.add(const Duration(days: 30));
    } else {
      startDate = DateTime.now().subtract(const Duration(days: 15));
      endDate = DateTime.now().add(const Duration(days: 15));
    }
    timetable = await untisSession.getPeriods(
      startDate: startDate,
      endDate: endDate,
    );

    mySubjects = _getMySubjects();
    // Filter Timetable for mySubjects
    timetable = timetable
        .where((element) => mySubjects.contains(element.name))
        .toList();

    timegrid = await untisSession.getTimegrid();

    mySubjectColors = _getSubjectColors();
    mySubjectNames = _getSubjectNames();
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

  Map<String, String> _getSubjectNames() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String>? names = prefs.getStringList('mySubjectNames');
    Map<String, String> mySubjectNames = {
      for (var e in names ?? [])
        e.split(':')[0]: e.split(':')[1]
    };
    return mySubjectNames;
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
      return Center(
        child: Text('missing-login-data'.tr()),
      );
    } else if (!getIt.isRegistered<Session>() || !getIt<Session>().isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('not-logged-in'.tr()),
            LoginButton(context: context),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: Text('reload'.tr()),
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
              timegrid: timegrid,
              mySubjects: mySubjects,
              mySubjectColors: mySubjectColors,
              mySubjectNames: mySubjectNames,
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

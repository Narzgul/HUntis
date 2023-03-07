import 'package:huntis/untis_api.dart';
import 'package:table_calendar/table_calendar.dart';

import 'auth/secrets.dart';
import 'auth/my_subjects.dart';

class Untis {
  late Session untisSession;
  late List<Subject> allSubjects;
  late IdProvider userId;
  late List<Period> timetable;

  Untis() {
    init();
  }

  Future<void> init() async {
    untisSession = await Session.init(
        unitsCredentials['server']!,
        unitsCredentials['school']!,
        unitsCredentials['username']!,
        unitsCredentials['password']!);
    untisSession.cacheDisposeTime = 15; // Half the default
    untisSession.cacheLengthMaximum = 40; // Twice the default (?)
    allSubjects = await untisSession.getSubjects();
    userId = untisSession.userId!;
    timetable = await untisSession.getTimetable(userId,
        startDate: DateTime(2022, 8, 22),
        endDate: DateTime(2023, 5, 30),
        useCache: true);
  }

  Future<List<Period>> getTimetable(
      DateTime startDate, DateTime endDate) async {
    return await untisSession.getTimetable(userId,
        startDate: startDate, endDate: endDate, useCache: true);
  }

  String getSubjectName(int id) {
    //Name of first Subject with matching ID
    return allSubjects.where((element) => element.id.id == id).first.name;
  }

  List<Period> getEventsForDay(DateTime day) {
    List<Period> periods = [];

    for (Period period in timetable) {
      if (isSameDay(period.startTime, day)) {
        periods.add(period);
      }
    }

    return periods;
  }
}

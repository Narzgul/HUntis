import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../untis_api.dart';

class SubjectList extends StatefulWidget {
  const SubjectList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  List<String> _mySubjects = [];
  Map<String, Color> _mySubjectColors = {};

  Future<void> _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mySubjects', _mySubjects);
    List<String> mySubjectColorsList = [];
    _mySubjectColors.forEach(
      (key, value) =>
          mySubjectColorsList.add("$key:${value.value.toRadixString(16)}"),
    );
    await prefs.setStringList(
      'mySubjectColors',
      mySubjectColorsList,
    );
  }

  Future<void> _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('mySubjects');
    List<String>? colors = prefs.getStringList('mySubjectColors');
    _mySubjectColors = {
      for (var e in colors ?? [])
        // Decode color map from hex string
        e.split(':')[0]: Color(int.parse(e.split(':')[1], radix: 16))
    };
    if (list != null) {
      _mySubjects = list;
    }
  }

  Future<List<String>> _getAvailableSubjects() async {
    GetIt getIt = GetIt.instance;
    var untisSession = getIt<Session>();
    if (!untisSession.isLoggedIn) {
      await untisSession.login();
    }

    var userId = untisSession.userId;

    // Get latest school year
    var allSchoolYears = await untisSession.getSchoolyears();
    allSchoolYears.sort((a, b) => a.endDate.compareTo(b.endDate));
    Schoolyear schoolYear = allSchoolYears.last;

    late DateTime startDate, endDate;

    if (DateTime.now()
        .add(const Duration(days: 30))
        .isAfter(schoolYear.endDate)) {
      // If today is after or within the last 30 days of the school year
      startDate = schoolYear.endDate.subtract(const Duration(days: 30));
      endDate = schoolYear.endDate;
    } else if (DateTime.now().isBefore(schoolYear.startDate)) {
      // If today is before or within the first 30 days of the school year
      startDate = schoolYear.startDate;
      endDate = schoolYear.startDate.add(const Duration(days: 30));
    } else {
      startDate = DateTime.now().subtract(const Duration(days: 15));
      endDate = DateTime.now().add(const Duration(days: 15));
    }

    List<Period> timetable = await untisSession.getTimetable(
      userId!,
      startDate: startDate,
      endDate: endDate,
      useCache: false,
    );

    List<String> relevantSubjects = [];
    for (Period period in timetable) {
      if (!relevantSubjects.contains(period.name)) {
        relevantSubjects.add(period.name);
      }
    }
    relevantSubjects.sort(); // Sort alphabetically

    return relevantSubjects;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
    _loadSubjects();
    return FutureBuilder<List<String>>(
      future: _getAvailableSubjects(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<String>> snapshot,
      ) {
        if (snapshot.hasData) {
          List<String> availableSubjects = snapshot.data!;
          return ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: availableSubjects.length,
            itemBuilder: (BuildContext context, int index) {
              return CheckboxListTile(
                title: Text(snapshot.data![index]),
                value: _mySubjects.contains(availableSubjects[index]),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _mySubjects.add(availableSubjects[index]);
                      _mySubjectColors[availableSubjects[index]] = Colors.green;
                    } else {
                      _mySubjects.remove(snapshot.data![index]);
                      _mySubjectColors.remove(snapshot.data![index]);
                    }
                  });
                  _saveSubjects();
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

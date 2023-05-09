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

  Future<void> _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mySubjects', _mySubjects);
  }

  Future<void> _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('mySubjects');
    if (list != null) {
      _mySubjects = list;
    }
  }

  Future<List<String>> _getSubjects() async {
    GetIt getIt = GetIt.instance;
    var untisSession = getIt<Session>();
    if (!untisSession.isLoggedIn) {
      await untisSession.login();
    }

    var userId = untisSession.userId;
    List<Period> timetable = await untisSession.getTimetable(
      userId!,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 30)),
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
      future: _getSubjects(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<String>> snapshot,
      ) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return CheckboxListTile(
                title: Text(snapshot.data![index]),
                value: _mySubjects.contains(snapshot.data![index]),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _mySubjects.add(snapshot.data![index]);
                    } else {
                      _mySubjects.remove(snapshot.data![index]);
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

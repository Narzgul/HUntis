import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectNameList extends StatefulWidget {
  const SubjectNameList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectNameListState();
}

class _SubjectNameListState extends State<SubjectNameList> {
  void _saveSubjects(Map<String, String> mySubjectNames) {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String> mySubjectNamesList = [];
    mySubjectNames.forEach(
      (key, value) => mySubjectNamesList.add("$key:$value"),
    );
    prefs.setStringList(
      'mySubjectNames',
      mySubjectNamesList,
    );
  }

  Map<String, String> _loadSubjectNames() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String>? names = prefs.getStringList('mySubjectNames');
    Map<String, String> mySubjectNames = {
      for (var e in names ?? []) e.split(':')[0]: e.split(':')[1]
    };

    // Add missing subject names
    // This is needed because the subject name list was added later
    List<String> mySubjects = prefs.getStringList('mySubjects') ?? [];
    for (var subject in mySubjects) {
      if (!mySubjectNames.containsKey(subject)) {
        mySubjectNames[subject] = subject;
      }
    }

    return mySubjectNames;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
    Map<String, String> mySubjectNames = _loadSubjectNames();
    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: mySubjectNames.length,
      itemBuilder: (BuildContext context, int index) {
        MapEntry<String, String> element =
            mySubjectNames.entries.elementAt(index);
        TextEditingController textController = TextEditingController();
        textController.text = element.value;
        textController.addListener(() {
          mySubjectNames[element.key] = textController.text;
          _saveSubjects(mySubjectNames);
        });
        return TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: element.key,
            hintText: element.value,
          ),
          initialValue: element.value,
          onChanged: (value) {
            mySubjectNames[element.key] = value;
            _saveSubjects(mySubjectNames);
          },
        );
      },
    );
  }
}

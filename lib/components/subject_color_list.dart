import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectColorList extends StatefulWidget {
  const SubjectColorList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectColorListState();
}

class _SubjectColorListState extends State<SubjectColorList> {
  Future<void> _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('mySubjects');
    if (list != null) {
    }
  }

  Future<Map<String, Color>> _getSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? subjects = prefs.getStringList('mySubjects');
    List<Color>? colors = prefs
        .getStringList('mySubjectColors')
        ?.map((e) => Color(int.parse(e, radix: 16)))
        .toList();
    if (subjects != null && colors != null) {
      return Map.fromIterables(subjects, colors);
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
    _loadSubjects();
    return FutureBuilder<Map<String, Color>>(
      future: _getSubjects(),
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<String, Color>> snapshot,
      ) {
        if (snapshot.hasData) {
          Map<String, Color> subjects = snapshot.data!;
          return ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: subjects.length,
            itemBuilder: (BuildContext context, int index) {
              MapEntry<String, Color> element =
                  subjects.entries.elementAt(index);
              return ListTile(
                title: Text(element.key),
                trailing: Container(
                  width: 30,
                  height: 30,
                  color: element.value,
                ),
                onTap: () async {
                  Color? newColor = await showDialog<Color>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color!'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: element.value,
                            onColorChanged: (Color color) {
                              element = MapEntry(element.key, color);
                            },
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Save'),
                            onPressed: () {
                              Navigator.of(context).pop(element.value);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (newColor != null) {
                    subjects[element.key] = newColor;
                    List<String> subjectsList = [];
                    List<String> colorsList = [];
                    subjects.forEach((key, value) {
                      subjectsList.add(key);
                      colorsList.add(value.value.toRadixString(16));
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setStringList('mySubjects', subjectsList);
                    await prefs.setStringList('mySubjectColors', colorsList);
                    setState(() {});
                  }
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

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
  List<String> _mySubjects = [];
  Map<String, Color> _mySubjectColors = {};

  Future<void> _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    print(colors);
    _mySubjectColors = {
      for (var e in colors ?? [])
        e.split(':')[0]: Color(int.parse(e.split(':')[1], radix: 16))
    };
    if (list != null) {
      _mySubjects = list;
    }
  }

  Future<Map<String, Color>> _getSubjects() async {
    await _loadSubjects();
    return _mySubjectColors;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
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
                    _mySubjectColors[element.key] = newColor;
                    _saveSubjects();
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

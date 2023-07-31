import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectColorList extends StatefulWidget {
  const SubjectColorList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubjectColorListState();
}

class _SubjectColorListState extends State<SubjectColorList> {
  void _saveSubjects(Map<String, Color> mySubjectColors) {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String> mySubjectColorsList = [];
    mySubjectColors.forEach(
      (key, value) =>
          mySubjectColorsList.add("$key:${value.value.toRadixString(16)}"),
    );
    prefs.setStringList(
      'mySubjectColors',
      mySubjectColorsList,
    );
  }

  Map<String, Color> _loadSubjectColors() {
    SharedPreferences prefs = GetIt.instance<SharedPreferences>();
    List<String>? colors = prefs.getStringList('mySubjectColors');
    Map<String, Color> mySubjectColors = {
      for (var e in colors ?? [])
        e.split(':')[0]: Color(int.parse(e.split(':')[1], radix: 16))
    };
    return mySubjectColors;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Crashes app if not used :(
    Map<String, Color> mySubjectColors = _loadSubjectColors();
    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: mySubjectColors.length,
      itemBuilder: (BuildContext context, int index) {
        MapEntry<String, Color> element =
        mySubjectColors.entries.elementAt(index);
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
              mySubjectColors[element.key] = newColor;
              _saveSubjects(mySubjectColors);
              setState(() {});
            }
          },
        );
      },
    );
  }
}

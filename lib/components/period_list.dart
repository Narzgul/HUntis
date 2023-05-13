import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../untis_api.dart';

class PeriodList extends StatelessWidget {
  final List<Period> periods;

  PeriodList({Key? key, required this.periods}) : super(key: key);

  Future<List<Color>> _getSubjectColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Color>? colors = prefs
        .getStringList('mySubjectColors')
        ?.map((e) => Color(int.parse(e, radix: 16)))
        .toList();
    List<String>? subjects = prefs.getStringList('mySubjects');
    List<Color> periodColors = [];
    if (subjects == null || colors == null) {
      return periodColors;
    }
    for (Period period in periods) {
      periodColors.add(colors[subjects.indexOf(period.name)]);
    }
    return periodColors;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Color>>(
        future: _getSubjectColors(),
        builder: (BuildContext context, AsyncSnapshot<List<Color>> snapshot) {
          if (snapshot.hasData && snapshot.data?.length == periods.length) {
            List<Color> periodColors = snapshot.data!;
            return ListView.builder(
              itemCount: periods.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                    color: periods[index].isCancelled
                        ? Colors.blue
                        : periodColors[index],
                  ),
                  child: ListTile(
                    title: Text(periods[index].name),
                    subtitle: Text(periods[index].getStartEndTime()),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        periods[index].isCancelled
                            ? const Text("Cancelled")
                            : Text(periods[index].teacherName),
                        const Spacer(),
                        Text(periods[index].roomName),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading subject colors'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

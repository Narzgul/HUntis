import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../untis_api.dart';

class PeriodList extends StatelessWidget {
  final List<Period> periods;

  const PeriodList({Key? key, required this.periods}) : super(key: key);

  Future<Map<String, Color>> _getSubjectColors() async {
    Map<String, Color> mySubjectColors = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? colors = prefs.getStringList('mySubjectColors');
    mySubjectColors = {
      for (var e in colors ?? [])
        e.split(':')[0]: Color(int.parse(e.split(':')[1], radix: 16))
    };
    return mySubjectColors;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Color>>(
      future: _getSubjectColors(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, Color>> snapshot) {
        if (snapshot.hasData) {
          Map<String, Color> periodColors = snapshot.data!;
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
                      : periodColors[periods[index].name],
                ),
                child: ListTile(
                  title: periods[index].isCancelled
                      ? Text(
                          periods[index].name,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(periods[index].name),
                  subtitle: Text(periods[index].getStartEndTime()),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      periods[index].isCancelled
                          ? const Text(
                              "Cancelled",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
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
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../untis_api.dart';

String teacherInfo(Teacher? teacher) {
  if (teacher == null) {
    return 'No teacher';
  }
  if (teacher.title == null || teacher.title == '') {
    return '${teacher.foreName} ${teacher.surName} (${teacher.shorthand})';
  }
  return '${teacher.title} ${teacher.foreName} ${teacher.surName} (${teacher.shorthand})';
}

String roomInfo(Room? room) {
  if (room == null) {
    return 'No room';
  }
  return '${room.longName} (${room.name})';
}

class PeriodInfo extends SimpleDialog {
  final Period period;

  PeriodInfo(
      {super.key,
      required this.period,
      required Color textColor,
      required Color backgroundColor})
      : super(
          title: Text(
            'Info',
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          children: [
            ListTile(
              title: Text(
                'Subject',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                period.name,
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              title: Text(
                'Teacher',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                teacherInfo(period.teacher),
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              title: Text(
                'Room',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                roomInfo(period.room),
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              title: Text(
                'Time',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                period.startEndTimeString(),
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        );
}

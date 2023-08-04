import 'package:flutter/material.dart';

import '../untis_api.dart';

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
                period.teacherName,
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              title: Text(
                'Room',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                period.roomName,
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              title: Text(
                'Time',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                period.getStartEndTime(),
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        );
}

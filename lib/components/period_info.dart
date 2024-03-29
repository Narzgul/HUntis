import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../untis_api.dart';

String teacherInfo(Teacher? teacher) {
  if (teacher == null) {
    return 'messages.period-info.no-teacher'.tr();
  }
  if (teacher.title == null || teacher.title == '') {
    return '${teacher.foreName} ${teacher.surName} (${teacher.shorthand})';
  }
  return '${teacher.title} ${teacher.foreName} ${teacher.surName} (${teacher.shorthand})';
}

String roomInfo(Room? room) {
  if (room == null) {
    return 'messages.period-info.no-room'.tr();
  }
  return '${room.longName} (${room.name})';
}

String subjectInfo(Period? period, Map<String, String> mySubjectNames) {
  if (period == null) {
    return 'messages.period-info.no-subject'.tr();
  }
  return '${mySubjectNames[period.name] ?? period.name} (${period.name})';
}

class PeriodInfo extends SimpleDialog {
  final Period period;

  PeriodInfo({
    super.key,
    required this.period,
    required Color textColor,
    required Color backgroundColor,
    required Map<String, String> mySubjectNames,
  }) : super(
          title: Text(
            'calendar-page.info'.tr(),
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          children: [
            ListTile(
              leading: Icon(
                Icons.book,
                color: textColor,
              ),
              title: Text(
                'subject'.tr(),
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                subjectInfo(period, mySubjectNames),
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: textColor,
              ),
              title: Text(
                'teacher'.tr(),
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                teacherInfo(period.teacher),
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.room,
                color: textColor,
              ),
              title: Text(
                'calendar-page.room'.tr(),
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                roomInfo(period.room),
                style: TextStyle(color: textColor),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: textColor,
              ),
              title: Text(
                'calendar-page.time'.tr(),
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:huntis/components/period_info.dart';

import '../untis_api.dart';

class PeriodTile extends StatelessWidget {
  const PeriodTile({
    super.key,
    required this.primaryColor,
    required this.mySubjectNames,
    required this.textColor,
    required this.period,
  });

  final Period period;
  final Color primaryColor;
  final Map<String, String> mySubjectNames;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: primaryColor,
      ),
      child: ListTile(
        title: period.isCancelled
            ? Text(
                mySubjectNames[period.name] ?? period.name,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              )
            : Text(
                mySubjectNames[period.name] ?? period.name,
                style: TextStyle(color: textColor),
              ),
        subtitle: Text(period.startEndTimeString(),
            style: TextStyle(color: textColor)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            period.isCancelled
                ? Text(
                    "calendar-page.cancelled".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )
                : Text(
                    period.teacher?.surName ?? '?',
                    style: TextStyle(color: textColor),
                  ),
            const Spacer(),
            Text(
              period.room?.name ?? '?',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return PeriodInfo(
                period: period,
                textColor: textColor,
                backgroundColor: primaryColor,
                mySubjectNames: mySubjectNames,
              );
            },
          );
        },
      ),
    );
  }
}

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
    required this.width,
  });

  final Period period;
  final Color primaryColor;
  final Map<String, String> mySubjectNames;
  final Color textColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: primaryColor,
        ),
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                period.room?.name ?? '?',
                style: TextStyle(color: textColor),
              ),
            ),
            // Period Name
            Center(
              child: period.isCancelled
                  ? Text(
                      mySubjectNames[period.name] ?? period.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    )
                  : Text(
                      mySubjectNames[period.name] ?? period.name,
                      style: TextStyle(fontSize: 18.0, color: textColor),
                    ),
            ),
            // Teacher Name
            Align(
              alignment: Alignment.bottomRight,
              child: period.isCancelled
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
            ),
          ],
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PeriodInfo(
            period: period,
            textColor: textColor,
            backgroundColor: primaryColor,
            mySubjectNames: mySubjectNames,
          ),
        );
      },
    );
  }
}

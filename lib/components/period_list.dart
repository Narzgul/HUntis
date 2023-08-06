import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:huntis/components/period_info.dart';

import '../untis_api.dart';

class PeriodList extends StatelessWidget {
  final List<Period> periods;
  final Map<String, Color> mySubjectColors;
  final Map<String, String> mySubjectNames;

  const PeriodList({
    Key? key,
    required this.periods,
    required this.mySubjectColors,
    required this.mySubjectNames,
  }) : super(key: key);

  Color _getBestTextColor(Color background) {
    // Convert the rgb color values to a 0 to 1 scale
    double red = background.red / 255;
    double green = background.green / 255;
    double blue = background.blue / 255;
    // Get the average color value and check if it's higher than 0.5
    // If it is, the color is a lighter color and the best opposing color is Black
    // If it is not, the color is a darker color and the best opposing color is White
    if ((red + green + blue) / 3.0 > 0.5) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: periods.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Color primaryColor = Theme.of(context).colorScheme.primary;
        if (periods[index].isCancelled) {
          primaryColor = Colors.blue;
        } else if (mySubjectColors.containsKey(periods[index].name)) {
          primaryColor = mySubjectColors[periods[index].name]!;
        }
        Color textColor = _getBestTextColor(primaryColor);

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(12.0),
            color: primaryColor,
          ),
          child: ListTile(
            title: periods[index].isCancelled
                ? Text(
                    mySubjectNames[periods[index].name] ?? periods[index].name,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )
                : Text(
                    mySubjectNames[periods[index].name] ?? periods[index].name,
                    style: TextStyle(color: textColor),
                  ),
            subtitle: Text(periods[index].startEndTimeString(),
                style: TextStyle(color: textColor)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                periods[index].isCancelled
                    ? Text(
                        "calendar-page.cancelled".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )
                    : Text(
                        periods[index].teacher?.surName ?? '?',
                        style: TextStyle(color: textColor),
                      ),
                const Spacer(),
                Text(
                  periods[index].room?.name ?? '?',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return PeriodInfo(
                    period: periods[index],
                    textColor: textColor,
                    backgroundColor: primaryColor,
                    mySubjectNames: mySubjectNames,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

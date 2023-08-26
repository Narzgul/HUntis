import 'package:flutter/material.dart';
import 'package:huntis/components/period_tile.dart';

import '../untis_api.dart';

class PeriodList extends StatelessWidget {
  final List<Period> periods;
  final Map<String, Color> mySubjectColors;
  final Map<String, String> mySubjectNames;
  final Timegrid timegrid;

  const PeriodList({
    Key? key,
    required this.periods,
    required this.mySubjectColors,
    required this.mySubjectNames,
    required this.timegrid,
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

        return PeriodTile(
          period: periods[index],
          primaryColor: primaryColor,
          periods: periods,
          mySubjectNames: mySubjectNames,
          textColor: textColor,
        );
      },
    );
  }
}

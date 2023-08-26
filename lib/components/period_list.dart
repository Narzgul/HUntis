import 'package:flutter/material.dart';
import 'package:huntis/components/period_tile.dart';

import '../untis_api.dart';

class PeriodList extends StatefulWidget {
  final List<Period> periods;
  final Map<String, Color> mySubjectColors;
  final Map<String, String> mySubjectNames;
  final Timegrid timeGrid;

  const PeriodList({
    Key? key,
    required this.periods,
    required this.mySubjectColors,
    required this.mySubjectNames,
    required this.timeGrid,
  }) : super(key: key);

  @override
  State<PeriodList> createState() => _PeriodListState();
}

class _PeriodListState extends State<PeriodList> {
  late DayTime dayStart, dayEnd;

  late double totalHeight;

  late double heightPerMinute;

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

  int getMinutes(DayTime time) => time.hour * 60 + time.minute;

  void init() {
    int weekday = widget.periods[0].startTime.weekday; // Monday = 1, Sunday = 7
    dayStart = widget.timeGrid.asList()[weekday - 1].first.first;
    dayEnd = widget.timeGrid.asList()[weekday - 1].last.last;
  }

  @override
  Widget build(BuildContext context) {
    init();
    return LayoutBuilder(
      builder: (context, constraints) {
        totalHeight = constraints.maxHeight;
        heightPerMinute =
            totalHeight / (getMinutes(dayEnd) - getMinutes(dayStart));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Stack(
            children: List.generate(
              widget.periods.length,
              (index) {
                Period period = widget.periods[index];
                Color primaryColor = Theme.of(context).colorScheme.primary;
                if (period.isCancelled) {
                  primaryColor = Colors.blue;
                } else if (widget.mySubjectColors.containsKey(period.name)) {
                  primaryColor = widget.mySubjectColors[period.name]!;
                }
                Color textColor = _getBestTextColor(primaryColor);

                double heightFromTop = heightPerMinute *
                    (getMinutes(DayTime.fromDateTime(period.startTime)) -
                        getMinutes(dayStart));
                double heightFromBottom = heightPerMinute *
                    (getMinutes(dayEnd) -
                        getMinutes(DayTime.fromDateTime(period.endTime)));
                return Positioned(
                  top: heightFromTop,
                  bottom: heightFromBottom,
                  width: constraints.maxWidth,
                  child: PeriodTile(
                    period: period,
                    primaryColor: primaryColor,
                    mySubjectNames: widget.mySubjectNames,
                    textColor: textColor,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

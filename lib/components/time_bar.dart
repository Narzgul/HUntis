import 'package:flutter/material.dart';
import 'package:huntis/untis_api.dart';

class TimeBar extends StatelessWidget {
  final TimeGrid timeGrid;
  final List<Period> periods;

  const TimeBar({
    super.key,
    required this.timeGrid,
    required this.periods,
  });

  int getMinutes(DayTime time) => time.hour * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    int weekday = periods[0].startTime.weekday; // Monday = 1, Sunday = 7
    DayTime dayStart = timeGrid.asList()[weekday - 1].first.first;
    DayTime dayEnd = timeGrid.asList()[weekday - 1].last.last;

    return LayoutBuilder(
      builder: (context, constraints) {
        double totalHeight = constraints.maxHeight;
        double heightPerMinute =
            totalHeight / (getMinutes(dayEnd) - getMinutes(dayStart));
        return Stack(
          children: List.generate(
            timeGrid.asList()[weekday - 1].length,
            (index) {
              List<DayTime> timeUnit = timeGrid.asList()[weekday - 1][index];
              double heightFromTop = heightPerMinute *
                  (getMinutes(timeUnit.first) - getMinutes(dayStart));
              double heightFromBottom = heightPerMinute *
                  (getMinutes(dayEnd) - getMinutes(timeUnit.last));
              Color textColor = Theme.of(context).colorScheme.onSurface;
              return Positioned(
                top: heightFromTop,
                bottom: heightFromBottom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeUnit.first.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    Text(
                      timeUnit.last.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

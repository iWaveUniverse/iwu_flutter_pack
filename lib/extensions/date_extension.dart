import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../setup/index.dart'; 

DateFormat intlDateFormat([newPattern, languageCode]) {
  return DateFormat(newPattern, languageCode ?? appPrefs.languageCode);
}

class TimeOfDayS {
  int hour;
  int minute;
  int seconds;

  TimeOfDayS({required this.hour, required this.minute, this.seconds = 00});
}

extension TimeOfDaySExtension on TimeOfDayS {
  bool isBefore(TimeOfDayS timeOfDay) {
    if (timeOfDay.hour > hour) return true;
    if (timeOfDay.hour < hour) return false;
    if (timeOfDay.hour == hour) {
      if (timeOfDay.minute > minute) {
        return true;
      } else if (timeOfDay.minute < minute) {
        return false;
      } else {
        if (timeOfDay.seconds > seconds) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  bool isBeforeOrSame(TimeOfDayS timeOfDay) {
    if (timeOfDay.hour > hour) return true;
    if (timeOfDay.hour < hour) return false;
    if (timeOfDay.hour == hour) {
      if (timeOfDay.minute > minute) {
        return true;
      } else if (timeOfDay.minute < minute) {
        return false;
      } else {
        if (timeOfDay.seconds >= seconds) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  bool isBefore(TimeOfDay timeOfDay) {
    if (timeOfDay.hour > hour) return true;
    if (timeOfDay.hour < hour) return false;
    if (timeOfDay.hour == hour) {
      if (timeOfDay.minute > minute) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool isBeforeOrSame(TimeOfDay timeOfDay) {
    if (timeOfDay.hour > hour) return true;
    if (timeOfDay.hour < hour) return false;
    if (timeOfDay.hour == hour) {
      if (timeOfDay.minute >= minute) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
}

extension DurationExtension on Duration {
  String toTime() {
    return toString().substring(2, 7);
  }
}

extension DateHelperExtension on DateTime {
  TimeOfDayS toTimeOfDayS() {
    return TimeOfDayS(hour: hour, minute: minute, seconds: second);
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  int dateDifference(DateTime secondDate) {
    return DateTime.utc(year, month, day)
        .difference(
            DateTime.utc(secondDate.year, secondDate.month, secondDate.day))
        .inDays;
  } 

  DateTime addDate(int days) {
    return DateTime(year, month, day).add(Duration(days: days));
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameTime(DateTime other) {
    return hour == other.hour && minute == other.minute;
  }

  bool isToday() {
    return year == DateTime.now().year &&
        month == DateTime.now().month &&
        day == DateTime.now().day;
  }

  bool isInRange(DateTime startDate, DateTime endDate) {
    return (isAfter(startDate) || isSameDate(startDate)) &&
        (isBefore(endDate) || isSameDate(endDate));
  }

  String getGregorianWeekDayAndDate({languageCode}) {
    final f = DateFormat('EEEE, MMM d', languageCode ?? appPrefs.languageCode);

    return f.format(this);
  }

  String formatDate({String? formatType, languageCode}) {
    return DateFormat(formatType ?? appPrefs.dateFormat,
            languageCode ?? appPrefs.languageCode)
        .format(this);
  }

  String formatShortDate({String? formatType, languageCode}) {
    return DateFormat(
            formatType ?? appPrefs.dateFormat.replaceAll('yyyy', 'yy'),
            languageCode ?? appPrefs.languageCode)
        .format(this);
  }

  String formatTime({String? formatType, languageCode}) {
    return DateFormat(formatType ?? appPrefs.timeFormat,
            languageCode ?? appPrefs.languageCode)
        .format(this);
  }

  String formatDateTime({languageCode}) {
    return DateFormat('${appPrefs.timeFormat}, ${appPrefs.dateFormat}',
            languageCode ?? appPrefs.languageCode)
        .format(this);
  }
}

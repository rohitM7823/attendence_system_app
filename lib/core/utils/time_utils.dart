import 'package:flutter/material.dart';

import '../../core/constants/time_constants.dart';

class TimeUtils {
  static bool isAfter(TimeOfDay now, TimeOfDay target) {
    return now.hour > target.hour ||
        (now.hour == target.hour && now.minute > target.minute);
  }

  static bool isWithinClockInTime(TimeOfDay now) {
    return now.hour == TimeConstants.clockInHour &&
        now.minute >= TimeConstants.clockInMinute;
  }

  static bool isWithinClockOutTime(TimeOfDay now) {
    return now.hour == TimeConstants.clockOutHour &&
        now.minute >= TimeConstants.clockOutMinute;
  }
}

extension TimeUtilsExt on TimeOfDay {
  String get toTimeStamp {
    var date = DateTime.now();
    return DateTime(date.year, date.month, date.day, this.hour, this.minute)
        .toString();
  }

  DateTime get toDateTime {
    var date = DateTime.now();
    return DateTime(date.year, date.month, date.day, this.hour, this.minute);
  }
}


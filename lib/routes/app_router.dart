import 'package:attendance_system/features/attendance/presentation/pages/device_not_registered.dart';
import 'package:attendance_system/features/attendance/presentation/pages/recognition_employee.dart';
import 'package:attendance_system/main.dart';
import 'package:flutter/material.dart';

import '../features/attendance/presentation/pages/clock_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
        builder: (_) => FaceRecognitionScreen(camera: cameraDescriptions.last),
        maintainState: true,
      );
    /*case '/face-verification':
      return MaterialPageRoute(
          builder: (_) =>
              FaceRecognitionScreen(camera: cameraDescriptions.last));*/
    case '/not_registered':
      return MaterialPageRoute(
        builder: (context) => const DeviceNotRegistered(),
      );
    case '/clock':
      return MaterialPageRoute(builder: (_) => ClockPage());
    default:
      return MaterialPageRoute(
        builder: (_) => FaceRecognitionScreen(camera: cameraDescriptions.last),
        maintainState: true,
      );
  }
}

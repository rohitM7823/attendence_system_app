import 'package:attendance_system/features/attendance/presentation/pages/recognition_employee.dart';
import 'package:attendance_system/features/attendance/presentation/pages/register_employee.dart';
import 'package:attendance_system/main.dart';
import 'package:flutter/material.dart';
import '../features/attendance/presentation/pages/clock_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
          builder: (_) =>
              EmployeeRegisterScreen(camera: cameraDescriptions.last));
    case '/face-verification':
      return MaterialPageRoute(
          builder: (_) =>
              FaceRecognitionScreen(camera: cameraDescriptions.last));
    case '/clock':
      return MaterialPageRoute(builder: (_) => ClockPage());
    default:
      return MaterialPageRoute(builder: (_) => EmployeeRegisterScreen(camera: cameraDescriptions.last));
  }
}

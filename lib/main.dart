import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameraDescriptions = [];


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameraDescriptions = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
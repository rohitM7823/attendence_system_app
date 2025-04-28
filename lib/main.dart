import 'package:attendance_system/core/commons/device_details.dart';
import 'package:attendance_system/data/apis.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'routes/app_router.dart';

List<CameraDescription> cameraDescriptions = [];
String initialRoute = '';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initialization();
  FlutterNativeSplash.remove();
  runApp(MyApp(
    initialRoute: initialRoute,
  ));
}

Future<void> initialization() async {
  cameraDescriptions = await availableCameras();
  await DeviceDetails.instance.init();
  var isRegistered = await Apis.registerDeviceIfNot();
  bool? isApproved;
  if (isRegistered) {
    isApproved = await Apis.isDeviceApproved();
  }

  initialRoute = isRegistered && isApproved == true ? '/' : '/not_registered';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: generateRoute,
      initialRoute: widget.initialRoute,
    );
  }
}

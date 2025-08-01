import 'dart:developer';

import 'package:attendance_system/core/commons/device_details.dart';
import 'package:attendance_system/routes/app_router.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';

List<CameraDescription> cameraDescriptions = [];
String initialRoute = '/';

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
  try {
    cameraDescriptions = await availableCameras();
    await DeviceDetails.instance.init();
    /*var isRegistered = await Apis.registerDeviceIfNot();
    bool? isApproved;
    if (isRegistered) {
      isApproved = await Apis.isDeviceApproved();
    }

    initialRoute = isRegistered && isApproved == true ? '/' : '/not_registered';*/
  } catch (Ex) {
    log(Ex.toString(), name: 'INITIALIZATION');
  }
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
      //home: SignInScreenWidget(),
    );
  }
}


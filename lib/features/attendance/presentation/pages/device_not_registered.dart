import 'package:flutter/material.dart';

class DeviceNotRegistered extends StatefulWidget {
  const DeviceNotRegistered({super.key});

  @override
  State<DeviceNotRegistered> createState() => _DeviceNotRegisteredState();
}

class _DeviceNotRegisteredState extends State<DeviceNotRegistered> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Your device is not registered from Admin.\nPlease contact admin to register your device.',
          style: TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'dart:developer';
import 'dart:ui';

import 'package:attendance_system/data/apis.dart';
import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:attendance_system/helpers/face_detector.dart';
import 'package:attendance_system/helpers/location_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final CameraDescription camera;
  final VoidCallback? onFaceVerified;
  final VoidCallback? onNoFaceDetected;

  const FaceRecognitionScreen(
      {super.key,
      required this.camera,
      this.onFaceVerified,
      this.onNoFaceDetected});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool scanning = false;
  double confidenceLevel = 0.85;
  List<Rect> detectedFaces = [
    const Rect.fromLTWH(100, 200, 200, 250)
  ]; // Mock data
  Employee? recognitionResult;
  bool _buttonPressed = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Future<void> _initializeControllerFuture;
  String _statusMessage = 'Align your face within the frame';
  bool _faceVerified = false;
  bool _cameraReady = false;

  FaceRecognitionService faceRecognitionService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      setState(() {
        _cameraReady = true;
      });
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  void _detectFace() async {
    setState(() {
      scanning = true;
    });
    final face = await _controller.takePicture();
    var result = await faceRecognitionService
        .recognizeFace(InputImage.fromFilePath(face.path));

    setState(() {
      scanning = false;
    });

    if (result != null) {
      widget.onFaceVerified?.call();
      setState(() {
        _faceVerified = true;
        _statusMessage = 'Face Verified!';
      });
      await _checkClockAndNavigateAttendence(result);
    } else {
      setState(() {
        _faceVerified = false;
        _statusMessage = 'Face Verification Failed!';
      });
    }
    try {

    } catch (e) {
      setState(() {
        scanning = false;
        _faceVerified = false;
        _statusMessage = 'Face Verification Failed!';
      });
      log(e.toString(), name: 'Face Recognition issue');
    }
  }

  Widget _buildGlassLayer() {
    return Container(
      width: 260,
      height: 350,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildScanningAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScannerPainter(_animation.value),
          child: const SizedBox(
            width: 260,
            height: 350,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face_retouching_natural, color: Colors.black),
            Text(' Face Verification')
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    return AnimatedOpacity(
                      opacity: _cameraReady ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .85,
                        height: MediaQuery.of(context).size.height * .55,
                        child: snapshot.connectionState == ConnectionState.done
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CameraPreview(_controller))
                            : Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                _buildScanningAnimation(),
                if (scanning)
                  SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        color: Colors.redAccent.withOpacity(.50),
                        strokeCap: StrokeCap.round,
                        strokeWidth: 5,
                      )),
                if (_faceVerified) _buildGlassLayer(),
                if (_faceVerified)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 120,
                  ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _statusMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (!scanning)
              ElevatedButton.icon(
                onPressed: () {
                  _detectFace();
                },
                icon: _faceVerified
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.camera,
                        color: Colors.black,
                      ),
                label: _faceVerified
                    ? const Text(
                        'Employee Verified',
                        style: TextStyle(color: Colors.green, fontSize: 20),
                      )
                    : const Text(
                        'Recognise yourself',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkClockAndNavigateAttendence(Employee employee) async {
    if (employee.shift != null) {
      var clockInWindow = employee.shift?.clockInWindow;
      var clockOutWindow = employee.shift?.clockOutWindow;

      if (clockInWindow?.start != null &&
          clockInWindow!.start!.isBefore(DateTime.now()) &&
          clockInWindow.end != null &&
          clockInWindow.end!.isAfter(DateTime.now())) {
        final site = await Apis.getSiteRadius(employee.id!);
        log('${site?.toJson()}', name: 'STIE');
        if (site != null) {
          var result = await LocationHandler.isWithinRadius(
              context: context,
              targetLatitude: site.location!.lat,
              targetLongitude: site.location!.lng,
              radiusInMeters: site.radius!.toDouble());
          log('$result', name: 'RESULT');
          if (result == false) {
            LocationHandler.showOutOfRadiusDialog(context);
            return;
          } else if(result == true) {
            Navigator.of(context)
                .pushReplacementNamed('/clock', arguments: employee.toJson());
          }
        }
      } else if (clockOutWindow?.start != null &&
          clockOutWindow!.start!.isBefore(DateTime.now()) &&
          clockOutWindow.end != null &&
          clockOutWindow.end!.isAfter(DateTime.now())) {
        final site = await Apis.getSiteRadius(employee.id!);
        if (site != null) {
          var result = await LocationHandler.isWithinRadius(
              context: context,
              targetLatitude: site.location!.lat,
              targetLongitude: site.location!.lng,
              radiusInMeters: site.radius!.toDouble());
          if (result == false) {
            LocationHandler.showOutOfRadiusDialog(context);
            return;
          } else if(result == true) {
            Navigator.of(context)
                .pushReplacementNamed('/clock', arguments: employee.toJson());
          }
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Error",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "You time window has been expired!!",
              style: TextStyle(fontSize: 16),
            ),
            actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;

  _ScannerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, paint);

    final lineY = size.height * progress;
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class FaceOutlinePainter extends CustomPainter {
  final List<Rect> faces;

  FaceOutlinePainter({required this.faces});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.redAccent
      ..shader = const LinearGradient(
        colors: [Colors.cyanAccent, Colors.redAccent],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    for (final rect in faces) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(20)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/*class RecognitionResultCard extends StatelessWidget {
  final Employee employee;
  final double confidence;

  const RecognitionResultCard({
    super.key,
    required this.employee,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(employee.photoUrl),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(employee.position ??''),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.verified, color: Colors.cyanAccent, size: 40),
          ],
        ),
      ),
    );
  }
}*/

class GlassmorphicContainer extends StatelessWidget {
  final double height;
  final double? borderRadius;
  final Widget child;
  final BoxDecoration? decoration;
  final double? width;

  const GlassmorphicContainer({
    super.key,
    required this.height,
    this.borderRadius,
    required this.child,
    this.decoration,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          width: width,
          decoration: decoration ??
              BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(borderRadius ?? 20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
          child: child,
        ),
      ),
    );
  }
}

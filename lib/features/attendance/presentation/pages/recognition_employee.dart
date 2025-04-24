import 'dart:ui';

import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:attendance_system/helpers/face_detector.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceRecognitionScreen({super.key, required this.camera});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  String statusText = 'Scanning...';
  double confidenceLevel = 0.85;
  List<Rect> detectedFaces = [
    const Rect.fromLTWH(100, 200, 200, 250)
  ]; // Mock data
  Employee? recognitionResult = testEmployee;
  FaceRecognitionService faceRecognitionService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  InputImage _createInputImage(CameraImage image) {
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _getRotation(),
      format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: metadata,
    );
  }

  InputImageRotation _getRotation() {
    final rotation = _controller.description.sensorOrientation;
    return InputImageRotationValue.fromRawValue(rotation) ?? InputImageRotation.rotation0deg;
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    setState(() => _isCameraInitialized = true);

    _controller.startImageStream((image) async {
      final inputImage = _createInputImage(image);
      var emp = await faceRecognitionService.recognizeFace(inputImage);
      if(emp != null) {
        _controller.stopImageStream();
        setState(() {
          recognitionResult = emp;
          statusText = 'Verified';
        });
      }
    },);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_controller),
                CustomPaint(painter: FaceOutlinePainter(faces: detectedFaces)),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: GlassmorphicContainer(
                    height: 80,
                    borderRadius: 20,
                    child: Row(
                      children: [
                        Lottie.asset('assets/face-scan.json', width: 60),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'FACE SCAN ACTIVE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (recognitionResult != null)
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: RecognitionResultCard(
                      employee: recognitionResult!,
                      confidence: confidenceLevel,
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
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

class RecognitionResultCard extends StatelessWidget {
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
                Text(employee.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(employee.position),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.cyanAccent,
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
}

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

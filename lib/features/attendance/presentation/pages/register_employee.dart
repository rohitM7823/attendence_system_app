import 'dart:io';

import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:attendance_system/features/attendance/presentation/pages/recognition_employee.dart';
import 'package:attendance_system/helpers/face_detector.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shimmer/shimmer.dart';

class EmployeeRegisterScreen extends StatefulWidget {
  final CameraDescription camera;

  const EmployeeRegisterScreen({super.key, required this.camera});

  @override
  State<EmployeeRegisterScreen> createState() => _EmployeeRegisterScreenState();
}

class _EmployeeRegisterScreenState extends State<EmployeeRegisterScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  bool _faceDetected = false;
  bool _isScanning = true;
  bool _buttonPressed = false;
  late AnimationController _waveController;
  final FaceRecognitionService faceRecognitionService =
      FaceRecognitionService();

  @override
  void initState() {
    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized) return;
    setState(() {
      _faceDetected = false;
    });
    final XFile image = await _controller.takePicture();

    // Handle captured image
    await faceRecognitionService.registerEmployeeFace(
        testEmployee, InputImage.fromFilePath(image.path));
    setState(() {
      _faceDetected = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacementNamed('/face-verification');
    debugPrint('Image captured: ${image.path}');
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      // Handle registration logic
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Position: ${_positionController.text}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Employee Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFaceCaptureSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaceCaptureSection() {
    return GlassmorphicContainer(
      height: 320,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Camera Preview with Dynamic Border
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _faceDetected ? Colors.cyanAccent : Colors.white30,
                width: _faceDetected ? 3 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _isCameraInitialized
                  ? CameraPreview(_controller)
                  : _buildCameraLoadingPlaceholder(),
            ),
          ),

          // Scanning Animation Overlay
          if (_isScanning)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) => Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _faceDetected ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      painter:
                          _ScanningWavePainter(animation: _waveController.view),
                    ),
                  ),
                ),
              ),
            ),

          // Instruction Panel
          Positioned(
            top: 30,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face_retouching_natural,
                      color: Colors.white.withOpacity(0.8)),
                  const SizedBox(width: 10),
                  Text(
                    'Align face within the frame',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _buttonPressed = true),
              onTapUp: (_) => setState(() => _buttonPressed = false),
              onTapCancel: () => setState(() => _buttonPressed = false),
              onTap: _captureImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _buttonPressed
                      ? Colors.cyanAccent.withOpacity(0.8)
                      : Colors.cyanAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: _buttonPressed ? 5 : 3,
                    )
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 32,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ),

          // Status Indicator
          if (_faceDetected)
            Positioned(
              right: 30,
              top: 30,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        color: Colors.black,
      ),
    );
  }
}

class _ScanningWavePainter extends CustomPainter {
  final Animation<double> animation;

  _ScanningWavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0),
          Colors.cyanAccent.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..moveTo(0, size.height * animation.value)
      ..quadraticBezierTo(size.width / 2, size.height * animation.value + 50,
          size.width, size.height * animation.value);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

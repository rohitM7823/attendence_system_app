import 'dart:developer';
import 'dart:ui';

import 'package:attendance_system/core/commons/secure_storage.dart';
import 'package:attendance_system/data/apis.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../features/attendance/domain/models/employee_model.dart';
import 'face_embedding_service.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final apiService = Apis();

  // Threshold for face recognition (cosine similarity)
  static const double recognitionThreshold = 0.65;

  InputImage convertCameraImage(
      CameraImage image, InputImageRotation rotation) {
    final bytes = image.toNV21();
    final size = Size(image.width.toDouble(), image.height.toDouble());

    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<bool?> recognizeFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    // Get the largest face (most prominent in the image)
    faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
        .compareTo(a.boundingBox.width * a.boundingBox.height));

    final face = faces.first;

    // Convert InputImage to image.Image for processing
    final image = await _embeddingService.convertInputImageToImage(inputImage);

    // Crop face from image
    final croppedFace = img.copyCrop(
      image,
      face.boundingBox.left.toInt(),
      face.boundingBox.top.toInt(),
      face.boundingBox.width.toInt(),
      face.boundingBox.height.toInt(),
    );

    // Get embedding for the detected face
    final probeEmbedding =
        await _embeddingService.getFaceEmbedding(croppedFace);

    var employees = await Apis.getFaceEmbeddings(
        await SecureStorage.instance.deviceIdentifier);
    if (employees?.isEmpty == true) return null;

    for (var employee in employees!) {
      final storedEmbedding = _parseEmbeddingString(employee.faceData!);
      final similarity = _embeddingService.compareEmbeddings(
        probeEmbedding,
        storedEmbedding,
      );
      log('$similarity --- $recognitionThreshold', name: 'SIMILARITY');
      return similarity >= recognitionThreshold;
    }

    return null;
  }


  String _embeddingToString(List<double> embedding) {
    return embedding.map((e) => e.toString()).join(',');
  }

  List<double> _parseEmbeddingString(String embeddingString) {
    return embeddingString.split(',').map(double.parse).toList();
  }
}

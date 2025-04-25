import 'dart:developer';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../features/attendance/domain/models/employee_model.dart';
import 'face_embedding_service.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

  // Threshold for face recognition (cosine similarity)
  static const double recognitionThreshold = 0.6;

  Future<Employee?> recognizeFace(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    // Get the largest face (most prominent in the image)
    faces.sort((a, b) =>
        (b.boundingBox.width * b.boundingBox.height).compareTo(
            a.boundingBox.width * a.boundingBox.height));

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
    final probeEmbedding = await _embeddingService.getFaceEmbedding(croppedFace);

    // Compare with all registered employees (assuming you will loop through a list later)
    final storedEmbedding = _parseEmbeddingString(testEmployee.faceData);

    final similarity = _embeddingService.compareEmbeddings(
      probeEmbedding,
      storedEmbedding,
    );

    if (similarity > recognitionThreshold) {
      return testEmployee;
    }

    return null;
  }

  Future<void> registerEmployeeFace(Employee employee, InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) throw Exception('No face detected');

    // Get the largest face
    faces.sort((a, b) =>
        (b.boundingBox.width * b.boundingBox.height).compareTo(
            a.boundingBox.width * a.boundingBox.height));

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

    // Get face embedding
    final embedding = await _embeddingService.getFaceEmbedding(croppedFace);
    log(embedding.toString(), name: 'EMBEDDING');
    employee.faceData = _embeddingToString(embedding);
  }

  String _embeddingToString(List<double> embedding) {
    return embedding.map((e) => e.toString()).join(',');
  }

  List<double> _parseEmbeddingString(String embeddingString) {
    return embeddingString.split(',').map(double.parse).toList();
  }
}

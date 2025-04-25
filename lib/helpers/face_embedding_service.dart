import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FaceEmbeddingService {
  late Interpreter _faceRecognitionInterpreter;
  late ImageProcessor _imageProcessor;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize MobileFaceNet Interpreter
      _faceRecognitionInterpreter = await Interpreter.fromAsset(
        'ml_model/mobilefacenet.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      // Initialize image processor for input image resizing
      _imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(112, 112, ResizeMethod.BILINEAR))
          .add(NormalizeOp(128, 128))
          .build();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Initialization failed: ${e.toString()}');
    }
  }

  Future<img.Image> convertInputImageToImage(InputImage inputImage) async {
    if (inputImage.bytes != null) {
      final image = img.decodeImage(inputImage.bytes!);
      if (image == null) {
        throw Exception("Could not decode image from bytes.");
      }
      return image;
    }

    if (inputImage.filePath != null) {
      final file = File(inputImage.filePath!);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception("Could not decode image from file path.");
      }
      return image;
    }

    throw Exception("InputImage does not contain byte data or file path.");
  }

  Future<List<double>> getFaceEmbedding(img.Image image) async {
    if (!_isInitialized) await initialize();

    final tensorImage = TensorImage(TfLiteType.float32)..loadImage(image);
    final processedTensor = _imageProcessor.process(tensorImage);

    final outputTensor = _faceRecognitionInterpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final outputType = outputTensor.type;
    final outputList = Float32List(outputShape.reduce((a, b) => a * b));

    _faceRecognitionInterpreter.run(processedTensor.buffer, outputList);

    final outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
    outputBuffer.loadList(outputList, shape: outputShape);

    return outputBuffer.getDoubleList();
  }

  double compareEmbeddings(List<double> emb1, List<double> emb2) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    final cosineSimilarity = dotProduct / (sqrt(normA) * sqrt(normB));
    return cosineSimilarity;
  }
}

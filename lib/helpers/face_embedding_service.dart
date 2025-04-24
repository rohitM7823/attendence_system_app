import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';


class FaceEmbeddingService {
  late Interpreter _interpreter;
  late ImageProcessor _imageProcessor;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model with error handling
      _interpreter = await Interpreter.fromAsset('assets/blaze_face_short_range.tflite',
          options: InterpreterOptions()..threads = 4);

      // Verify input tensor shape
      final inputTensor = _interpreter.getInputTensor(0);
      if (inputTensor.shape[1] != 112 || inputTensor.shape[2] != 112) {
        throw Exception('Model expects input shape ${inputTensor.shape}');
      }

      // Initialize image processor
      _imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(112, 112, ResizeMethod.BILINEAR))
          .add(NormalizeOp(127.5, 127.5)) // Normalizes to [-1, 1]
          .build();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Face embedding initialization failed: $e');
    }
  }

  Future<List<double>> getFaceEmbedding(img.Image image) async {
    if (!_isInitialized) await initialize();

    try {
      // Convert to RGB and remove alpha channel
      final rgbImage = img.copyResize(image, width: 112, height: 112);
      final tensorImage = TensorImage(TensorBufferFloat.DATA_TYPE)
        ..loadImage(rgbImage);

      // Process image
      final processedImage = _imageProcessor.process(tensorImage);

      // Allocate tensors
      final inputBuffer = processedImage.buffer;
      final outputBuffer = TensorBuffer.createFixedSize(
        _interpreter.getOutputTensor(0).shape,
        TensorBufferFloat.DATA_TYPE,
      );

      // Run inference
      _interpreter.run(inputBuffer, outputBuffer.buffer);

      // Return normalized embeddings
      return _normalize(outputBuffer.getDoubleList());
    } catch (e) {
      throw Exception('Embedding extraction failed: $e');
    }
  }

  List<double> _normalize(List<double> embeddings) {
    final norm = sqrt(embeddings
        .map((x) => x * x)
        .reduce((sum, element) => sum + element));
    return embeddings.map((x) => x / norm).toList();
  }

  double compareEmbeddings(List<double> emb1, List<double> emb2) {
    if (emb1.length != emb2.length) return 0.0;

    double dotProduct = 0.0;
    for (int i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
    }

    // Clamp to [-1, 1] to avoid floating point errors
    return dotProduct.clamp(-1.0, 1.0);
  }

  Future<img.Image> convertInputImageToImage(InputImage inputImage) async {
    try {
      List<int> bytes;
      if (inputImage.bytes != null) {
        bytes = inputImage.bytes!;
      } else if (inputImage.filePath != null) {
        bytes = await File(inputImage.filePath!).readAsBytes();
      } else {
        throw Exception('No valid image data found');
      }

      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');

      return image;
    } catch (e) {
      throw Exception('Image conversion error: $e');
    }
  }
}
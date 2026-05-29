import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

class TransactionClassifier {
  static const int inputSize = 320;
  static const List<double> _mean = [0.485, 0.456, 0.406];
  static const List<double> _std = [0.229, 0.224, 0.225];
  static const int _padR = 124;
  static const int _padG = 116;
  static const int _padB = 104;
  static const double threshold = 0.5;

  OrtSession? _session;

  Future<void> init() async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    sessionOptions.appendDefaultProviders();
    final rawAsset = await rootBundle.load('assets/models/teacher.onnx');
    final bytes = rawAsset.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
  }

  Future<Map<String, dynamic>> classify(img.Image image) async {
    final letterboxed = _letterbox(image, inputSize);
    final input = _preprocess(letterboxed);
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      input,
      [1, 3, inputSize, inputSize],
    );
    final runOptions = OrtRunOptions();
    final outputs = await _session!.runAsync(runOptions, {'image': inputOrt});
    final output = outputs![0]!;
    final logitData = output.value as List;
    final logit = (logitData[0] as List)[0] as double;
    final probability = 1.0 / (1.0 + exp(-logit));

    inputOrt.release();
    runOptions.release();
    for (final o in outputs) {
      o?.release();
    }

    return {
      'is_transaction': probability >= threshold,
      'confidence': probability,
    };
  }

  img.Image _letterbox(img.Image image, int size) {
    final longestSide = max(image.width, image.height);
    final scale = size / longestSide;
    final resizedWidth = (image.width * scale).round();
    final resizedHeight = (image.height * scale).round();
    final resized = img.copyResize(
      image,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: img.Interpolation.linear,
    );
    final canvas = img.Image(width: size, height: size);
    img.fill(canvas, color: img.ColorRgb8(_padR, _padG, _padB));
    final offsetX = (size - resizedWidth) ~/ 2;
    final offsetY = (size - resizedHeight) ~/ 2;
    img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
    return canvas;
  }

  Float32List _preprocess(img.Image image) {
    final buffer = Float32List(3 * inputSize * inputSize);
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final idx = y * inputSize + x;
        buffer[0 * inputSize * inputSize + idx] =
            (pixel.r / 255.0 - _mean[0]) / _std[0];
        buffer[1 * inputSize * inputSize + idx] =
            (pixel.g / 255.0 - _mean[1]) / _std[1];
        buffer[2 * inputSize * inputSize + idx] =
            (pixel.b / 255.0 - _mean[2]) / _std[2];
      }
    }
    return buffer;
  }

  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
  }
}

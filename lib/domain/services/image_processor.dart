import 'dart:typed_data';
import 'dart:isolate';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../core/config/app_config.dart';

/// Menjalankan preprocessing berat di Isolate terpisah
/// agar UI thread (main isolate) tidak terblokir.
class ImageProcessor {
  /// Konversi CameraImage (YUV420) → input tensor Float32 [1,224,224,3]
  ///
  /// Pipeline:
  ///   1. YUV420 → RGB (via rotasi & konversi channel)
  ///   2. Resize → 224×224
  ///   3. Normalize [0,255] → [0.0,1.0]
  ///   4. Flatten menjadi Float32List untuk TFLite
  static Future<Float32List> preprocessCameraImage(CameraImage image) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_processInIsolate, [receivePort.sendPort, image]);
    return await receivePort.first as Float32List;
  }

  /// Konversi file gambar (JPEG/PNG bytes) → input tensor Float32 [1,224,224,3]
  static Future<Float32List> preprocessImageBytes(Uint8List bytes) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_processBytesInIsolate, [receivePort.sendPort, bytes]);
    return await receivePort.first as Float32List;
  }

  // ── Private isolate workers ─────────────────────────────────────────────

  static void _processInIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final CameraImage cameraImage = args[1];

    // 1. YUV420 → img.Image (RGB)
    final img.Image rgbImage = _yuv420ToRgb(cameraImage);

    // 2. Resize + 3. Normalize
    final Float32List tensor = _toTensor(rgbImage);
    sendPort.send(tensor);
  }

  static void _processBytesInIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final Uint8List bytes = args[1];

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      sendPort.send(Float32List(AppConfig.inputSize * AppConfig.inputSize * 3));
      return;
    }

    final Float32List tensor = _toTensor(decoded);
    sendPort.send(tensor);
  }

  /// YUV420 (NV21 / NV12 / YUV_420_888) → RGB img.Image
  static img.Image _yuv420ToRgb(CameraImage cameraImage) {
    final int width  = cameraImage.width;
    final int height = cameraImage.height;

    final Uint8List yPlane  = cameraImage.planes[0].bytes;
    final Uint8List uvPlane = cameraImage.planes[1].bytes;

    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex  = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) * 2 + (x ~/ 2) * 2;

        final int yVal = yPlane[yIndex];
        final int uVal = uvPlane[uvIndex];
        final int vVal = uvPlane[uvIndex + 1];

        // YUV → RGB formula
        int r = (yVal + 1.402   * (vVal - 128)).round().clamp(0, 255);
        int g = (yVal - 0.344136 * (uVal - 128) - 0.714136 * (vVal - 128)).round().clamp(0, 255);
        int b = (yVal + 1.772   * (uVal - 128)).round().clamp(0, 255);

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  /// img.Image → Float32List tensor [H×W×C] dinormalisasi [0,1]
  static Float32List _toTensor(img.Image source) {
    // Resize → 224×224
    final img.Image resized = img.copyResize(
      source,
      width:  AppConfig.inputSize,
      height: AppConfig.inputSize,
      interpolation: img.Interpolation.linear,
    );

    final int pixelCount = AppConfig.inputSize * AppConfig.inputSize;
    final Float32List tensor = Float32List(pixelCount * AppConfig.inputChannels);

    int idx = 0;
    for (int y = 0; y < AppConfig.inputSize; y++) {
      for (int x = 0; x < AppConfig.inputSize; x++) {
        final img.Pixel pixel = resized.getPixel(x, y);
        // Normalize: [0,255] → [0.0, 1.0]
        tensor[idx++] = pixel.r / AppConfig.inputStd;
        tensor[idx++] = pixel.g / AppConfig.inputStd;
        tensor[idx++] = pixel.b / AppConfig.inputStd;
      }
    }

    return tensor;
  }

  /// Hitung bounding box overlay di screen coordinates.
  /// Model output 224×224, screen mungkin berbeda resolusi.
  static mapCoordinatesToScreen({
    required double modelLeft,
    required double modelTop,
    required double modelWidth,
    required double modelHeight,
    required double screenWidth,
    required double screenHeight,
  }) {
    final double scaleX = screenWidth  / AppConfig.inputSize;
    final double scaleY = screenHeight / AppConfig.inputSize;

    return Rect.fromLTWH(
      modelLeft   * scaleX,
      modelTop    * scaleY,
      modelWidth  * scaleX,
      modelHeight * scaleY,
    );
  }
}

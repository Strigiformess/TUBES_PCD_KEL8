import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

/// CameraService — mengelola lifecycle CameraController secara aman.
///
/// Lifecycle Safety (dari FigJam Bagian 3):
///   - init() dipanggil di initState
///   - dispose() dipanggil di dispose widget
///   - Tidak ada akses ke controller setelah dispose
class CameraService extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isDisposed    = false;
  String? _errorMessage;

  CameraController? get controller   => _controller;
  bool get isInitialized             => _isInitialized;
  bool get hasError                  => _errorMessage != null;
  String? get errorMessage           => _errorMessage;

  /// Inisialisasi kamera — panggil di initState.
  Future<void> init() async {
    if (_isDisposed) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = 'Tidak ada kamera yang tersedia';
        notifyListeners();
        return;
      }

      // Prefer back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (_isDisposed) {
        await _controller!.dispose();
        return;
      }

      _isInitialized = true;
      _errorMessage  = null;
      notifyListeners();
    } on CameraException catch (e) {
      _errorMessage = 'Camera error: ${e.description}';
      notifyListeners();
    }
  }

  /// Ambil foto untuk dianalisis.
  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;
    try {
      return await _controller!.takePicture();
    } on CameraException {
      return null;
    }
  }

  /// Pause preview saat berpindah halaman.
  Future<void> pausePreview() async {
    if (_isInitialized && _controller != null) {
      await _controller!.pausePreview();
    }
  }

  /// Resume preview saat kembali ke halaman kamera.
  Future<void> resumePreview() async {
    if (_isInitialized && _controller != null) {
      await _controller!.resumePreview();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await _controller?.dispose();
    _controller    = null;
    _isInitialized = false;
    super.dispose();
  }
}

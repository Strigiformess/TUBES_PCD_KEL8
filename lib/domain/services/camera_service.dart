import 'package:flutter/material.dart';

class CameraService extends ChangeNotifier {
  bool isReady = false;

  Future<void> initialize() async {
    // Simulasi menyalakan perangkat kamera HP
    await Future.delayed(const Duration(milliseconds: 800));
    isReady = true;
    notifyListeners();
  }
}
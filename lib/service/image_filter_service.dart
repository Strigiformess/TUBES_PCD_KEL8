// service/image_filter_service.dart
// PCD (Pengolahan Citra Digital) filter implementations.
// All filters are applied manually at the pixel level to demonstrate
// core digital image processing concepts.

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Available PCD filter types
enum PCDFilter {
  none,        // Original image (no filter)
  grayscale,   // Luminance conversion: Y = 0.299R + 0.587G + 0.114B
  gaussianBlur,// Spatial convolution with Gaussian-like 3×3 kernel
  sobelEdge,   // Gradient-based edge detection (Sobel operator)
  otsuThreshold// Automatic binarization using Otsu's method
}

class ImageFilterService {
  /// Apply a PCD filter to raw JPEG/PNG bytes.
  /// Returns the processed image as JPEG bytes.
  /// Designed to be called inside an isolate via compute().
  static Uint8List applyFilter(Uint8List imageBytes, PCDFilter filter) {
    final image = img.decodeImage(imageBytes)!;
    final filtered = _applyFilterToImage(image, filter);
    return Uint8List.fromList(img.encodeJpg(filtered, quality: 90));
  }

  static img.Image _applyFilterToImage(img.Image image, PCDFilter filter) {
    switch (filter) {
      case PCDFilter.none:
        return image;
      case PCDFilter.grayscale:
        return _grayscale(image);
      case PCDFilter.gaussianBlur:
        return _gaussianBlur(image);
      case PCDFilter.sobelEdge:
        return _sobelEdge(image);
      case PCDFilter.otsuThreshold:
        return _otsuThreshold(image);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 1. GRAYSCALE  (RGB → Luminance)
  //    Formula: Y = 0.299R + 0.587G + 0.114B
  //    ITU-R BT.601 standard for perceived brightness.
  // ─────────────────────────────────────────────────────────────
  static img.Image _grayscale(img.Image src) {
    final dst = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final a = p.a.toInt();
        final lum = (0.299 * r + 0.587 * g + 0.114 * b).round();
        dst.setPixelRgba(x, y, lum, lum, lum, a);
      }
    }
    return dst;
  }

  // ─────────────────────────────────────────────────────────────
  // 2. GAUSSIAN BLUR  (3×3 convolution kernel)
  //    Kernel (σ ≈ 0.85):
  //      1  2  1
  //      2  4  2  ÷ 16
  //      1  2  1
  //    Low-pass filter: reduces high-frequency noise.
  // ─────────────────────────────────────────────────────────────
  static img.Image _gaussianBlur(img.Image src) {
    const K = [1, 2, 1, 2, 4, 2, 1, 2, 1]; // 3×3 kernel flattened
    const sum = 16;

    final dst = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        int rr = 0, gg = 0, bb = 0, ki = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final ny = (y + ky).clamp(0, src.height - 1);
            final nx = (x + kx).clamp(0, src.width - 1);
            final p = src.getPixel(nx, ny);
            final w = K[ki++];
            rr += p.r.toInt() * w;
            gg += p.g.toInt() * w;
            bb += p.b.toInt() * w;
          }
        }
        final alpha = src.getPixel(x, y).a.toInt();
        dst.setPixelRgba(x, y, rr ~/ sum, gg ~/ sum, bb ~/ sum, alpha);
      }
    }
    return dst;
  }

  // ─────────────────────────────────────────────────────────────
  // 3. SOBEL EDGE DETECTION
  //    Gx (horizontal gradient):     Gy (vertical gradient):
  //     -1  0  1                       -1 -2 -1
  //     -2  0  2                        0  0  0
  //     -1  0  1                        1  2  1
  //    Edge magnitude: G = √(Gx² + Gy²), clamped to [0, 255].
  //    High-pass filter: highlights intensity transitions.
  // ─────────────────────────────────────────────────────────────
  static img.Image _sobelEdge(img.Image src) {
    const gx = [-1, 0, 1, -2, 0, 2, -1, 0, 1];
    const gy = [-1, -2, -1, 0, 0, 0, 1, 2, 1];

    final dst = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        int sx = 0, sy = 0, ki = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final ny = (y + ky).clamp(0, src.height - 1);
            final nx = (x + kx).clamp(0, src.width - 1);
            final p = src.getPixel(nx, ny);
            // Luminance at this neighbour
            final lum =
                (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
            sx += lum * gx[ki];
            sy += lum * gy[ki];
            ki++;
          }
        }
        final mag = sx * sx + sy * sy;
        final edge = (mag > 65025) ? 255 : math.sqrt(mag.toDouble()).round();
        dst.setPixelRgb(x, y, edge, edge, edge);
      }
    }
    return dst;
  }

  // ─────────────────────────────────────────────────────────────
  // 4. OTSU'S THRESHOLDING  (automatic binarization)
  //    Step 1: Convert to grayscale.
  //    Step 2: Build luminance histogram.
  //    Step 3: Find threshold t that maximises inter-class variance:
  //            σ²_b(t) = w₀·w₁·(μ₀ − μ₁)²
  //    Step 4: Pixel ≥ t → white (255), else → black (0).
  //    Used for foreground/background segmentation.
  // ─────────────────────────────────────────────────────────────
  static img.Image _otsuThreshold(img.Image src) {
    // Step 1: build grayscale luminance buffer
    final w = src.width, h = src.height, N = w * h;
    final lums = Uint8List(N);
    int idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);
        lums[idx++] = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
      }
    }

    // Step 2: histogram
    final hist = List<int>.filled(256, 0);
    for (int i = 0; i < N; i++) {
      hist[lums[i]]++;
    }

    // Step 3: Otsu's method — maximise between-class variance
    double sumAll = 0;
    for (int i = 0; i < 256; i++) {
      sumAll += i * hist[i];
    }

    double sumB   = 0;
    int    wB     = 0;
    double maxVar = 0;
    int    bestT  = 0;

    for (int t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = N - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sumAll - sumB) / wF;
      final between = wB.toDouble() * wF * (mB - mF) * (mB - mF);
      if (between > maxVar) {
        maxVar = between;
        bestT  = t;
      }
    }

    // Step 4: apply threshold to produce binary image
    final dst = img.Image(width: w, height: h);
    idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final v = lums[idx++] >= bestT ? 255 : 0;
        dst.setPixelRgb(x, y, v, v, v);
      }
    }
    return dst;
  }
}

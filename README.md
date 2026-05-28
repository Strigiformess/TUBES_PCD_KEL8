# 🥦 FreshCheck — Sistem Analisis Tingkat Kesegaran Makanan

> Tugas Besar PCD — Kelompok 8  
> Topik: Computer Vision berbasis Mobile Edge Intelligence

---

## 📁 Struktur Project

```
freshcheck/
├── pubspec.yaml
├── assets/
│   ├── models/
│   │   └── freshness_model.tflite      ← taruh model TFLite di sini
│   └── labels/
│       └── labels.txt                  ← daftar kelas buah/sayur
│
└── lib/
    ├── main.dart                        ← entry point
    ├── app.dart                         ← router (go_router)
    │
    ├── core/
    │   ├── config/
    │   │   └── app_config.dart          ← Single Source of Truth konfigurasi
    │   └── theme/
    │       └── app_theme.dart           ← warna, typography, FreshnessStatus
    │
    ├── data/
    │   ├── models/
    │   │   └── scan_result.dart         ← model data + Hive adapter
    │   └── repositories/
    │       └── scan_repository.dart     ← abstraksi penyimpanan lokal
    │
    ├── domain/
    │   └── services/
    │       ├── ml_service.dart          ← ML Kit + TFLite pipeline
    │       ├── image_processor.dart     ← YUV→RGB, resize, normalize (Isolate)
    │       └── camera_service.dart      ← lifecycle-safe CameraController
    │
    └── presentation/
        ├── providers/
        │   └── scan_provider.dart       ← semua Riverpod providers & notifiers
        ├── screens/
        │   ├── home/
        │   │   ├── home_screen.dart
        │   │   └── widgets/
        │   │       └── scan_card.dart
        │   ├── camera/
        │   │   └── camera_screen.dart
        │   └── detail/
        │       └── detail_screen.dart
        └── widgets/
            └── freshness_badge.dart     ← FreshnessBadge + FreshnessScoreBar
```

---

## 🧠 Pipeline ML

```
CameraImage (YUV420)
      │
      ▼  [ImageProcessor — di Isolate terpisah]
  YUV420 → RGB
      │
      ▼
  Resize → 224×224
      │
      ▼
  Normalize [0,255] → [0.0, 1.0]
      │
      ▼
  Float32List tensor [1, 224, 224, 3]
      │
      ├──→  Google ML Kit ImageLabeler  → label buah/sayur
      │
      └──→  TFLite Interpreter          → skor kesegaran [0,100]
                                              │
                                              ▼
                                         ScanResult
```

---

## ⚙️ Setup

### 1. Install dependencies
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Tambahkan model TFLite
Taruh file model Anda di:
```
assets/models/freshness_model.tflite
```

Format input yang diharapkan: `[1, 224, 224, 3]` float32  
Format output: `[1, N_classes]` float32

### 3. Konfigurasi Android (`android/app/build.gradle`)
```gradle
android {
    aaptOptions {
        noCompress "tflite"
    }
}
```

### 4. Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

---

## 🏗️ Arsitektur

| Prinsip | Implementasi |
|---------|-------------|
| **S** Single Responsibility | Setiap class punya 1 tugas: `MLService`, `CameraService`, `ImageProcessor` terpisah |
| **O** Open/Closed | `AppConfig` bisa diperluas tanpa modifikasi class lain |
| **L** Liskov Substitution | `IScanRepository`, `IMLService` bisa diganti implementasinya |
| **I** Interface Segregation | Interface kecil & focused |
| **D** Dependency Inversion | UI bergantung pada abstraksi, bukan implementasi konkret |

**State Management:** Riverpod (`ref.watch`) sebagai Single Source of Truth

---

## 📦 Packages Utama

| Package | Kegunaan |
|---------|---------|
| `flutter_riverpod` | State management |
| `google_mlkit_image_labeling` | Deteksi label buah/sayur |
| `tflite_flutter` | Inferensi model kesegaran |
| `camera` | Preview & capture kamera |
| `image` | Preprocessing YUV→RGB |
| `hive_flutter` | Penyimpanan riwayat scan |
| `go_router` | Navigasi |

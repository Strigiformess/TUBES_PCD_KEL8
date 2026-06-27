# 🥦 FreshCheck — Sistem Analisis Tingkat Kesegaran Makanan

> Tugas Besar Pengolahan Citra Digital — Kelompok 8
> Topik: Mobile Edge Intelligence untuk Deteksi Kesegaran Buah & Sayur

---

## 🧠 Cara Kerja Sistem

```
[Foto dari Kamera/Galeri]
  → [Filter PCD: Grayscale / Gaussian Blur / Sobel Edge / Otsu Thresholding]
  → [TFLite Model: Binary Classifier Fresh vs Rotten, input 128×128]
  → [Skor 0–100 + Kategori Fresh/Medium/Rotten]
  → [Simpan ke Hive (offline-first)]
  → [Sync ke backend jika online (opsional)]
```

## 📁 Struktur Proyek

```
lib/
├── main.dart                     ← entry point
├── app_theme.dart                ← design tokens (warna, typography)
├── config/app_config.dart        ← baca .env
├── controller/app_controller.dart ← state management (ChangeNotifier)
├── model/
│   ├── history_model.dart        ← data hasil scan (Hive typeId:0)
│   ├── sync_queue_model.dart     ← antrian sync (Hive typeId:1)
│   ├── user_model.dart           ← data akun (Hive typeId:2)
│   └── result_model.dart         ← response dari backend opsional
├── service/
│   ├── tflite_service.dart       ← inferensi model on-device
│   ├── image_filter_service.dart ← 4 filter PCD pixel-level
│   ├── hive_service.dart         ← CRUD database lokal
│   ├── sync_service.dart         ← sinkronisasi offline↔online
│   ├── auth_service.dart         ← login/register (SHA-256)
│   └── api_service.dart          ← backend opsional (fallback otomatis)
└── view/
    ├── main_shell.dart           ← bottom nav: Home/Scanner/History
    ├── home_tab.dart             ← dashboard + grafik + tips
    ├── scanner_tab.dart          ← pick foto + filter PCD + analyze
    ├── history_tab.dart          ← riwayat scan + statistik
    ├── result_screen.dart        ← halaman hasil analisis
    ├── login_screen.dart
    ├── register_screen.dart
    └── settings_screen.dart

assets/
├── models/fruit_model.tflite    ← model Binary Classifier (2.8MB)
└── labels/labels.txt             ← 11 label buah/sayur
```

## 🚀 Cara Menjalankan

1. Clone repo & masuk ke folder
2. Salin .env.example ke .env dan sesuaikan
3. Jalankan: `flutter pub get`
4. Generate Hive adapters: `flutter pub run build_runner build --delete-conflicting-outputs`
5. Jalankan di emulator/device: `flutter run`

## 🔧 Tech Stack

| Komponen | Package |
|---|---|
| State management | provider ^6.1.2 |
| Database lokal | hive + hive_flutter |
| ML on-device | tflite_flutter |
| Ambil foto | image_picker |
| Image processing (PCD) | image |
| Deteksi koneksi | connectivity_plus |
| Hash password | crypto |
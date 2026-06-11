# 🔐 Environment Variables Setup Guide

Panduan lengkap untuk setup environment variables di aplikasi FreshCheck.

## ❓ Apa itu .env File?

File `.env` adalah file konfigurasi yang menyimpan **environment variables** seperti:
- API URLs
- Database connections
- Feature flags
- Debug settings
- Secret keys

**Keuntungan menggunakan .env:**
- ✅ Pisahkan konfigurasi dari code
- ✅ Easy switching antara dev/staging/production
- ✅ Jangan commit secrets ke git
- ✅ Setiap developer bisa punya konfigurasi sendiri

## 📋 Setup Steps

### 1. Copy Template

Copy file `.env.example` ke `.env`:

```bash
# Windows
copy .env.example .env

# Linux/Mac
cp .env.example .env
```

### 2. Edit Konfigurasi

Buka file `.env` dan sesuaikan dengan environment Anda:

```env
# Development
API_BASE_URL=http://localhost:3000/api
DEBUG_MODE=true
LOG_LEVEL=debug

# Production (contoh)
# API_BASE_URL=https://api.freshcheck.com/v1
# DEBUG_MODE=false
# LOG_LEVEL=error
```

### 3. File Structure

```
TUBES_PCD_KEL8/
├── .env                    ← Konfigurasi Anda (JANGAN commit)
├── .env.example            ← Template (aman di-commit)
├── .gitignore              ← Pastikan .env ada di sini
└── lib/
    └── config/
        └── app_config.dart ← Helper untuk baca .env
```

## 🔧 Available Variables

### API Configuration

```env
# Base URL untuk backend API
API_BASE_URL=http://localhost:3000/api

# Timeout (seconds)
API_TIMEOUT=30
```

**Usage:**
```dart
import 'package:freshcheck/config/app_config.dart';

final url = AppConfig.apiBaseUrl;
final timeout = AppConfig.apiTimeout;
```

### Database Configuration

```env
# MongoDB connection string
MONGODB_URI=mongodb://localhost:27017/freshcheck
```

**Usage:**
```dart
final mongoUri = AppConfig.mongoUri;
```

### Feature Flags

```env
# Enable/disable features
ENABLE_BACKEND_SYNC=true
ENABLE_PCD_FEATURES=true
```

**Usage:**
```dart
if (AppConfig.enableBackendSync) {
  // Sync ke backend
}

if (AppConfig.enablePcdFeatures) {
  // Gunakan PCD features
}
```

### Debug Settings

```env
DEBUG_MODE=false
LOG_LEVEL=info  # info, debug, warning, error
```

**Usage:**
```dart
if (AppConfig.debugMode) {
  print('Debug info...');
}
```

### App Configuration

```env
# Sync settings
MAX_RETRY_COUNT=3
SYNC_INTERVAL_MINUTES=15
```

**Usage:**
```dart
final maxRetry = AppConfig.maxRetryCount;
final syncInterval = AppConfig.syncIntervalMinutes;
```

## 💻 Using in Code

### Method 1: Via AppConfig (Recommended)

```dart
import 'package:freshcheck/config/app_config.dart';

// Di main.dart, load dulu
await AppConfig.load();

// Lalu gunakan di mana saja
final apiUrl = AppConfig.apiBaseUrl;
```

### Method 2: Direct dotenv (Advanced)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load
await dotenv.load(fileName: '.env');

// Get value
final value = dotenv.get('KEY_NAME', fallback: 'default');
```

## 🌍 Multiple Environments

Untuk handle multiple environments (dev, staging, prod):

### Option 1: Multiple .env Files

```
.env.dev
.env.staging
.env.prod
```

Load berdasarkan environment:

```dart
const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
await dotenv.load(fileName: '.env.$environment');
```

Run dengan:
```bash
flutter run --dart-define=ENV=dev
flutter run --dart-define=ENV=prod
```

### Option 2: Single .env with Comments

```env
# Development
# API_BASE_URL=http://localhost:3000/api

# Staging
# API_BASE_URL=https://staging-api.freshcheck.com

# Production (active)
API_BASE_URL=https://api.freshcheck.com/v1
```

Uncomment yang mau dipakai.

## 🔒 Security Best Practices

### ✅ DO

1. **Add .env to .gitignore**
   ```gitignore
   .env
   .env.local
   .env.*.local
   ```

2. **Use .env.example as template**
   - Commit .env.example (without secrets)
   - Team members copy ke .env

3. **Document all variables**
   - Jelaskan setiap variable di .env.example
   - Tambahkan default values

4. **Use environment-specific configs**
   - Development: localhost
   - Production: actual URLs

### ❌ DON'T

1. **NEVER commit .env file**
   - Contains sensitive data
   - Each developer has different config

2. **NEVER hardcode secrets in code**
   ```dart
   // ❌ BAD
   const apiKey = 'sk-123456';
   
   // ✅ GOOD
   final apiKey = AppConfig.apiKey;
   ```

3. **NEVER expose .env in production builds**
   - Flutter automatically excludes from release builds
   - But double-check your .gitignore

## 🧪 Testing

### Check if .env is loaded correctly:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppConfig.load();
  AppConfig.printConfig(); // Prints all config if DEBUG_MODE=true
  
  runApp(MyApp());
}
```

### Verify environment variables:

```bash
# Run app dengan log
flutter run -v
```

Lihat output:
```
=== App Configuration ===
API Base URL: http://localhost:3000/api
API Timeout: 30s
Backend Sync: true
PCD Features: true
Debug Mode: true
Max Retry: 3
Sync Interval: 15m
========================
```

## 🐛 Troubleshooting

### Error: "No file or variants found for asset: .env"

**Solution:**
1. Pastikan file `.env` ada di root project
2. Check `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. Run: `flutter clean && flutter pub get`

### Error: "Bad state: No element"

**Solution:**
Environment variable tidak ditemukan. Gunakan fallback:

```dart
// ❌ Will throw if not found
final url = dotenv.get('API_URL');

// ✅ Safe with fallback
final url = dotenv.get('API_URL', fallback: 'http://localhost:3000');
```

### Warning: .env file not found

**Solution:**
AppConfig sudah handle ini dengan graceful fallback:

```dart
static Future<void> load() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Will use fallback values
    print('Warning: .env file not found, using default values');
  }
}
```

## 📚 Additional Resources

### Flutter Dotenv Package
- Documentation: https://pub.dev/packages/flutter_dotenv
- GitHub: https://github.com/java-james/flutter_dotenv

### Best Practices
- [12 Factor App - Config](https://12factor.net/config)
- [Flutter Environment Variables Guide](https://flutter.dev/docs/deployment/flavors)

## ✅ Checklist

Sebelum commit, pastikan:

- [ ] File `.env` ada dan berisi konfigurasi yang benar
- [ ] File `.env.example` updated dengan variable baru
- [ ] `.env` sudah ada di `.gitignore`
- [ ] Tidak ada secrets hardcoded di code
- [ ] AppConfig.load() dipanggil di main.dart
- [ ] Test aplikasi berjalan dengan .env

## 🎉 Summary

Sekarang aplikasi FreshCheck Anda sudah:
- ✅ Menggunakan environment variables
- ✅ Pisah config dari code
- ✅ Secure (no secrets in git)
- ✅ Easy switching antar environments
- ✅ Ready untuk deployment

**Happy Coding! 🚀**

---

**Version:** 1.0.0  
**Last Updated:** 2026-06-12

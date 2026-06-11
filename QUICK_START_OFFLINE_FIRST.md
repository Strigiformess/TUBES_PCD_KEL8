# 🚀 Quick Start - Offline First Implementation

Panduan cepat untuk menggunakan implementasi offline-first di aplikasi FreshCheck.

## 📦 What's Included

### New Files Created:

1. **`lib/service/hive_service.dart`**
   - Service untuk mengelola local database (Hive)
   - CRUD operations untuk history
   - Sync queue management
   - Settings storage
   - Statistics calculations

2. **`lib/service/sync_service.dart`**
   - Service untuk sinkronisasi offline-online
   - Auto-detect koneksi internet
   - Auto-sync saat online
   - Retry mechanism untuk failed syncs
   - Stream untuk status updates

3. **`lib/model/sync_queue_model.dart`**
   - Model untuk menyimpan operasi yang perlu di-sync
   - Support create/update/delete operations
   - Retry counter dan error tracking

4. **`lib/widgets/sync_status_widget.dart`**
   - Widget untuk menampilkan status sync
   - Compact mode (badge) dan detailed mode
   - Interactive dialog

5. **`lib/view/settings_screen.dart`**
   - Halaman settings lengkap
   - Sync management
   - Storage info
   - Statistics
   - Actions (force sync, retry, clear data)

### Updated Files:

1. **`lib/main.dart`** - Initialize Hive dan register adapters
2. **`lib/controller/app_controller.dart`** - Integrasi dengan HiveService dan SyncService
3. **`lib/view/main_shell.dart`** - Tambah sync status badge dan settings button

## ⚡ Setup & Run

### 1. Generate Hive Adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Run App

```bash
flutter run
```

## 🎯 Key Features

### 1. Offline Scanning ✅
- Scan makanan **tanpa koneksi internet**
- TFLite model berjalan on-device
- Data tersimpan lokal otomatis

### 2. Auto Sync 🔄
- Deteksi koneksi otomatis
- Sync data ke backend saat online
- Tidak mengganggu pengalaman user

### 3. Sync Status Badge 📊
Di app bar, ada badge yang menunjukkan:
- 🟢 Online & synced
- 🟠 Online & syncing
- ⚪ Offline
- Badge menampilkan jumlah pending sync

### 4. Settings Screen ⚙️
Akses via tombol **Settings** di app bar:
- **Sync Status** - Status koneksi dan last sync time
- **Storage Info** - Total records, synced, pending
- **Statistics** - Average freshness, kategori breakdown
- **Actions**:
  - Force Sync
  - Retry Failed Syncs
  - Optimize Storage
  - Clear All Data

## 🧪 Testing Offline Mode

### Test Scenario 1: Offline Scan
1. Matikan WiFi/Data pada device
2. Buka tab **Scanner**
3. Ambil foto/pilih dari gallery
4. Tap **Analyze Now**
5. ✅ Hasil scan tetap muncul
6. ✅ Data tersimpan di History
7. ✅ Badge menunjukkan pending sync count

### Test Scenario 2: Auto Sync
1. Lakukan beberapa scan dalam mode offline
2. Lihat badge menunjukkan pending count (contoh: "3")
3. Nyalakan WiFi/Data
4. ✅ Badge berubah menjadi syncing icon
5. ✅ Auto-sync berjalan di background
6. ✅ Badge kembali hijau setelah selesai

### Test Scenario 3: Manual Sync
1. Buka **Settings** (tap icon ⚙️)
2. Lihat "Sync Status" section
3. Tap **Sync Now** button
4. ✅ Progress dialog muncul
5. ✅ Success message setelah selesai

### Test Scenario 4: Failed Sync Retry
1. Simulate offline/error condition
2. Data masuk ke sync queue dengan error
3. Buka Settings
4. Tap **Retry Failed Syncs**
5. ✅ Retry mechanism berjalan

## 📱 UI/UX Highlights

### Sync Status Badge (App Bar)
```
┌─────────────────┐
│  🟢  3          │  ← Online dengan 3 pending syncs
└─────────────────┘

Tap badge → Dialog dengan detail status
```

### Settings Screen Sections

```
┌────────────────────────────────┐
│ Sync Status                    │
├────────────────────────────────┤
│ 🟢 Online                      │
│ Last synced: 2m ago            │
│                                │
│ ⚠️ 5 items waiting to sync    │
│ [Sync Now]                     │
└────────────────────────────────┘

┌────────────────────────────────┐
│ Storage                        │
├────────────────────────────────┤
│ 💾 Total Records: 24           │
│ ☁️  Synced: 19                 │
│ ⏳ Pending Sync: 5             │
└────────────────────────────────┘

┌────────────────────────────────┐
│ Statistics                     │
├────────────────────────────────┤
│ 📊 Average Freshness: 78.5%   │
│ ✅ Fresh Items: 15             │
│ ⚠️  Medium Items: 7            │
│ ❌ Rotten Items: 2             │
└────────────────────────────────┘
```

## 💡 Usage Examples

### From Controller

```dart
final ctrl = context.read<AppController>();

// Check online status
if (ctrl.isOnline) {
  print('Device online');
}

// Check pending syncs
print('Pending: ${ctrl.pendingSyncCount}');

// Manual sync
final result = await ctrl.syncNow();
print('Synced: ${result.synced}, Failed: ${result.failed}');

// Search history
final results = ctrl.searchHistory('apple');

// Get statistics
final stats = ctrl.getStatsByKategori();
print('Fresh: ${stats['Fresh']}');
```

### From Anywhere

```dart
// Direct access to HiveService
final totalScans = HiveService.getTotalScans();
final avgFreshness = HiveService.getAverageFreshness();
final pendingCount = HiveService.getPendingSyncCount();

// Sync service
final syncService = SyncService();
final isOnline = syncService.isOnline;
final isSyncing = syncService.isSyncing;
```

## 🔧 Configuration

### Auto-Sync Settings

Sudah enabled by default. Untuk customize:

```dart
// Ubah max retry count
item.shouldRetry(maxRetries: 5) // Default: 3

// Ubah cleanup period
HiveService.cleanupSyncQueue(daysOld: 14) // Default: 7
```

### Backend Integration

Update `sync_service.dart` untuk integrasi dengan API Anda:

```dart
// File: lib/service/sync_service.dart

Future<void> _syncCreate(SyncQueueItem item) async {
  // REPLACE THIS:
  // await Future.delayed(Duration(milliseconds: 500));
  
  // WITH YOUR API CALL:
  final response = await http.post(
    Uri.parse('https://your-api.com/history'),
    body: jsonEncode(item.data),
    headers: {'Content-Type': 'application/json'},
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to sync: ${response.body}');
  }
}

// Similar untuk _syncUpdate() dan _syncDelete()
```

## 📊 Storage Management

### Database Size
- History: ~1KB per item
- Sync Queue: ~500B per item
- Typical usage: 100 scans = ~150KB

### Optimization
Auto-optimize dengan:
```dart
await HiveService.compact();
```

### Factory Reset
Clear semua data:
```dart
await HiveService.deleteAllData();
```

## 🐛 Troubleshooting

### Problem: Sync tidak jalan otomatis
**Solution:**
1. Check device connection
2. Check permission (internet access)
3. Review logs: `flutter logs | grep -i sync`

### Problem: Pending sync terus bertambah
**Solution:**
1. Check backend API status
2. Tap "Retry Failed Syncs" di Settings
3. Review error messages di sync queue

### Problem: App lambat setelah banyak data
**Solution:**
1. Tap "Optimize Storage" di Settings
2. Consider pagination untuk history list

## 🔐 Security Notes

### Current Implementation
- Data disimpan **unencrypted** di device
- Image path disimpan, bukan file binary
- Suitable untuk non-sensitive data

### For Production
Jika perlu encrypt data:

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  hive_secure_storage: ^0.1.0
```

```dart
// Encrypt Hive box
final encryptionKey = await secureStorage.read(key: 'hive_key');
final box = await Hive.openBox('history',
  encryptionCipher: HiveAesCipher(encryptionKey),
);
```

## 📈 Performance Tips

1. **Batch Sync**: Sync berjalan batch, tidak per-item
2. **Background Sync**: Non-blocking, tidak freeze UI
3. **Lazy Loading**: History di-load on-demand
4. **Indexed Queries**: Hive support indexing untuk fast queries

## 🎉 That's It!

Aplikasi Anda sekarang **fully offline-capable** dengan:
- ✅ Local-first architecture
- ✅ Auto-sync ke backend
- ✅ Comprehensive sync management
- ✅ Statistics & analytics
- ✅ User-friendly status indicators

**Happy Coding! 🚀**

---

**Need Help?**
- Check [OFFLINE_FIRST_IMPLEMENTATION.md](./OFFLINE_FIRST_IMPLEMENTATION.md) untuk detail teknis
- Review code di `/lib/service/` dan `/lib/model/`
- Test semua scenarios di atas

**Version:** 1.0.0  
**Date:** 2026-06-12

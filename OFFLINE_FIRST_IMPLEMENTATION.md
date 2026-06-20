# Implementasi Offline-First dengan Hive

Dokumen ini menjelaskan implementasi **offline-first architecture** menggunakan Hive sebagai local database untuk aplikasi FreshCheck.

## 📋 Overview

Aplikasi FreshCheck menggunakan pendekatan **offline-first**, yang berarti:
- ✅ Aplikasi tetap berfungsi penuh tanpa koneksi internet
- ✅ Semua data disimpan secara lokal menggunakan Hive
- ✅ Sinkronisasi otomatis ke backend saat online
- ✅ Queue management untuk operasi yang gagal
- ✅ Conflict resolution untuk data yang bentrok

## 🏗️ Arsitektur

```
┌─────────────────────────────────────────────────────┐
│                   UI Layer                          │
│  (Scanner, History, Settings Screens)               │
└───────────────────┬─────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────┐
│               AppController                         │
│  (Business Logic & State Management)                │
└───────────┬───────────────────────┬─────────────────┘
            │                       │
┌───────────▼──────────┐  ┌────────▼─────────────────┐
│   HiveService        │  │   SyncService            │
│ (Local Database)     │  │ (Online/Offline Sync)    │
└──────────────────────┘  └──────────────────────────┘
            │                       │
┌───────────▼───────────────────────▼─────────────────┐
│                   Hive Boxes                        │
│  • history_box (HistoryItem)                        │
│  • sync_queue_box (SyncQueueItem)                   │
│  • settings_box (Key-Value pairs)                   │
└─────────────────────────────────────────────────────┘
```

## 📦 Hive Boxes

### 1. History Box
Menyimpan semua riwayat scan makanan.

**Model:** `HistoryItem`
```dart
- id: String
- foodName: String
- imagePath: String
- skor: double
- kategori: String
- createdAt: DateTime
- skorWarna: double
- skorKecerahan: double
- skorTekstur: double
- skorKerusakan: double
```

### 2. Sync Queue Box
Menyimpan operasi yang perlu di-sync ke backend.

**Model:** `SyncQueueItem`
```dart
- id: String
- historyId: String
- operation: String (create/update/delete)
- data: Map<String, dynamic>
- isSynced: bool
- createdAt: DateTime
- syncedAt: DateTime?
- retryCount: int
- errorMessage: String?
```

### 3. Settings Box
Menyimpan pengaturan dan metadata aplikasi.

**Contoh data:**
- `last_sync_time`: DateTime terakhir sync berhasil
- `auto_sync_enabled`: Boolean untuk auto-sync
- Custom user preferences

## 🔄 Sync Flow

### Flow Diagram

```
┌─────────────┐
│ User Action │
│ (Scan/Edit) │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Save to Hive    │
│ (HiveService)   │
└──────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ Add to Sync Queue   │
│ (operation: create) │
└──────┬──────────────┘
       │
       ▼
    ┌──────┐
    │Online?│
    └──┬───┘
       │
   ┌───┴────┐
   │        │
  YES      NO
   │        │
   ▼        ▼
┌──────┐  ┌────────────────┐
│ Sync │  │ Wait for online│
│ Now  │  │ (auto-retry)   │
└──────┘  └────────────────┘
   │
   ▼
┌──────────────┐
│ Mark Synced  │
└──────────────┘
```

### Proses Sync

1. **Create/Update/Delete Operation**
   - Data disimpan ke Hive (local-first)
   - Operation ditambahkan ke sync queue
   - Auto-sync triggered jika online

2. **Auto Sync**
   - Monitoring koneksi internet menggunakan `connectivity_plus`
   - Saat device online, sync queue diproses otomatis
   - Retry otomatis untuk failed operations (max 3x)

3. **Manual Sync**
   - User bisa trigger manual sync dari Settings
   - Force retry untuk failed operations

4. **Conflict Resolution**
   - Timestamp-based resolution (last write wins)
   - User dapat melihat failed syncs di Settings

## 🛠️ API Reference

### HiveService

```dart
// History Operations
HiveService.saveHistory(HistoryItem item)
HiveService.getAllHistory() → List<HistoryItem>
HiveService.getHistoryById(String id) → HistoryItem?
HiveService.deleteHistory(String id)
HiveService.searchHistory(String query) → List<HistoryItem>

// Sync Queue Operations
HiveService.addToSyncQueue(SyncQueueItem item)
HiveService.getPendingSyncItems() → List<SyncQueueItem>
HiveService.markAsSynced(String id)
HiveService.getPendingSyncCount() → int

// Settings Operations
HiveService.saveSetting(String key, dynamic value)
HiveService.getSetting<T>(String key, {T? defaultValue}) → T?

// Statistics
HiveService.getAverageFreshness() → double
HiveService.getTotalScans() → int
HiveService.getStatsByKategori() → Map<String, int>

// Maintenance
HiveService.compact() // Optimize storage
HiveService.deleteAllData() // Factory reset
```

### SyncService

```dart
// Initialize
SyncService().init()

// Sync Operations
SyncService().syncAll() → Future<SyncResult>
SyncService().retryFailedSyncs() → Future<SyncResult>

// Status
SyncService().isOnline → bool
SyncService().isSyncing → bool
SyncService().pendingSyncCount → int
SyncService().lastSyncTime → DateTime?

// Listen to sync status
SyncService().syncStatusStream → Stream<SyncStatus>
```

### AppController (Updated)

```dart
// New offline-first methods
ctrl.syncNow() → Future<SyncResult>
ctrl.retryFailedSyncs() → Future<SyncResult>
ctrl.searchHistory(String query) → List<HistoryItem>
ctrl.getHistoryByKategori(String kategori) → List<HistoryItem>
ctrl.getStatsByKategori() → Map<String, int>

// Status properties
ctrl.isSyncing → bool
ctrl.isOnline → bool
ctrl.pendingSyncCount → int
ctrl.lastSyncTime → DateTime?
```

## 🎯 Fitur Offline-First

### 1. ✅ Full Offline Support
- Semua fitur scanner berfungsi offline
- TFLite model berjalan on-device
- History tersimpan lokal

### 2. 🔄 Auto Sync
- Deteksi koneksi internet otomatis
- Sync queue diproses saat online
- Background sync (tidak mengganggu user)

### 3. 🔁 Retry Mechanism
- Max 3x retry untuk failed operations
- Exponential backoff (opsional)
- Manual retry dari Settings

### 4. 📊 Sync Status UI
- Badge di app bar menampilkan status
- Pending sync count
- Last sync time
- Detail di Settings screen

### 5. 💾 Storage Management
- Database optimization (compact)
- Cleanup old synced items (>7 days)
- Factory reset option

### 6. 📈 Statistics
- Average freshness score
- Category breakdown (Fresh/Medium/Rotten)
- Daily scan history
- All computed from local data

## 🚀 Usage Examples

### Basic Usage

```dart
// Save history (auto-queued for sync)
await ctrl.analyze(); // Otomatis save & add to queue

// Manual sync
final result = await ctrl.syncNow();
if (result.success) {
  print('Synced ${result.synced} items');
}

// Search history
final results = ctrl.searchHistory('apple');

// Get statistics
final stats = ctrl.getStatsByKategori();
print('Fresh: ${stats['Fresh']}');
```

### Listen to Sync Status

```dart
SyncService().syncStatusStream.listen((status) {
  switch (status.state) {
    case SyncState.syncing:
      print('Syncing: ${status.message}');
      break;
    case SyncState.completed:
      print('Sync complete!');
      break;
    case SyncState.error:
      print('Sync error: ${status.message}');
      break;
  }
});
```

## 🧪 Testing

### Test Offline Mode

1. Matikan WiFi/Data
2. Lakukan scan → Data tetap tersimpan
3. Lihat pending sync count di badge
4. Nyalakan koneksi → Auto sync

### Test Sync Queue

1. Scan beberapa item dalam mode offline
2. Buka Settings → Lihat pending items
3. Tap "Force Sync"
4. Verifikasi semua data ter-sync

### Test Retry Mechanism

1. Force offline mode
2. Lakukan operations
3. Simulate sync failure (3x)
4. Check failed items
5. Manual retry

## ⚠️ Important Notes

### Backend Integration

Saat ini, sync operations menggunakan placeholder:

```dart
// sync_service.dart - _syncCreate()
await Future.delayed(Duration(milliseconds: 500));
```

**TODO:** Replace dengan actual API calls:

```dart
Future<void> _syncCreate(SyncQueueItem item) async {
  await ApiService.createHistory(item.data);
}

Future<void> _syncUpdate(SyncQueueItem item) async {
  await ApiService.updateHistory(item.historyId, item.data);
}

Future<void> _syncDelete(SyncQueueItem item) async {
  await ApiService.deleteHistory(item.historyId);
}
```

### Data Migration

Jika ada perubahan schema:

```dart
// Tambahkan versioning di Hive
@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0) String id;
  // ... existing fields ...
  @HiveField(10) int? schemaVersion; // New field
}

// Migration logic
if (item.schemaVersion == null || item.schemaVersion < 2) {
  // Migrate data
  item.schemaVersion = 2;
  await item.save();
}
```

## 🔐 Security Considerations

1. **Sensitive Data:** Jika menyimpan data sensitif, gunakan `hive_secure_storage`
2. **Image Storage:** Path gambar disimpan, bukan file binary
3. **Encryption:** Pertimbangkan encrypt Hive box untuk production

## 📚 Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.0.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

## 🎉 Benefits

✅ **User Experience**
- Aplikasi responsif (tidak tunggu network)
- Offline functionality
- Seamless sync

✅ **Performance**
- Fast read/write (local database)
- Minimal network calls
- Battery efficient

✅ **Reliability**
- Data tidak hilang saat offline
- Auto-retry mechanism
- Conflict resolution

✅ **Developer Experience**
- Simple API
- Type-safe (Hive adapters)
- Easy debugging

## 📞 Support

Untuk pertanyaan atau masalah:
1. Check dokumentasi Hive: https://docs.hivedb.dev
2. Check connectivity_plus: https://pub.dev/packages/connectivity_plus
3. Review kode di folder `/lib/service/` dan `/lib/model/`

---

**Version:** 1.0.0  
**Last Updated:** 2026-06-12  
**Author:** Tubes PCD Kelompok 8

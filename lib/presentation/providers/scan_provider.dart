import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/scan_result.dart';
import '../../data/repositories/scan_repository.dart';
import '../../domain/services/ml_service.dart';
import '../../domain/services/camera_service.dart';
import '../../core/theme/app_theme.dart';

// ── Repository provider ──────────────────────────────────────────────────────

final scanRepositoryProvider = Provider<IScanRepository>((ref) {
  return ScanRepository();
});

// ── ML Service provider ──────────────────────────────────────────────────────

final mlServiceProvider = Provider<IMLService>((ref) {
  final service = MLService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Camera Service provider ──────────────────────────────────────────────────

final cameraServiceProvider = ChangeNotifierProvider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Scan history provider ─────────────────────────────────────────────────────

final scanHistoryProvider =
    AsyncNotifierProvider<ScanHistoryNotifier, List<ScanResult>>(
  ScanHistoryNotifier.new,
);

class ScanHistoryNotifier extends AsyncNotifier<List<ScanResult>> {
  @override
  Future<List<ScanResult>> build() async {
    final repo = ref.read(scanRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(scanRepositoryProvider).getAll(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(scanRepositoryProvider).delete(id);
    await refresh();
  }
}

// ── Current scan state ────────────────────────────────────────────────────────

sealed class ScanState {
  const ScanState();
}
class ScanIdle    extends ScanState { const ScanIdle(); }
class ScanLoading extends ScanState { const ScanLoading(); }
class ScanSuccess extends ScanState {
  final ScanResult result;
  const ScanSuccess(this.result);
}
class ScanError   extends ScanState {
  final String message;
  const ScanError(this.message);
}

final scanStateProvider =
    StateNotifierProvider<ScanStateNotifier, ScanState>((ref) {
  return ScanStateNotifier(ref);
});

class ScanStateNotifier extends StateNotifier<ScanState> {
  final Ref _ref;
  static const _uuid = Uuid();

  ScanStateNotifier(this._ref) : super(const ScanIdle());

  /// Jalankan analisis pada file gambar (hasil dari kamera).
  Future<void> analyze(File imageFile) async {
    state = const ScanLoading();

    try {
      final mlService = _ref.read(mlServiceProvider);
      await mlService.init();

      final result = await mlService.analyzeFile(imageFile);
      if (result == null) {
        state = const ScanError('Tidak dapat mendeteksi objek. Coba lagi.');
        return;
      }

      final scanResult = ScanResult(
        id:             _uuid.v4(),
        label:          result.label,
        freshnessScore: result.freshnessScore,
        confidence:     result.confidence,
        scannedAt:      DateTime.now(),
        imagePath:      imageFile.path,
        pipeline:       result.pipeline,
      );

      // Simpan ke repository
      await _ref.read(scanRepositoryProvider).save(scanResult);

      // Refresh history
      await _ref.read(scanHistoryProvider.notifier).refresh();

      state = ScanSuccess(scanResult);
    } catch (e) {
      state = ScanError('Analisis gagal: ${e.toString()}');
    }
  }

  void reset() => state = const ScanIdle();
}

// ── Weekly stats ──────────────────────────────────────────────────────────────

final weeklyStatsProvider = Provider<({int totalScans, int freshCount})>((ref) {
  final historyAsync = ref.watch(scanHistoryProvider);
  return historyAsync.when(
    data: (history) {
      final now   = DateTime.now();
      final week  = now.subtract(const Duration(days: 7));
      final thisWeek = history.where((s) => s.scannedAt.isAfter(week)).toList();
      final fresh = thisWeek
          .where((s) => s.status == FreshnessStatus.fresh)
          .length;
      return (totalScans: thisWeek.length, freshCount: fresh);
    },
    loading: () => (totalScans: 0, freshCount: 0),
    error:   (_, __) => (totalScans: 0, freshCount: 0),
  );
});

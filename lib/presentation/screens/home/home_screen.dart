import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshCheck'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cek Kesegaran Makananmu!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Deteksi kualitas buah dan sayur menggunakan Pengolahan Citra Digital.",
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary.withValues(alpha:0.7), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    title: "Kamera",
                    icon: Icons.camera_alt_rounded,
                    cardColor: AppTheme.accentBlue,
                    route: '/camera',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    title: "Galeri",
                    icon: Icons.photo_library_rounded,
                    cardColor: AppTheme.accentYellow,
                    route: '/gallery',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color cardColor, required String route}) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha:0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.textPrimary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
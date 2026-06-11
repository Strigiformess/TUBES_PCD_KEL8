import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../service/auth_service.dart';    // ← baru
import 'home_tab.dart';
import 'scanner_tab.dart';
import 'history_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _titles = ['FreshCheck', 'Scanner', 'Scan History'];

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthService>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    final tabs = [
      const HomeTab(),
      const ScannerTab(),
      const HistoryTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppTheme.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_rounded, color: AppTheme.green, size: 18),
          ),
          const SizedBox(width: 10),
          Text(_titles[_tab]),
        ]),
        actions: [
          // Avatar + nama user
          if (auth.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text(
                auth.currentUser!.name.split(' ').first,
                style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
              )),
            ),
          // Tombol logout
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: tabs[_tab],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.greenLight,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.document_scanner_outlined),
              selectedIcon: Icon(Icons.document_scanner_rounded),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
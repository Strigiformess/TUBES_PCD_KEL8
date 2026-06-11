import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/sync_status_widget.dart';
import 'home_tab.dart';
import 'scanner_tab.dart';
import 'history_tab.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _titles = ['FreshCheck', 'Scanner', 'Scan History'];

  @override
  Widget build(BuildContext context) {
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.eco_rounded, color: AppTheme.green, size: 18),
          ),
          const SizedBox(width: 10),
          Text(_titles[_tab]),
        ]),
        actions: [
          // Sync Status Badge
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncStatusWidget(),
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: tabs[_tab],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
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

// view/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../service/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthService>().login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      // AuthService notifyListeners → MaterialApp root rebuild → ke MainShell
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Logo ──
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.eco_rounded, color: AppTheme.green, size: 28),
            ),
            const SizedBox(height: 24),

            const Text('Selamat datang\nkembali 👋', style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary, height: 1.2,
            )),
            const SizedBox(height: 8),
            const Text('Masuk untuk melanjutkan ke FreshCheck.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),

            const SizedBox(height: 36),

            // ── Form ──
            const _Label('Email'),
            const SizedBox(height: 6),
            _Field(
              controller: _emailCtrl,
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            const _Label('Password'),
            const SizedBox(height: 6),
            _Field(
              controller: _passwordCtrl,
              hint: 'Masukkan password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textSecondary, size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),

            // ── Error ──
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.redLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppTheme.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                    style: const TextStyle(color: AppTheme.red, fontSize: 13))),
                ]),
              ),
            ],

            const SizedBox(height: 28),

            // ── Login button ──
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.green.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Masuk', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Register link ──
            Center(child: GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: RichText(text: const TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                children: [
                  TextSpan(text: 'Daftar sekarang',
                    style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w700)),
                ],
              )),
            )),
          ]),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
  ));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.green, width: 1.5),
      ),
    ),
  );
}
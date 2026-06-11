// view/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Password dan konfirmasi tidak cocok.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthService>().register(
        name:     _nameCtrl.text,
        email:    _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      // Sukses → AuthService notifyListeners → root rebuild → ke MainShell
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
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            const Text('Buat akun baru', style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            )),
            const SizedBox(height: 6),
            const Text('Daftarkan diri untuk mulai menggunakan FreshCheck.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),

            const SizedBox(height: 28),

            _Label('Nama Lengkap'),
            const SizedBox(height: 6),
            _Field(
              controller: _nameCtrl,
              hint: 'Masukkan nama kamu',
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 14),

            _Label('Email'),
            const SizedBox(height: 6),
            _Field(
              controller: _emailCtrl,
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            _Label('Password'),
            const SizedBox(height: 6),
            _Field(
              controller: _passwordCtrl,
              hint: 'Minimal 6 karakter',
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

            const SizedBox(height: 14),

            _Label('Konfirmasi Password'),
            const SizedBox(height: 6),
            _Field(
              controller: _confirmCtrl,
              hint: 'Ulangi password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
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

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.green.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Daftar', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 20),

            Center(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                children: [
                  TextSpan(text: 'Masuk',
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
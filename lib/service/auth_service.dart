// service/auth_service.dart
// Login/Register menggunakan Hive lokal.
// Password di-hash dengan SHA-256 sebelum disimpan.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../model/user_model.dart';

class AuthService extends ChangeNotifier {
  static const _usersBox   = 'users';
  static const _sessionBox = 'session';
  static const _sessionKey = 'currentUserId';

  late Box<UserModel> _users;
  late Box<String>    _session;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inisialisasi: buka box & restore sesi.
  Future<void> init() async {
    _users   = await Hive.openBox<UserModel>(_usersBox);
    _session = await Hive.openBox<String>(_sessionBox);
    _restoreSession();
  }

  void _restoreSession() {
    final id = _session.get(_sessionKey);
    if (id != null) {
      _currentUser = _users.get(id);
      notifyListeners();
    }
  }

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  /// Daftar akun baru.
  /// Throws String jika validasi gagal.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) throw 'Nama tidak boleh kosong.';
    if (!trimEmail.contains('@')) throw 'Format email tidak valid.';
    if (password.length < 6) throw 'Password minimal 6 karakter.';

    final exists = _users.values.any((u) => u.email == trimEmail);
    if (exists) throw 'Email sudah terdaftar.';

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: trimEmail,
      passwordHash: _hash(password),
      createdAt: DateTime.now(),
    );

    await _users.put(user.id, user);
    await _startSession(user);
  }

  /// Login dengan email + password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final trimEmail = email.trim().toLowerCase();

    final user = _users.values.firstWhere(
      (u) => u.email == trimEmail,
      orElse: () => throw 'Email tidak ditemukan.',
    );

    if (user.passwordHash != _hash(password)) {
      throw 'Password salah.';
    }

    await _startSession(user);
  }

  Future<void> _startSession(UserModel user) async {
    _currentUser = user;
    await _session.put(_sessionKey, user.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _session.delete(_sessionKey);
    notifyListeners();
  }
}
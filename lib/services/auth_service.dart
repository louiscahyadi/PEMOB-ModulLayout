import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../utils/logger.dart';

// mengelola proses autentikasi pengguna
// menangani operasi login, logout, registrasi dan manajemen sesi
class AuthService {
  // mengimplementasi pola singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Uuid _uuid = const Uuid();

  // menyimpan data pengguna yang sedang aktif
  User? _currentUser;

  // mengakses data pengguna yang sedang aktif
  User? get currentUser => _currentUser;

  // menyimpan data pengguna sementara
  // catatan: pada implementasi nyata, gunakan database
  final Map<String, Map<String, String>> _users = {
    'user1': {
      'id': 'user1',
      'username': 'ketut',
      'password': _hashPassword('password123'),
      'name': 'I Ketut Resika Arthana',
      'email': 'ketut@example.com',
      'phoneNumber': '0878-1234-1024',
    },
  };

  // mengenkripsi password menggunakan algoritma SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // memeriksa status login pengguna
  // mengembalikan `true` jika pengguna sudah login, `false` jika belum
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      Logger.info('AuthService: Memeriksa status login untuk userId: $userId');

      if (userId != null) {
        final userData = _users[userId];
        if (userData != null) {
          _currentUser = User(
            id: userData['id']!,
            username: userData['username']!,
            name: userData['name']!,
            email: userData['email']!,
            phoneNumber: userData['phoneNumber']!,
          );
          Logger.info(
              'AuthService: Pengguna ditemukan dan dimuat: ${_currentUser?.username}');
          return true;
        } else {
          Logger.warning(
              'AuthService: Data pengguna tidak ditemukan untuk userId: $userId');
        }
      } else {
        Logger.info(
            'AuthService: Tidak ada userId yang ditemukan di preferences');
      }
    } catch (e) {
      Logger.error('AuthService: Error saat memeriksa status login: $e');
    }

    return false;
  }

  // melakukan proses login pengguna
  // mengembalikan `true` jika login berhasil, `false` jika gagal
  Future<bool> login(String username, String password) async {
    try {
      Logger.info('AuthService: Mencoba login untuk username: $username');

      // mencari pengguna berdasarkan username
      String? userId;
      Map<String, String>? userData;

      _users.forEach((id, data) {
        if (data['username'] == username) {
          userId = id;
          userData = data;
          Logger.info('AuthService: Pengguna ditemukan: $id');
        }
      });

      if (userId == null || userData == null) {
        Logger.warning('AuthService: Pengguna tidak ditemukan: $username');
        return false; // pengguna tidak ditemukan
      }

      // memverifikasi password
      final hashedPassword = _hashPassword(password);

      if (userData!['password'] != hashedPassword) {
        Logger.warning('AuthService: Password salah untuk pengguna: $username');
        return false; // password salah
      }

      // membuat objek pengguna
      _currentUser = User(
        id: userData!['id']!,
        username: userData!['username']!,
        name: userData!['name']!,
        email: userData!['email']!,
        phoneNumber: userData!['phoneNumber']!,
      );

      // menyimpan status login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      Logger.info(
          'AuthService: Login berhasil untuk pengguna: $username dengan ID: ${_currentUser!.id}');
      return true;
    } catch (e) {
      Logger.error('AuthService: Error saat login: $e');
      return false;
    }
  }

  // melakukan proses logout pengguna
  // mengembalikan `true` jika logout berhasil, `false` jika gagal
  Future<bool> logout() async {
    try {
      Logger.info('AuthService: Logout pengguna: ${_currentUser?.username}');
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      return true;
    } catch (e) {
      Logger.error('AuthService: Error saat logout: $e');
      return false;
    }
  }

  // melakukan proses registrasi pengguna baru
  // mengembalikan `true` jika registrasi berhasil, `false` jika gagal
  Future<bool> register(String username, String password, String name,
      String email, String phoneNumber) async {
    try {
      Logger.info('AuthService: Mencoba mendaftarkan pengguna baru: $username');

      // memeriksa apakah username sudah ada
      bool userExists = false;
      _users.forEach((_, data) {
        if (data['username'] == username) {
          userExists = true;
          Logger.warning('AuthService: Username sudah digunakan: $username');
        }
      });

      if (userExists) {
        return false; // username sudah digunakan
      }

      // membuat pengguna baru
      final userId = _uuid.v4();
      final hashedPassword = _hashPassword(password);

      _users[userId] = {
        'id': userId,
        'username': username,
        'password': hashedPassword,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
      };

      // membuat objek pengguna
      _currentUser = User(
        id: userId,
        username: username,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      // menyimpan status login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);

      Logger.info(
          'AuthService: Registrasi berhasil untuk pengguna: $username dengan ID: $userId');
      return true;
    } catch (e) {
      Logger.error('AuthService: Error saat registrasi: $e');
      return false;
    }
  }

  // mengubah password pengguna
  // mengembalikan `true` jika perubahan berhasil, `false` jika gagal
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null) {
        Logger.warning(
            'AuthService: Tidak ada pengguna yang login saat mencoba mengubah password');
        return false;
      }

      final userData = _users[_currentUser!.id];
      if (userData == null) {
        Logger.warning(
            'AuthService: Data pengguna tidak ditemukan untuk ID: ${_currentUser!.id}');
        return false;
      }

      // memverifikasi password saat ini
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (userData['password'] != hashedCurrentPassword) {
        Logger.warning('AuthService: Password saat ini salah');
        return false;
      }

      // mengubah password
      final hashedNewPassword = _hashPassword(newPassword);
      _users[_currentUser!.id]!['password'] = hashedNewPassword;

      Logger.info(
          'AuthService: Password berhasil diubah untuk pengguna: ${_currentUser!.username}');
      return true;
    } catch (e) {
      Logger.error('AuthService: Error saat mengubah password: $e');
      return false;
    }
  }
}

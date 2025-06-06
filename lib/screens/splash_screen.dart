import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// menampilkan layar splash sebagai tampilan awal aplikasi
// melakukan pengecekan status autentikasi pengguna untuk menentukan halaman tujuan
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // melakukan validasi status autentikasi dan mengarahkan ke halaman yang sesuai
  Future<void> _checkLoginStatus() async {
    try {
      // memberikan jeda waktu untuk menampilkan splash screen
      await Future.delayed(const Duration(seconds: 2));

      // memvalidasi status autentikasi pengguna
      final isLoggedIn = await _authService.isLoggedIn();
      Logger.info('splash_screen: mencatat status autentikasi: $isLoggedIn');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                isLoggedIn ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      Logger.error('splash_screen: gagal memvalidasi status autentikasi: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // mengatur warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Koperasi Undiksha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // warna utama
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1F2937)), // warna utama
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// layar splash yang ditampilkan saat aplikasi pertama kali dibuka
// layar ini memeriksa status login pengguna dan mengarahkan ke layar yang sesuai
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

  // memeriksa status login pengguna dan navigasi ke layar yang sesuai
  Future<void> _checkLoginStatus() async {
    try {
      // delay untuk splash screen
      await Future.delayed(const Duration(seconds: 2));

      // mengecek status login
      final isLoggedIn = await _authService.isLoggedIn();
      Logger.info('SplashScreen: Status login: $isLoggedIn');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                isLoggedIn ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      Logger.error('SplashScreen: Error saat memeriksa status login: $e');
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
      backgroundColor: const Color(0xFFF8F9FA), // Light background
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
                color: Color(0xFF1F2937), // Main color
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1F2937)), // Main color
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

/// mengimplementasikan layar login untuk proses autentikasi pengguna
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // memproses autentikasi pengguna
  Future<void> _login() async {
    // melakukan validasi input form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      Logger.info('menginisiasi proses login untuk pengguna: $username');

      final success = await _authService.login(username, password);

      if (success) {
        Logger.info('berhasil melakukan autentikasi untuk pengguna: $username');

        // menavigasikan pengguna ke halaman utama
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        Logger.warning('gagal melakukan autentikasi untuk pengguna: $username');

        setState(() {
          _errorMessage = 'Username atau password salah';
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('terjadi kesalahan pada proses login: $e');

      setState(() {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // mengatur warna latar belakang
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1F2937), // mengatur warna utama aplikasi
        title: const Text('Koperasi Undiksha'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // menampilkan logo aplikasi
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 32.0),

                // menampilkan pesan error
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2), // warna latar pesan error
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                          color: const Color(
                              0xFFFECACA)), // warna border pesan error
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Color(0xFFB91C1C)), // warna teks pesan error
                      textAlign: TextAlign.center,
                    ),
                  ),

                // mengimplementasikan input username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Username tidak boleh kosong'
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16.0),

                // mengimplementasikan input password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),

                // menambahkan tautan lupa password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF1F2937), // warna utama aplikasi
                    ),
                    child: const Text('Lupa Password?'),
                  ),
                ),
                const SizedBox(height: 24.0),

                // mengimplementasikan tombol login
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1F2937), // warna utama aplikasi
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
                const SizedBox(height: 16.0),

                // menambahkan tautan registrasi
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF1F2937), // warna utama aplikasi
                  ),
                  child: const Text('Belum punya akun? Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// mengelola tampilan untuk registrasi pengguna baru
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // memproses data registrasi pengguna
  Future<void> _register() async {
    // memvalidasi input form
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
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      Logger.info(
          'RegisterScreen: Mencoba mendaftarkan pengguna baru: $username');

      final success = await _authService.register(
        username,
        password,
        name,
        email,
        phone,
      );

      if (success) {
        Logger.info(
            'RegisterScreen: Registrasi berhasil untuk pengguna: $username');

        // menavigasi ke home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        Logger.warning(
            'RegisterScreen: Registrasi gagal untuk pengguna: $username');

        setState(() {
          _errorMessage =
              'Username sudah digunakan. Silakan pilih username lain.';
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('RegisterScreen: Error saat registrasi: $e');

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
        backgroundColor: const Color(0xFF1F2937), // mengatur warna primary
        title: const Text('Daftar Akun'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // menampilkan pesan error jika terjadi kesalahan
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), // Light red background
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                        color: const Color(0xFFFCA5A5)), // Light red border
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFB91C1C)), // Dark red text
                    textAlign: TextAlign.center,
                  ),
                ),

              // mengatur input nama lengkap
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Nama lengkap tidak boleh kosong'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // mengatur input email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // mengatur input nomor telepon
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Nomor telepon tidak boleh kosong'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // mengatur input username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  if (value.length < 4) {
                    return 'Username minimal 4 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // mengatur input password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 24.0),

              // menampilkan tombol daftar
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1F2937), // Primary dark color
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
                        'DAFTAR',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
              const SizedBox(height: 16.0),

              // menampilkan link ke halaman login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF1F2937), // Primary dark color
                ),
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

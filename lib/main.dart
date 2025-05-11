import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/logger.dart';

// memulai eksekusi fungsi utama aplikasi secara asynchronous
void main() async {
  // menginisialisasi binding flutter untuk memastikan widget telah siap
  WidgetsFlutterBinding.ensureInitialized();

  // mengatur level minimum logger dan mencatat permulaan aplikasi
  Logger.setMinLevel(LogLevel.debug);
  Logger.info('Aplikasi dimulai');

  // mengonfigurasi format tanggal sesuai lokalisasi indonesia
  await initializeDateFormatting('id_ID', null);
  Logger.info('Format tanggal Indonesia diinisialisasi');

  // mempersiapkan layanan notifikasi aplikasi
  await NotificationService().initialize();

  // mengkustomisasi tampilan sistem ui
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // mengeksekusi aplikasi dengan widget utama
  runApp(const MyApp());
}

// widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koperasi Undiksha',
      theme: ThemeData(
        primaryColor: const Color(0xFF706D54),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF706D54),
          primary: const Color(0xFF706D54),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF706D54),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF706D54),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF706D54),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const SplashScreen(),
    );
  }
}

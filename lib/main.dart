import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/logger.dart';

// fungsi utama aplikasi
void main() async {
  // memastikan binding flutter diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // menginisialisasi logger
  Logger.setMinLevel(LogLevel.debug);
  Logger.info('Aplikasi dimulai');

  // menginisialisasi format tanggal untuk locale indonesia
  await initializeDateFormatting('id_ID', null);
  Logger.info('Format tanggal Indonesia diinisialisasi');

  // menginisialisasi service notifikasi
  await NotificationService().initialize();

  // emngatur tampilan UI sistem
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // menjalankan aplikasi
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

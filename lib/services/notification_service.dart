import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';

// mengimplementasikan servis untuk mengelola notifikasi pada aplikasi
class NotificationService {
  // menerapkan pola singleton untuk memastikan hanya ada satu instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // melakukan inisialisasi konfigurasi dasar notifikasi
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
      );

      _isInitialized = true;
      Logger.info('NotificationService: Notifikasi berhasil diinisialisasi');
    } catch (e) {
      Logger.error(
          'NotificationService: Error saat menginisialisasi notifikasi: $e');
    }
  }

  // menampilkan notifikasi setelah transaksi berhasil dilakukan
  Future<void> showTransactionNotification(String title, String body) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'transaction_channel',
        'Transaction Notifications',
        channelDescription: 'Notifikasi untuk transaksi',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );

      Logger.info(
          'NotificationService: Notifikasi transaksi ditampilkan: $title');
    } catch (e) {
      Logger.error(
          'NotificationService: Error saat menampilkan notifikasi transaksi: $e');
    }
  }

  // menjadwalkan notifikasi untuk ditampilkan pada waktu yang ditentukan
  Future<void> scheduleNotification(
      String title, String body, DateTime scheduledDate) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: 'Notifikasi yang dijadwalkan',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.zonedSchedule(
        1,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      Logger.info(
          'NotificationService: Notifikasi dijadwalkan untuk: ${scheduledDate.toString()}');
    } catch (e) {
      Logger.error(
          'NotificationService: Error saat menjadwalkan notifikasi: $e');
    }
  }
}

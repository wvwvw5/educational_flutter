import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wrapper around flutter_local_notifications for scheduling habit reminders.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'habit_reminders';
  static const String _channelName = 'Habit Reminders';
  static const String _channelDesc =
      'Reminders to complete your daily habits';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();

      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );
      await _plugin.initialize(initSettings);

      // Android 13+ permission
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_initialized) await init();
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) await init();
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Show instant notification error: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

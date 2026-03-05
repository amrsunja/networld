import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../locale/l10n.dart';

class NotificationsServices {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return ;

    // 1. Initialize the timezone database
    tz.initializeTimeZones();

    try {
      // Correctly accessing the identifier from the object
      // 2. Get the device's specific timezone string (e.g., "Africa/Cairo" or "Europe/London")
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      // 3. Set the local location so tz.local works
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // Fallback if the platform fails to return a timezone
      tz.setLocalLocation(tz.getLocation('UTC'));
    }



    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings
    );

    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_chanel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  void showSimpleNotification() async {
    await notificationPlugin.show(
      0,
      'Hello from Networld!',
      'This is a simple notification.',
      notificationDetails(),
    );
  }

  // Helper to get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyNotifications(AppLocale locale) async {
    /*
    // Schedule 10:00 AM Notification
    await notificationPlugin.zonedSchedule(
      1, // Unique ID
      locale.notif_1_title,
      locale.notif_1_body,
      _nextInstanceOfTime(10, 0),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
    );

    // Schedule 8:00 PM (20:00) Notification
    await notificationPlugin.zonedSchedule(
      2, // Unique ID
      locale.notif_2_title,
      locale.notif_2_body,
      _nextInstanceOfTime(20, 0),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
    );
    */
  }

  Future<void> removeAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
}

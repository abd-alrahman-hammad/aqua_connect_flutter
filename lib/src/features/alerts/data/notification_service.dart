import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Channel IDs
  static const String channelIdHigh = 'high_importance_channel';
  static const String channelIdDefault = 'default_importance_channel';

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS/macOS initialization settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _handleNotificationTap(response);
      },
    );

    await _createNotificationChannels();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
        channelIdHigh,
        'Critical Alerts',
        description: 'Notifications for critical system alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
            channelIdDefault,
            'General Notifications',
            description: 'General system notifications',
            importance: Importance.defaultImportance,
            playSound: true,
            enableVibration: true,
          );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(highChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(defaultChannel);
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isCritical = false,
  }) async {
    if (!_isInitialized) await initialize();

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          isCritical ? channelIdHigh : channelIdDefault,
          isCritical ? 'Critical Alerts' : 'General Notifications',
          channelDescription: isCritical
              ? 'Notifications for critical system alerts'
              : 'General system notifications',
          importance: isCritical
              ? Importance.max
              : Importance.defaultImportance,
          priority: isCritical ? Priority.high : Priority.defaultPriority,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(body),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool isCritical = false,
  }) async {
    if (!_isInitialized) await initialize();

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          isCritical ? channelIdHigh : channelIdDefault,
          isCritical ? 'Critical Alerts' : 'General Notifications',
          channelDescription: isCritical
              ? 'Notifications for critical system alerts'
              : 'General system notifications',
          importance: isCritical
              ? Importance.max
              : Importance.defaultImportance,
          priority: isCritical ? Priority.high : Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Notification tap handled - payload: ${response.payload}
    }
  }

  Future<NotificationResponse?> getNotificationLaunchDetails() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      return notificationAppLaunchDetails?.notificationResponse;
    }
    return null;
  }
}

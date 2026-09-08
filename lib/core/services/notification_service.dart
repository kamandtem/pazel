import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
abstract interface class NotificationService {
  Future<bool> requestPermission();
  Future<void> schedule(int id, String title, String body, DateTime at);
  Future<void> cancel(int id);
  Future<void> cancelAll();
}
class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool get _supported => !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> _init() async {
    if (_ready || !_supported) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_pazel'),
      iOS: DarwinInitializationSettings(requestAlertPermission: false,
        requestBadgePermission: false, requestSoundPermission: false)));
    _ready = true;
  }
  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ?? false;
    }
    return await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }
  @override
  Future<void> schedule(int id, String title, String body, DateTime at) async {
    if (!_supported || !at.isAfter(DateTime.now())) return;
    await _init();
    await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(at, tz.UTC),
      const NotificationDetails(android: AndroidNotificationDetails(
        'study_reminders', 'Study reminders', channelDescription: 'Pazel local study reminders',
        importance: Importance.high, priority: Priority.high), iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
  @override
  Future<void> cancel(int id) async { if (_supported) { await _init(); await _plugin.cancel(id); } }
  @override
  Future<void> cancelAll() async { if (_supported) { await _init(); await _plugin.cancelAll(); } }
}

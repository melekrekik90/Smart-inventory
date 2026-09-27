import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal(); // singelton 
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const int _stockAlertId = 1;
  static const int _reminderBaseId = 100;
  static const String _stockChannelId = 'stock_alerts';
  static const String _reminderChannelId = 'reminders';

  /// Initialise le service (appeler dans main())
  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
    
    try {
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    } catch (e) {
      // Fallback si l'identifiant n'est pas trouvé (ex: "GMT" sur émulateur)
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Demander la permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // =========================================================
  //  1. ALERTE STOCK FAIBLE (immédiate)
  // =========================================================

  Future<void> showLowStockAlert(List<String> lowStockItems) async {
    if (lowStockItems.isEmpty) return;

    const String title = '\u26a0\ufe0f Attention - Stock critique !';
    final String body = lowStockItems.length == 1
        ? lowStockItems.first
        : '${lowStockItems.length} produits sont presque \u00e9puis\u00e9s !';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _stockChannelId,
      'Alertes de stock',
      channelDescription: 'Notifications pour les produits en stock faible',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Stock faible',
      styleInformation: BigTextStyleInformation(
        lowStockItems.map((item) => '\u2022 $item').join('\n'),
        contentTitle: title,
        summaryText: 'Consultez votre inventaire',
      ),
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id: _stockAlertId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  // =========================================================
  //  2. RAPPEL QUOTIDIEN (planifi\u00e9)
  // =========================================================

  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    await _plugin.cancel(id: _reminderBaseId);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      'Rappels',
      channelDescription: 'Rappels pour utiliser Smart Inventory',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      id: _reminderBaseId,
      title: '\ud83d\udce6 Smart Inventory',
      body: 'N\'oubliez pas de v\u00e9rifier votre stock aujourd\'hui !',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: _reminderBaseId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

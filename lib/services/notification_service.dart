import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static const _channelId = 'hydralife_channel';
  static const _channelName = 'Recordatorios de agua';
  static const _channelDesc = 'Notificaciones para recordar tomar agua';

  static Future<void> init() async {
    if (_inicializado) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _inicializado = true;
  }

  static Future<void> pedirPermiso() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (impl != null) {
      await impl.requestNotificationsPermission();
    }
  }

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );

  static Future<void> programarRecordatorios({required int cadaHoras}) async {
    await cancelarTodos();
    final ahora = DateTime.now();
    for (int i = 1; i <= 10; i++) {
      final cuando = ahora.add(Duration(hours: cadaHoras * i));
      if (cuando.hour >= 22) break;
      await _plugin.zonedSchedule(
        i,
        '¡Hora de hidratarte!',
        'Recuerda tomar un vaso de agua. Tu cuerpo te lo agradecerá.',
        _toTZDateTime(cuando),
        _detalles,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> notificacionPrueba() async {
    await _plugin.show(0, '¡Hydra Life!', 'Las notificaciones funcionan correctamente.', _detalles);
  }

  static Future<void> cancelarTodos() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime(tz.local, dt.year, dt.month, dt.day, dt.hour, dt.minute);
  }
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(
      tz.getLocation('America/Sao_Paulo'),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initializationSettings,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final notificacoesPermitidas =
        await androidPlugin?.areNotificationsEnabled();

    if (notificacoesPermitidas != true) {
      await androidPlugin?.requestNotificationsPermission();
    }

    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String? descricao,
    required DateTime dataHora,
  }) async {
    final horario = tz.TZDateTime.from(
      dataHora,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id,
      titulo,
      descricao ?? 'Você tem um lembrete para o seu pet.',
      horario,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lembretes_channel',
          'Lembretes',
          channelDescription: 'Notificações dos lembretes dos pets',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  static int gerarIdNotificacao(ReminderModel lembrete) {
    return lembrete.dataHora.millisecondsSinceEpoch
        .remainder(2147483647);
  }
}
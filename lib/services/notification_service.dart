import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ══════════════════════════════════════════════════════════════
// NotificationService — notificaciones locales programadas
//
// Permite al usuario configurar un recordatorio diario
// "¿Qué cocinamos hoy?" a la hora que prefiera.
//
// Usa flutter_local_notifications + timezone para programar
// notificaciones recurrentes diarias.
// ══════════════════════════════════════════════════════════════

class NotificationService {
  static final NotificationService _instancia = NotificationService._();
  factory NotificationService() => _instancia;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const String _claveActivo   = 'notif_activo';
  static const String _claveHora     = 'notif_hora';
  static const String _claveMinuto   = 'notif_minuto';
  static const int    _idNotificacion = 100;

  // ── INICIALIZAR ─────────────────────────────────────────────────
  Future<void> inicializar() async {
    // En Web no hay soporte de notificaciones locales
    if (kIsWeb) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Tijuana'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Si ya tenía recordatorio activo, lo reprograma
    final activo = await estaActivo();
    if (activo) {
      final hora = await obtenerHora();
      final minuto = await obtenerMinuto();
      await programarRecordatorio(hora, minuto);
    }
  }

  // ── PROGRAMAR RECORDATORIO DIARIO ───────────────────────────────
  Future<void> programarRecordatorio(int hora, int minuto) async {
    if (kIsWeb) return;

    // Cancelar anterior
    await _plugin.cancel(_idNotificacion);

    // Detalles de la notificación
    const androidDetalles = AndroidNotificationDetails(
      'cocina_recordatorio',
      'Recordatorio diario',
      channelDescription: '¿Qué cocinamos hoy?',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const detalles = NotificationDetails(android: androidDetalles);

    // Calcular la próxima fecha/hora
    final ahora = tz.TZDateTime.now(tz.local);
    var programado = tz.TZDateTime(tz.local, ahora.year, ahora.month, ahora.day, hora, minuto);

    // Si la hora ya pasó hoy, programar para mañana
    if (programado.isBefore(ahora)) {
      programado = programado.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _idNotificacion,
      '🍳 ¿Qué cocinamos hoy?',
      'Abre CocinaApp y descubre nuevas recetas deliciosas',
      programado,
      detalles,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repite diariamente
    );

    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveActivo, true);
    await prefs.setInt(_claveHora, hora);
    await prefs.setInt(_claveMinuto, minuto);
  }

  // ── CANCELAR RECORDATORIO ───────────────────────────────────────
  Future<void> cancelarRecordatorio() async {
    if (kIsWeb) return;

    await _plugin.cancel(_idNotificacion);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveActivo, false);
  }

  // ── LEER PREFERENCIAS ───────────────────────────────────────────
  Future<bool> estaActivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveActivo) ?? false;
  }

  Future<int> obtenerHora() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_claveHora) ?? 12; // default mediodía
  }

  Future<int> obtenerMinuto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_claveMinuto) ?? 0;
  }
}

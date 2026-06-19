import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// No todo_model import — avoids Priority name conflict with flutter_local_notifications.

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
      );

      // Request POST_NOTIFICATIONS permission on Android 13+.
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _ready = true;
    } catch (_) {
      // Plugin not yet registered (first run after adding the package, or
      // unsupported platform). App works normally; notifications are no-ops
      // until a full rebuild + reinstall is done.
    }
  }

  // ── Scheduled reminders ───────────────────────────────────────────────────

  /// Schedules a reminder. Passing [at] = null cancels any existing reminder.
  static Future<void> scheduleReminder({
    required String todoId,
    required String title,
    String description = '',
    required DateTime? at,
  }) async {
    if (!_ready) return;
    final id = _idFor(todoId);
    if (at == null || at.isBefore(DateTime.now())) {
      await _plugin.cancel(id);
      return;
    }
    await _plugin.zonedSchedule(
      id,
      '⏰ $title',
      description.isNotEmpty ? description : 'Tap to open task',
      tz.TZDateTime.from(at, tz.local),
      _details(
        channelId: 'reminders',
        channelName: 'Task Reminders',
        channelDesc: 'Scheduled task reminder alerts',
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(String todoId) async {
    if (_ready) await _plugin.cancel(_idFor(todoId));
  }

  // ── Collaborator notifications ────────────────────────────────────────────

  static Future<void> showCollaboratorNotification({
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _details(
        channelId: 'collaborators',
        channelName: 'Shared List Updates',
        channelDesc: 'Alerts when collaborators add or change tasks',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Stable int ID from first 8 hex chars of UUID — avoids hashCode instability.
  static int _idFor(String todoId) =>
      int.parse(todoId.replaceAll('-', '').substring(0, 8), radix: 16);

  static NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDesc,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
    ),
    iOS: const DarwinNotificationDetails(),
  );
}

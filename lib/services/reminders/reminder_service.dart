import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/document.dart';

const _reminderChannelId = 'expiration_reminders';

/// Schedules a local "this document is expiring soon" notification.
///
/// Real, OS-delivered notifications only exist here on Android/iOS. Windows
/// builds against a no-op stub for `flutter_local_notifications_windows`
/// (see `local_packages/flutter_local_notifications_windows_stub/pubspec.yaml`
/// — the real plugin needs a Visual Studio ATL component this project
/// otherwise has no reason to require), and Web has no equivalent OS-level
/// notification concept either. On those platforms every method here is a
/// deliberate no-op: the library screen's "expiring soon" badge (computed
/// straight from `Document.isExpiringSoon`, no scheduling involved) is what
/// surfaces reminders instead — see `ARCHITECTURE.md`.
class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get supportsRealNotifications => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _ensureInitialized() async {
    if (!supportsRealNotifications || _initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _initialized = true;
  }

  /// (Re)schedules the reminder for [doc], replacing any previous one.
  /// Cancels outright if [Document.reminderDate] is null or already past —
  /// callers don't need to check that themselves first.
  Future<void> scheduleReminder(Document doc) async {
    await cancelReminder(doc.id);
    if (!supportsRealNotifications) return;

    final reminderDate = doc.reminderDate;
    final expiresAt = doc.expiresAt;
    if (reminderDate == null || expiresAt == null) return;

    // Fire at a fixed local wall-clock hour on the reminder date. Tagged as
    // UTC below purely as a `tz.Location` label for `zonedSchedule` — since
    // `wallClock` is already a real local `DateTime`, its
    // millisecondsSinceEpoch is the correct absolute instant regardless of
    // which Location it's wrapped in, so this fires at the right real-world
    // moment without needing the device's actual timezone name.
    final wallClock = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9);
    if (wallClock.isBefore(DateTime.now())) return;

    await _ensureInitialized();
    await _plugin.zonedSchedule(
      id: doc.id,
      title: 'Expiring soon',
      body: '"${doc.name}" expires ${_formatDate(expiresAt)}',
      scheduledDate: tz.TZDateTime.from(wallClock, tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Expiration reminders',
          channelDescription: 'Reminders for documents you set an expiration date on',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // "Inexact" is deliberate: exact scheduling needs the user to grant
      // Android's SCHEDULE_EXACT_ALARM permission separately, which is real
      // friction for what's a day-granularity reminder ("expires in 30
      // days") — being off by up to a few minutes doesn't matter here.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int documentId) async {
    if (!supportsRealNotifications) return;
    await _ensureInitialized();
    await _plugin.cancel(id: documentId);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

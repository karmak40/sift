import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

/// Intentional no-op — see this package's pubspec.yaml. Sift's own code
/// never calls into this on Windows: `ReminderService` gates every real
/// scheduling call behind `!Platform.isWindows` and shows in-app "expiring
/// soon" indicators there instead, so every inherited method (which all
/// throw `UnimplementedError` by default in the base class) and
/// `initialize()` below should only ever be reached by a bug, never by
/// normal use.
class NoOpFlutterLocalNotificationsWindows extends FlutterLocalNotificationsPlatform {
  static void registerWith() {
    FlutterLocalNotificationsPlatform.instance = NoOpFlutterLocalNotificationsWindows();
  }
}

/// The real plugin's `FlutterLocalNotificationsWindows` extends the same
/// base interface and overrides a few methods with Windows-only extra
/// parameters (`notificationDetails`) plus a Windows-only `initialize()` —
/// replicated here with matching signatures purely so the main
/// `flutter_local_notifications` package's Dart source (which calls these
/// against this specific type) compiles. Never constructed by Sift's own
/// code, so every body just throws.
class FlutterLocalNotificationsWindows extends FlutterLocalNotificationsPlatform {
  Future<bool> initialize({
    required WindowsInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    throw UnimplementedError('initialize() has not been implemented');
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WindowsNotificationDetails? notificationDetails,
  }) async {
    throw UnimplementedError('show() has not been implemented');
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
    WindowsNotificationDetails? notificationDetails,
  }) async {
    throw UnimplementedError('zonedSchedule() has not been implemented');
  }

  @override
  Future<void> periodicallyShow({
    required int id,
    String? title,
    String? body,
    String? payload,
    required RepeatInterval repeatInterval,
    WindowsNotificationDetails? notificationDetails,
  }) async {
    throw UnimplementedError('periodicallyShow() has not been implemented');
  }
}

/// Stand-in for the real per-platform settings/details types the main
/// package declares as nullable fields (`InitializationSettings.windows`,
/// `NotificationDetails.windows`) but never constructs itself — Sift's own
/// code never populates these on Windows either, so no real fields are
/// needed, just types that exist.
class WindowsInitializationSettings {
  const WindowsInitializationSettings();
}

class WindowsNotificationDetails {
  const WindowsNotificationDetails();
}

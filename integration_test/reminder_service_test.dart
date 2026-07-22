import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sift/data/models/document.dart';
import 'package:sift/services/reminders/reminder_service.dart';

/// Runs on a real device so the actual `flutter_local_notifications`
/// platform channel is exercised (BiometricPrompt-style permission request
/// + real OS scheduling on Android/iOS). Doesn't assert a notification
/// actually appears (no way to observe the OS notification tray from here)
/// — proves the call path completes without throwing, which is what a
/// build-time-only check can't tell you.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scheduleReminder() then cancelReminder() complete without throwing', (tester) async {
    final service = ReminderService();
    final doc = Document(
      id: 999001,
      name: 'Integration Test Passport.pdf',
      type: DocType.pdf,
      categoryId: 'personal',
      sizeBytes: 100,
      addedAt: DateTime.now(),
      storageKey: '',
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      reminderDaysBefore: 30,
    );

    await service.scheduleReminder(doc);
    await service.cancelReminder(doc.id);

    // ignore: avoid_print
    print('supportsRealNotifications => ${service.supportsRealNotifications}');
  });
}

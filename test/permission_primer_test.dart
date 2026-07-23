import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sift/l10n/app_localizations.dart';
import 'package:sift/ui/widgets/permission_primer.dart';

const _permissionHandlerChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// PermissionStatus.permanentlyDenied's ordinal per
/// permission_handler_platform_interface's `statusByValue` — see
/// permission_status.dart. Not part of the public API, so this is just the
/// raw wire value the plugin's method channel uses.
const _permanentlyDeniedStatus = 4;

Future<void> _pumpWithLocale(
  WidgetTester tester,
  Widget Function(BuildContext) builder,
) {
  return tester.pumpWidget(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: builder),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Pumps a button that calls [ensurePermissionPrimed] on tap, taps it, and
  /// returns the still-pending Future — the caller then interacts with the
  /// sheet (tap Continue/Not now) and awaits this Future for the result.
  Future<Future<bool>> pumpAndTrigger(WidgetTester tester) async {
    late Future<bool> primerFuture;
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              primerFuture = ensurePermissionPrimed(
                context,
                prefsKey: 'test_permission',
                icon: Icons.camera_alt,
                title: 'Test title',
                message: 'Test message',
              );
            },
            child: const Text('trigger'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();
    return primerFuture;
  }

  testWidgets('shows the primer sheet the first time, not yet primed', (
    tester,
  ) async {
    await pumpAndTrigger(tester);
    expect(find.text('Test title'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('declining ("Not now") returns false and does not persist', (
    tester,
  ) async {
    final future1 = await pumpAndTrigger(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(await future1, isFalse);
    expect(await isPermissionPrimed('test_permission'), isFalse);

    // Triggering again shows the sheet again, since declining didn't persist.
    await pumpAndTrigger(tester);
    expect(find.text('Test title'), findsOneWidget);
  });

  testWidgets('continuing returns true and persists so it never shows again', (
    tester,
  ) async {
    final future1 = await pumpAndTrigger(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(await future1, isTrue);
    expect(await isPermissionPrimed('test_permission'), isTrue);

    // Triggering again resolves true immediately with no sheet shown.
    final future2 = await pumpAndTrigger(tester);
    expect(await future2, isTrue);
    expect(find.text('Test title'), findsNothing);
    expect(find.text('Test message'), findsNothing);
  });

  group('showPermissionSettingsDialog', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_permissionHandlerChannel, null);
    });

    testWidgets(
      'shows the title/message and Cancel dismisses without opening settings',
      (tester) async {
        var openSettingsCalled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_permissionHandlerChannel, (call) async {
              if (call.method == 'openAppSettings') openSettingsCalled = true;
              return null;
            });

        await _pumpWithLocale(
          tester,
          (context) => ElevatedButton(
            onPressed: () => showPermissionSettingsDialog(
              context,
              title: 'Camera access is off',
              message: 'Turn it on in Settings.',
            ),
            child: const Text('open'),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Camera access is off'), findsOneWidget);
        expect(find.text('Turn it on in Settings.'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Camera access is off'), findsNothing);
        expect(openSettingsCalled, isFalse);
      },
    );

    testWidgets('"Open Settings" calls openAppSettings and dismisses', (
      tester,
    ) async {
      var openSettingsCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_permissionHandlerChannel, (call) async {
            if (call.method == 'openAppSettings') openSettingsCalled = true;
            return true;
          });

      await _pumpWithLocale(
        tester,
        (context) => ElevatedButton(
          onPressed: () => showPermissionSettingsDialog(
            context,
            title: 'Camera access is off',
            message: 'Turn it on in Settings.',
          ),
          child: const Text('open'),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(openSettingsCalled, isTrue);
      expect(find.text('Camera access is off'), findsNothing);
    });
  });

  group('warnIfNotificationsPermanentlyDenied', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_permissionHandlerChannel, null);
    });

    testWidgets(
      'never checks permission status or shows anything on a non-mobile platform',
      (tester) async {
        // This test runs on the host platform (Windows/Linux/macOS in CI),
        // which is never Android or iOS — the one platform pairing this
        // function is actually meant to run on. See the doc comment on
        // warnIfNotificationsPermanentlyDenied: it's a deliberate no-op
        // everywhere else, since desktop/web have no such permission at all.
        var channelCalled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_permissionHandlerChannel, (call) async {
              channelCalled = true;
              return _permanentlyDeniedStatus;
            });

        await _pumpWithLocale(
          tester,
          (context) => ElevatedButton(
            onPressed: () => warnIfNotificationsPermanentlyDenied(context),
            child: const Text('open'),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(channelCalled, isFalse);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });
}

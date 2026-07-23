import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// One-off generator for the app icon source images used by
/// flutter_launcher_icons (see the `flutter_launcher_icons:` block in
/// pubspec.yaml). Not auto-run by a bare `flutter test` — this file
/// deliberately doesn't end in `_test.dart`, so it has to be invoked
/// explicitly:
///
///   flutter test test/tools/generate_app_icon.dart
///
/// Reuses the exact same shape/color/font as the in-app logo mark
/// (`home_shell.dart`'s AppBar "S" tile) so the icon stays pixel-consistent
/// with the brand as it renders elsewhere in the app. Re-run this (then
/// `dart run flutter_launcher_icons`) if the brand mark ever changes.
void main() {
  const accent = Color(0xFF5841C8); // hueColor(250, lightness: 0.52)

  Future<void> capture(
    WidgetTester tester, {
    required String outPath,
    required bool transparentBackground,
    required double sSize,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/IBMPlexSans-Bold.ttf');
    final loader = FontLoader('IBM Plex Sans')..addFont(Future.value(fontData));
    await loader.load();

    // The default test surface is 800x600 logical px, smaller than the
    // 1024x1024 icon canvas — without this, the widget gets clipped/scaled
    // to fit the surface instead of rendering at its real requested size.
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: SizedBox(
            width: 1024,
            height: 1024,
            child: DecoratedBox(
              // Deliberately NOT rounding the corners here, even for the
              // solid-background variant: Apple requires the 1024x1024 App
              // Store marketing icon to be fully opaque with square
              // corners (no alpha channel at all) — iOS applies its own
              // corner-rounding mask at render time. Baking rounding in
              // here would both violate that and double up with iOS's own
              // mask. Android's launcher icon shape is handled separately
              // by the adaptive icon foreground/background split below.
              decoration: BoxDecoration(color: transparentBackground ? null : accent),
              child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'IBM Plex Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: sSize,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // toImage()/toByteData() and file I/O do real async engine/OS work that
    // never resolves under flutter_test's fake-clock zone unless explicitly
    // escaped via runAsync — otherwise this hangs until the test timeout.
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      await File(outPath).writeAsBytes(bytes);
    });
  }

  testWidgets('generate full-bleed icon (iOS / legacy Android)', (tester) async {
    await capture(
      tester,
      outPath: 'assets/icon/icon_full.png',
      transparentBackground: false,
      sSize: 620,
    );
  });

  testWidgets('generate transparent foreground (Android adaptive icon)', (tester) async {
    await capture(
      tester,
      outPath: 'assets/icon/icon_foreground.png',
      transparentBackground: true,
      // Adaptive icon launchers crop to a circle/squircle/rounded-square
      // safe zone — keep the glyph well inside that so it never clips.
      sSize: 420,
    );
  });
}

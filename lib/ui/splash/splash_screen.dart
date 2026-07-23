import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// The animated brand reveal shown while the app initializes (see
/// `SplashGate` in `main.dart`). Recreates the "2c — playful, evolved"
/// direction from the Sift Splash design doc — confetti and file chips
/// falling in around a bouncy "S" mark, then the "Sift" wordmark bouncing
/// in letter by letter, then the tagline fading in — but recolored to
/// Sift's actual brand (the `SiftColors.accent` purple and IBM Plex Sans,
/// not the design doc's own orange/Space Grotesk) so it flows straight
/// into the rest of the app instead of looking like a different product.
///
/// Runs once (not repeating) over [_duration] and settles into a static
/// resting frame — safe to keep on screen longer than that if app
/// initialization takes a moment, since nothing loops indefinitely.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const duration = Duration(milliseconds: 2200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashScreen.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Bounce/position curve — deliberately kept separate from opacity below,
  /// since `Curves.elasticOut` overshoots past 1.0 (desirable for a bouncy
  /// `Transform`, but `Opacity` asserts its value stays within [0, 1]).
  Animation<double> _bounce(double start, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(start, end, curve: Curves.elasticOut),
  );

  /// Fade curve for the same element — monotonic, never overshoots, safe
  /// to feed straight into an `Opacity`/`FadeTransition`.
  Animation<double> _fade(double start, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(start, end, curve: Curves.easeOut),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final markScale = _bounce(0.05, 0.42);
    final markFade = _fade(0.05, 0.22);

    const chipHues = [45.0, 150.0, 340.0];
    final chipScales = [
      _bounce(0.16, 0.42),
      _bounce(0.22, 0.48),
      _bounce(0.28, 0.54),
    ];
    final chipFades = [_fade(0.16, 0.30), _fade(0.22, 0.36), _fade(0.28, 0.42)];

    const confettiHues = [45.0, 210.0, 340.0, 150.0];
    final confettiFades = [
      _fade(0.0, 0.30),
      _fade(0.08, 0.38),
      _fade(0.16, 0.46),
      _fade(0.24, 0.54),
    ];
    final confettiFalls = [
      _bounce(0.0, 0.55),
      _bounce(0.08, 0.62),
      _bounce(0.16, 0.68),
      _bounce(0.24, 0.74),
    ];

    const letters = ['S', 'i', 'f', 't'];
    final letterBounces = [
      _bounce(0.42, 0.58),
      _bounce(0.47, 0.63),
      _bounce(0.52, 0.68),
      _bounce(0.57, 0.73),
    ];
    final letterFades = [
      _fade(0.42, 0.52),
      _fade(0.47, 0.57),
      _fade(0.52, 0.62),
      _fade(0.57, 0.67),
    ];

    final taglineFade = _fade(0.76, 0.96);

    return Scaffold(
      backgroundColor: SiftColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 150,
                  // Confetti pieces are positioned above this box (negative
                  // `top`) and fall down through it, so clipping must be
                  // off — a plain Stack's default hardEdge clip would cut
                  // them off before they ever became visible.
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < confettiHues.length; i++)
                        _ConfettiPiece(
                          hue: confettiHues[i],
                          left: 70.0 + i * 22,
                          fall: confettiFalls[i],
                          fade: confettiFades[i],
                        ),
                      Positioned(
                        left: 6,
                        top: 14,
                        child: _Chip(
                          hue: chipHues[0],
                          width: 44,
                          height: 54,
                          scale: chipScales[0],
                          fade: chipFades[0],
                        ),
                      ),
                      Positioned(
                        right: 2,
                        top: 4,
                        child: _Chip(
                          hue: chipHues[1],
                          width: 40,
                          height: 50,
                          scale: chipScales[1],
                          fade: chipFades[1],
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 6,
                        child: _Chip(
                          hue: chipHues[2],
                          width: 38,
                          height: 46,
                          scale: chipScales[2],
                          fade: chipFades[2],
                        ),
                      ),
                      FadeTransition(
                        opacity: markFade,
                        child: ScaleTransition(
                          scale: markScale,
                          child: Container(
                            width: 96,
                            height: 96,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: SiftColors.accent,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: SiftColors.accent.withValues(
                                    alpha: 0.45,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Text(
                              'S',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 58,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < letters.length; i++)
                      FadeTransition(
                        opacity: letterFades[i],
                        child: ScaleTransition(
                          scale: letterBounces[i],
                          child: Text(
                            letters[i],
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 34,
                              color: SiftColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: taglineFade,
                  child: Text(
                    '${l10n.splashTagline} ✦',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SiftColors.accentDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.hue,
    required this.width,
    required this.height,
    required this.scale,
    required this.fade,
  });

  final double hue;
  final double width;
  final double height;
  final Animation<double> scale;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: hueColor(hue),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPiece extends StatelessWidget {
  const _ConfettiPiece({
    required this.hue,
    required this.left,
    required this.fall,
    required this.fade,
  });

  final double hue;
  final double left;
  final Animation<double> fall;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: -40,
      child: FadeTransition(
        opacity: fade,
        child: AnimatedBuilder(
          animation: fall,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, fall.value * 130),
            child: child,
          ),
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: hueColor(hue),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

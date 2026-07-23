import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_controller.dart';
import '../theme.dart';
import '../widgets/doc_icon_tile.dart';

/// The first-launch, 3-page feature tour — shown once (see
/// `OnboardingController`/`SplashGate` in `main.dart`) right after the
/// splash screen finishes. Covers the three "turn 1" pages from the Sift
/// Onboarding design doc (Store/Organize/Find — "Welcome" is skipped here
/// since the splash screen already covers that same brand-reveal moment;
/// showing it twice in a row would be redundant), restyled to Sift's real
/// branding and with copy corrected to describe what the app actually
/// does — the original design's "Organize" copy claimed automatic
/// smart-tagging, which isn't a real Sift feature; categories here are
/// always user-created and user-assigned.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      await ref.read(onboardingControllerProvider.notifier).markSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _OnboardingPage(
        illustration: const _StoreIllustration(),
        title: l10n.onboardingStoreTitle,
        body: l10n.onboardingStoreBody,
      ),
      _OnboardingPage(
        illustration: const _OrganizeIllustration(),
        title: l10n.onboardingOrganizeTitle,
        body: l10n.onboardingOrganizeBody,
      ),
      _OnboardingPage(
        illustration: const _FindIllustration(),
        title: l10n.onboardingFindTitle,
        body: l10n.onboardingFindBody,
      ),
    ];

    return Scaffold(
      backgroundColor: SiftColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < pages.length; i++) _Dot(active: i == _page),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(backgroundColor: SiftColors.accent),
                      child: Text(_page == pages.length - 1 ? l10n.onboardingGetStarted : l10n.onboardingNext),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3.5),
      width: active ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? SiftColors.accent : SiftColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.illustration, required this.title, required this.body});

  final Widget illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Align(alignment: Alignment.bottomCenter, child: illustration)),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SiftColors.textPrimary)),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(fontSize: 14, height: 1.5, color: SiftColors.textSecondary),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Page 1 — scattered file chips on a soft card, echoing "drop anything
/// in, it's stored safely."
class _StoreIllustration extends StatelessWidget {
  const _StoreIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 14))],
            ),
          ),
          Transform.translate(
            offset: const Offset(-46, -34),
            child: Transform.rotate(angle: -0.25, child: const DocIconTile(type: DocType.pdf, width: 46, height: 56)),
          ),
          Transform.translate(
            offset: const Offset(34, -38),
            child: Transform.rotate(angle: 0.16, child: const DocIconTile(type: DocType.img, width: 44, height: 54)),
          ),
          Transform.translate(
            offset: const Offset(-6, 14),
            child: Transform.rotate(angle: -0.1, child: const DocIconTile(type: DocType.xls, width: 44, height: 54)),
          ),
          Transform.translate(
            offset: const Offset(52, 24),
            child: Transform.rotate(angle: 0.26, child: const DocIconTile(type: DocType.doc, width: 40, height: 50)),
          ),
        ],
      ),
    );
  }
}

/// Page 2 — category rows, echoing "sort into categories you create," not
/// automatic tagging.
class _OrganizeIllustration extends StatelessWidget {
  const _OrganizeIllustration();

  Widget _row(String label, double hue, List<DocType> types) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 72,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(color: hueColor(hue), borderRadius: BorderRadius.circular(8)),
            child: Text(
              label,
              style: monoStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          for (final t in types)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: DocIconTile(type: t, width: 30, height: 38),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row('FINANCE', 150, const [DocType.pdf, DocType.xls]),
        _row('HEALTH', 30, const [DocType.pdf, DocType.img]),
        _row('TRAVEL', 210, const [DocType.pdf, DocType.pdf, DocType.pdf]),
      ],
    );
  }
}

/// Page 3 — a search bar + a matched result, echoing real search
/// (name + AI summary text) and the expiration-reminder feature the
/// original design didn't know about.
class _FindIllustration extends StatelessWidget {
  const _FindIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SiftColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: SiftColors.accent),
              const SizedBox(width: 10),
              Text('passport scan', style: TextStyle(fontSize: 14, color: SiftColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SiftColors.accentSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SiftColors.accentSoftBorder),
          ),
          child: Row(
            children: [
              const DocIconTile(type: DocType.pdf, width: 34, height: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 9,
                      width: 120,
                      decoration: BoxDecoration(
                        color: SiftColors.textPrimary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 7,
                      width: 70,
                      decoration: BoxDecoration(color: SiftColors.border, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: 0.4,
          child: Row(
            children: [
              const DocIconTile(type: DocType.img, width: 30, height: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: SiftColors.textSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

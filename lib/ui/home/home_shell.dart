import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/library_controller.dart';
import '../category/new_category_sheet.dart';
import '../coming_up/coming_up_screen.dart';
import '../library/library_screen.dart';
import '../settings/settings_screen.dart';
import '../theme.dart';
import '../upload/upload_sheet.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uiState = ref.watch(libraryControllerProvider);
    final tab = uiState.mobileTab;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SiftColors.accent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 9),
            const Text('Sift', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19)),
          ],
        ),
        actions: [
          if (tab == MobileTab.library)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              tooltip: l10n.newCategoryTooltip,
              onPressed: () => showNewCategorySheet(context),
            ),
        ],
        bottom: tab == MobileTab.library
            ? PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _SearchField(hintText: l10n.searchHint),
                ),
              )
            : null,
      ),
      body: switch (tab) {
        MobileTab.library => const LibraryScreen(),
        MobileTab.comingUp => const ComingUpScreen(),
        MobileTab.settings => const SettingsScreen(),
      },
      floatingActionButton: tab == MobileTab.library
          ? FloatingActionButton(
              backgroundColor: SiftColors.accent,
              onPressed: () => startAddDocument(context, ref),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: MobileTab.values.indexOf(tab),
        onDestinationSelected: (i) =>
            ref.read(libraryControllerProvider.notifier).setMobileTab(MobileTab.values[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.grid_view_rounded), label: l10n.navLibrary),
          NavigationDestination(icon: const Icon(Icons.notifications_none_rounded), label: l10n.navComingUp),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.navSettings),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (v) => ref.read(libraryControllerProvider.notifier).setSearch(v),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        filled: true,
        fillColor: SiftColors.sidebar,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SiftColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SiftColors.border),
        ),
      ),
    );
  }
}

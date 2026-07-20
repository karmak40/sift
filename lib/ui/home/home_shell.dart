import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library_controller.dart';
import '../category/new_category_sheet.dart';
import '../library/library_screen.dart';
import '../settings/settings_screen.dart';
import '../theme.dart';
import '../upload/upload_sheet.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              tooltip: 'New category',
              onPressed: () => showNewCategorySheet(context),
            ),
        ],
        bottom: tab != MobileTab.settings
            ? PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _SearchField(),
                ),
              )
            : null,
      ),
      body: switch (tab) {
        MobileTab.library => const LibraryScreen(),
        MobileTab.ai => const LibraryScreen(aiOnly: true),
        MobileTab.settings => const SettingsScreen(),
      },
      floatingActionButton: tab == MobileTab.library
          ? FloatingActionButton(
              backgroundColor: SiftColors.accent,
              onPressed: () => showUploadSheet(context, ref),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: MobileTab.values.indexOf(tab),
        onDestinationSelected: (i) =>
            ref.read(libraryControllerProvider.notifier).setMobileTab(MobileTab.values[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (v) => ref.read(libraryControllerProvider.notifier).setSearch(v),
      decoration: InputDecoration(
        hintText: 'Search documents & summaries',
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

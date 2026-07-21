import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/data_providers.dart';
import '../../providers/library_controller.dart';
import '../../providers/storage_location_controller.dart';
import '../theme.dart';
import '../widgets/ai_toggle_row.dart';
import '../widgets/section_label.dart';

/// Choosing where files live on disk only makes sense on a real desktop
/// filesystem — Android/iOS are sandboxed, and Web has no filesystem at all
/// (see `WebFileStorageService`). Gated to Windows specifically per how this
/// was asked for; drop `Platform.isWindows` for other desktop targets later
/// if needed.
bool get _canChangeStorageLocation => !kIsWeb && Platform.isWindows;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final uiState = ref.watch(libraryControllerProvider);
    final docs = docsAsync.valueOrNull ?? const [];
    final cats = catsAsync.valueOrNull ?? const [];
    final aiCount = docs.where((d) => d.hasAi).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        const SectionLabel('AI'),
        AiToggleRow(
          title: 'Summarize new uploads',
          subtitle: 'Default the AI toggle on when uploading',
          value: uiState.aiDefaultOn,
          onChanged: aiFeaturesEnabled
              ? (_) => ref.read(libraryControllerProvider.notifier).toggleAiDefault()
              : null,
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'Summaries created',
              subtitle: 'Across your whole library',
              trailing: Text(
                '$aiCount / ${docs.length}',
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: SiftColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Storage'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Local device storage',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${docs.length} files',
                        style: monoStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (docs.length / 100).clamp(0.03, 1.0),
                      minHeight: 8,
                      backgroundColor: SiftColors.border,
                      color: SiftColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            if (_canChangeStorageLocation) ...[
              const Divider(height: 1),
              const _StorageLocationRow(),
            ],
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Library'),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'Categories',
              trailing: Text('${cats.length}', style: monoStyle(fontSize: 13, color: SiftColors.textSecondary)),
            ),
            const Divider(height: 1),
            _SettingsRow(
              title: 'Default sort',
              trailing: Text(
                uiState.sortOrder.label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SiftColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Account'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: SiftColors.accentSoft,
                    child: Text('A', style: TextStyle(color: SiftColors.accentDark, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Rivera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('alex@example.com', style: TextStyle(fontSize: 12, color: SiftColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Sign out', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: SiftColors.danger)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StorageLocationRow extends ConsumerWidget {
  const _StorageLocationRow();

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a folder to store Sift files in',
    );
    if (picked == null) return;
    await ref.read(storageLocationControllerProvider.notifier).changePath(picked);
  }

  Future<void> _resetToDefault(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(storageLocationControllerProvider.notifier);
    final defaultPath = await controller.defaultPath();
    await controller.changePath(null);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Files moved back to $defaultPath')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(storageLocationControllerProvider);
    final busy = pathAsync.isLoading;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Files folder',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  pathAsync.when(
                    data: (path) => path,
                    loading: () => 'Moving files…',
                    error: (e, _) => 'Could not read current folder',
                  ),
                  style: monoStyle(fontSize: 11, color: SiftColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _choose(context, ref),
                  child: const Text('Change…'),
                ),
                TextButton(
                  onPressed: () => _resetToDefault(context, ref),
                  child: Text('Reset', style: TextStyle(color: SiftColors.textMuted)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiftColors.surface,
        border: Border.all(color: SiftColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.subtitle, required this.trailing});
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: SiftColors.textSecondary)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
